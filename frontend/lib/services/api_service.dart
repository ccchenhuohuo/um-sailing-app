import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/index.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${AppConstants.baseUrl}${AppConstants.apiPrefix}',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    validateStatus: (status) => true, // 允许所有状态码，不自动抛出异常
  ));

  String? _token;
  bool _initialized = false;

  /// 检查状态码是否成功 (200-299)
  bool _isSuccess(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  /// 安全解析响应数据
  dynamic _getData(Response response, String field) {
    if (response.data == null || response.data is! Map) {
      return null;
    }
    return response.data[field];
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // 启动时加载一次 token
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.accessTokenKey);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        return handler.next(e);
      },
    ));
  }

  Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.userInfoKey);
  }

  // ===== Auth =====
  Future<User> register({
    required String username,
    required String password,
    required String email,
    String? phone,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'username': username,
      'password': password,
      'email': email,
      'phone': phone,
    });

    if (!_isSuccess(response.statusCode)) {
      final errorMessage = _getData(response, 'detail') ?? '注册失败';
      throw Exception(errorMessage);
    }

    final userData = _getData(response, 'user');
    if (userData == null) {
      throw Exception('注册成功但无法获取用户信息');
    }
    return User.fromJson(userData as Map<String, dynamic>);
  }

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });

    // 检查响应状态码
    if (response.statusCode == 401) {
      // 用户名或密码错误
      final errorMessage = _getData(response, 'detail') ?? '用户名或密码错误';
      throw Exception(errorMessage);
    }

    if (!_isSuccess(response.statusCode)) {
      final errorMessage = _getData(response, 'detail') ?? '登录失败';
      throw Exception(errorMessage);
    }

    final token = _getData(response, 'access_token')?.toString();
    final userData = _getData(response, 'user');

    if (token == null || userData == null) {
      throw Exception('登录响应缺少必要字段');
    }

    final user = User.fromJson(userData as Map<String, dynamic>);

    // 登录成功后更新 token 缓存
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessTokenKey, token);
    await prefs.setString(AppConstants.userInfoKey, jsonEncode(user.toJson()));

    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.userInfoKey);
  }

  Future<User> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    if (response.statusCode != 200) {
      throw Exception('获取用户信息失败');
    }
    return User.fromJson(response.data);
  }

  // ===== User =====
  Future<User> updateUser(int userId, {String? username, String? email, String? phone}) async {
    final response = await _dio.put('/users/$userId', data: {
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '更新用户信息失败');
    }
    return User.fromJson(response.data);
  }

  Future<void> changePassword(int userId, String oldPassword, String newPassword) async {
    final response = await _dio.post('/users/$userId/password', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '修改密码失败');
    }
  }

  // ===== User Admin =====
  Future<List<User>> getUsers({int skip = 0, int limit = 100}) async {
    final response = await _dio.get('/users', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    if (response.statusCode != 200) {
      throw Exception('获取用户列表失败');
    }
    if (response.data is! List) {
      throw Exception('获取用户列表失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<User> getUser(int id) async {
    final response = await _dio.get('/users/$id');
    if (response.statusCode != 200) {
      throw Exception('获取用户详情失败');
    }
    return User.fromJson(response.data);
  }

  Future<User> updateUserAdmin(int id, {String? email, bool? isAdmin}) async {
    final response = await _dio.put('/users/$id', data: {
      if (email != null) 'email': email,
      if (isAdmin != null) 'is_admin': isAdmin,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '更新用户失败');
    }
    return User.fromJson(response.data);
  }

  Future<void> deleteUser(int id) async {
    final response = await _dio.delete('/users/$id');
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '删除用户失败');
    }
  }

  Future<double> updateUserBalance(int userId, double amount) async {
    final response = await _dio.post('/users/$userId/balance', data: {'amount': amount});
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '更新余额失败');
    }
    final balanceValue = response.data?['new_balance'];
    if (balanceValue == null) {
      throw Exception('获取余额失败');
    }
    return double.tryParse(balanceValue.toString()) ?? 0.0;
  }

  // ===== Activities =====

  /// 获取活动列表
  Future<List<Activity>> getActivities({int skip = 0, int limit = 20}) async {
    final response = await _dio.get('/activities', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    if (response.statusCode != 200) {
      throw Exception('获取活动列表失败');
    }
    if (response.data is! List) {
      throw Exception('获取活动列表失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 获取活动详情
  Future<Activity> getActivity(int id) async {
    final response = await _dio.get('/activities/$id');
    if (response.statusCode != 200) {
      throw Exception('获取活动详情失败');
    }
    return Activity.fromJson(response.data);
  }

  /// 创建活动
  Future<Activity> createActivity({
    required String title,
    String? description,
    String? location,
    required DateTime startTime,
    required DateTime endTime,
    int maxParticipants = 0,
  }) async {
    final response = await _dio.post('/activities', data: {
      'title': title,
      'description': description,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'max_participants': maxParticipants,
    });
    if (response.statusCode != 200) {
      throw Exception('创建活动失败');
    }
    return Activity.fromJson(response.data);
  }

  Future<void> signupActivity(int activityId) async {
    final response = await _dio.post('/activities/signup', data: {'activity_id': activityId});
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '报名失败');
    }
  }

  Future<void> checkinActivity(int activityId) async {
    final response = await _dio.post('/activities/$activityId/checkin');
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '签到失败');
    }
  }

  Future<List<ActivitySignup>> getMyActivitySignups() async {
    final response = await _dio.get('/activities/my/signups');
    if (response.statusCode != 200) {
      throw Exception('获取报名列表失败');
    }
    if (response.data is! List) {
      throw Exception('获取报名列表失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => ActivitySignup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 获取活动报名状态
  /// TODO: 性能优化 - 当前获取所有报名后过滤，建议后端提供单个活动状态 API
  Future<ActivitySignup?> getSignupStatus(int activityId) async {
    final signups = await getMyActivitySignups();
    try {
      return signups.firstWhere((s) => s.activityId == activityId);
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelSignup(int activityId) async {
    final response = await _dio.delete('/activities/signup/$activityId');
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '取消报名失败');
    }
  }

  // ===== Activities Admin =====
  Future<Activity> updateActivity(int id, {
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    int? maxParticipants,
  }) async {
    final response = await _dio.put('/activities/$id', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (startTime != null) 'start_time': startTime.toIso8601String(),
      if (endTime != null) 'end_time': endTime.toIso8601String(),
      if (maxParticipants != null) 'max_participants': maxParticipants,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '更新活动失败');
    }
    return Activity.fromJson(response.data);
  }

  Future<void> deleteActivity(int id) async {
    final response = await _dio.delete('/activities/$id');
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '删除活动失败');
    }
  }

  Future<List<ActivitySignup>> getActivitySignups(int activityId) async {
    final response = await _dio.get('/activities/$activityId/signups');
    if (response.statusCode != 200) {
      throw Exception('获取报名列表失败');
    }
    if (response.data is! List) {
      throw Exception('获取报名列表失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => ActivitySignup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ===== Boats =====
  Future<List<Boat>> getBoats({int skip = 0, int limit = 20, String? status}) async {
    final response = await _dio.get('/boats', queryParameters: {
      'skip': skip,
      'limit': limit,
      if (status != null) 'status': status,
    });
    if (response.statusCode != 200) {
      throw Exception('获取船只列表失败');
    }
    if (response.data is! List) {
      throw Exception('获取船只列表失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => Boat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Boat> getBoat(int id) async {
    final response = await _dio.get('/boats/$id');
    if (response.statusCode != 200) {
      throw Exception('获取船只详情失败');
    }
    return Boat.fromJson(response.data);
  }

  Future<Boat> createBoat({
    required String name,
    String? type,
    double rentalPrice = 0,
    String? description,
  }) async {
    final response = await _dio.post('/boats', data: {
      'name': name,
      'type': type,
      'rental_price': rentalPrice,
      'description': description,
    });
    if (response.statusCode != 200) {
      throw Exception('创建船只失败');
    }
    return Boat.fromJson(response.data);
  }

  Future<void> rentBoat(int boatId) async {
    final response = await _dio.post('/boats/$boatId/rent');
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '租船失败');
    }
  }

  Future<void> returnBoat(int rentalId) async {
    final response = await _dio.post('/boats/return', data: {'rental_id': rentalId});
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '归还失败');
    }
  }

  Future<List<BoatRental>> getMyRentals() async {
    final response = await _dio.get('/boats/rentals');
    if (response.statusCode != 200) {
      throw Exception('获取租船记录失败');
    }
    if (response.data is! List) {
      throw Exception('获取租船记录失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => BoatRental.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ===== Boats Admin =====
  Future<Boat> updateBoat(int id, {String? name, double? rentalPrice, String? status}) async {
    final response = await _dio.put('/boats/$id', data: {
      if (name != null) 'name': name,
      if (rentalPrice != null) 'rental_price': rentalPrice,
      if (status != null) 'status': status,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '更新船只失败');
    }
    return Boat.fromJson(response.data);
  }

  Future<void> deleteBoat(int id) async {
    final response = await _dio.delete('/boats/$id');
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '删除船只失败');
    }
  }

  Future<List<BoatRental>> getAllRentals() async {
    final response = await _dio.get('/boats/all/rentals');
    if (response.statusCode != 200) {
      throw Exception('获取租借记录失败');
    }
    if (response.data is! List) {
      throw Exception('获取租借记录失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => BoatRental.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ===== Finances =====
  Future<double> getBalance() async {
    final response = await _dio.get('/finances/balance');
    if (response.statusCode != 200) {
      throw Exception('获取余额失败');
    }
    final balanceValue = response.data?['total_balance'];
    if (balanceValue == null) {
      throw Exception('获取余额失败');
    }
    return double.tryParse(balanceValue.toString()) ?? 0.0;
  }

  Future<void> deposit(double amount, String? description) async {
    final response = await _dio.post('/finances/deposit', data: {
      'amount': amount,
      'description': description,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '充值失败');
    }
  }

  Future<List<TransactionRecord>> getTransactions() async {
    final response = await _dio.get('/finances/transactions');
    if (response.statusCode != 200) {
      throw Exception('获取交易记录失败');
    }
    if (response.data is! List) {
      throw Exception('获取交易记录失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => TransactionRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ===== Notices =====
  Future<List<Notice>> getNotices({int skip = 0, int limit = 20}) async {
    final response = await _dio.get('/notices', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    if (response.statusCode != 200) {
      throw Exception('获取公告列表失败');
    }
    if (response.data is! List) {
      throw Exception('获取公告列表失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => Notice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ===== Notices Admin =====
  Future<Notice> createNotice({required String title, required String content}) async {
    final response = await _dio.post('/notices', data: {
      'title': title,
      'content': content,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '创建公告失败');
    }
    return Notice.fromJson(response.data);
  }

  Future<Notice> updateNotice(int id, {String? title, String? content}) async {
    final response = await _dio.put('/notices/$id', data: {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '更新公告失败');
    }
    return Notice.fromJson(response.data);
  }

  Future<void> deleteNotice(int id) async {
    final response = await _dio.delete('/notices/$id');
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? '删除公告失败');
    }
  }

  // ===== Stats =====
  Future<Stats> getStats() async {
    final response = await _dio.get('/stats');
    if (response.statusCode != 200) {
      throw Exception('获取统计数据失败');
    }
    return Stats.fromJson(response.data);
  }

  // ===== Forum =====
  Future<List<Post>> getPosts({int skip = 0, int limit = 20, int? tagId}) async {
    final response = await _dio.get('/forum/posts', queryParameters: {
      'skip': skip,
      'limit': limit,
      if (tagId != null) 'tag_id': tagId,
    });
    if (response.statusCode != 200) {
      throw Exception('获取帖子列表失败');
    }
    if (response.data is! List) {
      throw Exception('获取帖子列表失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Post> createPost({
    required String title,
    required String content,
    int? tagId,
  }) async {
    final response = await _dio.post('/forum/posts', data: {
      'title': title,
      'content': content,
      'tag_id': tagId,
    });
    if (response.statusCode != 200) {
      throw Exception('创建帖子失败');
    }
    return Post.fromJson(response.data);
  }

  Future<List<Comment>> getComments(int postId) async {
    final response = await _dio.get('/forum/posts/$postId/comments');
    if (response.statusCode != 200) {
      throw Exception('获取评论列表失败');
    }
    if (response.data is! List) {
      throw Exception('获取评论列表失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createComment(int postId, String content) async {
    final response = await _dio.post('/forum/posts/$postId/comments', data: {
      'post_id': postId,
      'content': content,
    });
    if (response.statusCode != 200) {
      throw Exception('发表评论失败');
    }
  }

  Future<List<Tag>> getTags() async {
    final response = await _dio.get('/forum/tags');
    if (response.statusCode != 200) {
      throw Exception('获取标签列表失败');
    }
    if (response.data is! List) {
      throw Exception('获取标签列表失败：响应格式错误');
    }
    return (response.data as List)
        .map((e) => Tag.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
