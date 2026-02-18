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

  void init() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString(AppConstants.accessTokenKey);
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

    if (response.statusCode == 200) {
      return User.fromJson(response.data['user']);
    } else if (response.statusCode == 400) {
      final errorMessage = response.data['detail'] ?? '注册失败';
      throw Exception(errorMessage);
    } else {
      throw Exception('注册失败，请稍后重试');
    }
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
    if (response.statusCode == 200) {
      final token = response.data['access_token'];
      final user = User.fromJson(response.data['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.accessTokenKey, token);
      await prefs.setString(AppConstants.userInfoKey, jsonEncode(user.toJson()));

      return user;
    } else if (response.statusCode == 401) {
      // 用户名或密码错误
      final errorMessage = response.data['detail'] ?? '用户名或密码错误';
      throw Exception(errorMessage);
    } else {
      // 其他错误
      throw Exception('登录失败，请稍后重试');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.userInfoKey);
  }

  Future<User> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return User.fromJson(response.data);
  }

  // ===== Activities =====
  Future<List<Activity>> getActivities({int skip = 0, int limit = 20}) async {
    final response = await _dio.get('/activities', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    return (response.data as List)
        .map((e) => Activity.fromJson(e))
        .toList();
  }

  Future<Activity> getActivity(int id) async {
    final response = await _dio.get('/activities/$id');
    return Activity.fromJson(response.data);
  }

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
    return Activity.fromJson(response.data);
  }

  Future<void> signupActivity(int activityId) async {
    await _dio.post('/activities/signup', data: {'activity_id': activityId});
  }

  Future<void> checkinActivity(int activityId) async {
    await _dio.post('/activities/$activityId/checkin');
  }

  // ===== Boats =====
  Future<List<Boat>> getBoats({int skip = 0, int limit = 20, String? status}) async {
    final response = await _dio.get('/boats', queryParameters: {
      'skip': skip,
      'limit': limit,
      if (status != null) 'status': status,
    });
    return (response.data as List)
        .map((e) => Boat.fromJson(e))
        .toList();
  }

  Future<Boat> getBoat(int id) async {
    final response = await _dio.get('/boats/$id');
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
    return Boat.fromJson(response.data);
  }

  Future<void> rentBoat(int boatId) async {
    await _dio.post('/boats/$boatId/rent');
  }

  Future<void> returnBoat(int rentalId) async {
    await _dio.post('/boats/return', data: {'rental_id': rentalId});
  }

  // ===== Finances =====
  Future<double> getBalance() async {
    final response = await _dio.get('/finances/balance');
    return double.parse(response.data['total_balance'].toString());
  }

  Future<void> deposit(double amount, String? description) async {
    await _dio.post('/finances/deposit', data: {
      'amount': amount,
      'description': description,
    });
  }

  // ===== Notices =====
  Future<List<Notice>> getNotices({int skip = 0, int limit = 20}) async {
    final response = await _dio.get('/notices', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    return (response.data as List)
        .map((e) => Notice.fromJson(e))
        .toList();
  }

  // ===== Forum =====
  Future<List<Post>> getPosts({int skip = 0, int limit = 20, int? tagId}) async {
    final response = await _dio.get('/forum/posts', queryParameters: {
      'skip': skip,
      'limit': limit,
      if (tagId != null) 'tag_id': tagId,
    });
    return (response.data as List)
        .map((e) => Post.fromJson(e))
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
    return Post.fromJson(response.data);
  }

  Future<List<Comment>> getComments(int postId) async {
    final response = await _dio.get('/forum/posts/$postId/comments');
    return (response.data as List)
        .map((e) => Comment.fromJson(e))
        .toList();
  }

  Future<void> createComment(int postId, String content) async {
    await _dio.post('/forum/posts/$postId/comments', data: {
      'post_id': postId,
      'content': content,
    });
  }

  Future<List<Tag>> getTags() async {
    final response = await _dio.get('/forum/tags');
    return (response.data as List)
        .map((e) => Tag.fromJson(e))
        .toList();
  }
}
