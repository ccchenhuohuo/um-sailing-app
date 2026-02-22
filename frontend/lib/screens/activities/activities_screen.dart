import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/activity.dart';
import '../../models/activity_signup.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../widgets/ocean/ocean_background.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.whiteCardTheme,
      child: OceanBackground(
        enableWave: true,
        enableParticles: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event, color: Color(0xFF1E8C93)),
                SizedBox(width: 10),
                Text(
                  '活动管理',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            bottom: const TabBar(
              labelColor: Color(0xFF1E8C93),
              unselectedLabelColor: Colors.black54,
              indicatorColor: Color(0xFFE8B84A),
              tabs: [
                Tab(text: '即将开始'),
                Tab(text: '已结束'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ActivitiesListPage(upcoming: true),
              ActivitiesListPage(upcoming: false),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFE8B84A),
            foregroundColor: const Color(0xFF0A1628),
            onPressed: () => _showCreateActivityDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showCreateActivityDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateActivitySheet(),
    );
  }
}

class ActivitiesListPage extends StatefulWidget {
  final bool upcoming;

  const ActivitiesListPage({super.key, required this.upcoming});

  @override
  State<ActivitiesListPage> createState() => _ActivitiesListPageState();
}

class _ActivitiesListPageState extends State<ActivitiesListPage> {
  final _apiService = ApiService();
  late Future<List<Activity>> _activitiesFuture;
  List<ActivitySignup>? _signups;
  List<Activity>? _filteredActivities;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _activitiesFuture = _apiService.getActivities();
    // 直接在主 isolate 过滤，不需要 compute
    _activitiesFuture.then((activities) {
      final now = DateTime.now();
      final filtered = widget.upcoming
          ? activities.where((a) => a.startTime.isAfter(now)).toList()
          : activities.where((a) => a.endTime.isBefore(now)).toList();
      if (mounted) {
        setState(() {
          _filteredActivities = filtered;
        });
      }
    });
    // 预加载报名状态
    try {
      final signups = await _apiService.getMyActivitySignups();
      if (mounted) {
        setState(() {
          _signups = signups;
        });
      }
    } catch (e) {
      debugPrint('加载报名状态失败: $e');
    }
  }

  bool _isSignedUp(int activityId) {
    if (_signups == null) return false;
    return _signups!.any((s) => s.activityId == activityId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Activity>>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1E8C93)));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  '加载失败: ${snapshot.error}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _loadData()),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        final activities = snapshot.data ?? [];
        // 使用缓存的过滤结果，避免每次 build 都执行过滤
        final filtered = _filteredActivities ??
            (widget.upcoming
                ? activities.where((a) => a.startTime.isAfter(DateTime.now())).toList()
                : activities.where((a) => a.endTime.isBefore(DateTime.now())).toList());

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.black26),
                const SizedBox(height: 16),
                Text(
                  widget.upcoming ? '暂无即将开始的活动' : '暂无已结束的活动',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final activity = filtered[index];
            final now = DateTime.now();
            final isEnded = activity.endTime.isBefore(now);
            return ActivityCard(
              activity: activity,
              isSignedUp: _isSignedUp(activity.id),
              isEnded: isEnded,
              onSignupSuccess: _loadData,
              apiService: _apiService,
            );
          },
        );
      },
    );
  }
}

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final bool isSignedUp;
  final bool isEnded;
  final VoidCallback? onSignupSuccess;
  final ApiService? apiService;

  const ActivityCard({
    super.key,
    required this.activity,
    this.isSignedUp = false,
    this.isEnded = false,
    this.onSignupSuccess,
    this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.push('/activity/${activity.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              _getStatusBadge(),
            ],
          ),
          if (activity.description != null) ...[
            const SizedBox(height: 8),
            Text(
              activity.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E8C93).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.location_on, size: 14, color: Color(0xFF1E8C93)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  activity.location ?? '未指定地点',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B84A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.access_time, size: 14, color: Color(0xFFE8B84A)),
              ),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('MM-dd HH:mm').format(activity.startTime)} - ${DateFormat('MM-dd HH:mm').format(activity.endTime)}',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (activity.maxParticipants > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E8C93).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '限 ${activity.maxParticipants} 人',
                    style: const TextStyle(color: Color(0xFF1E8C93), fontSize: 12),
                  ),
                ),
              _buildSignupButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getStatusBadge() {
    final now = DateTime.now();
    if (now.isBefore(activity.startTime)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E8C93).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '报名中',
          style: TextStyle(color: Color(0xFF1E8C93), fontSize: 12, fontWeight: FontWeight.w500),
        ),
      );
    } else if (now.isBefore(activity.endTime)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '进行中',
          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '已结束',
          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      );
    }
  }

  void _handleSignup(BuildContext context) async {
    final service = apiService ?? ApiService();
    try {
      await service.signupActivity(activity.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('报名成功！')),
        );
        // 通知父组件刷新状态
        onSignupSuccess?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('报名失败: $e')),
        );
      }
    }
  }

  Widget _buildSignupButton(BuildContext context) {
    // 活动已结束，禁用按钮
    if (isEnded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '已结束',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      );
    }

    // 已报名，显示不同样式
    if (isSignedUp) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: Colors.green),
            SizedBox(width: 4),
            Text(
              '已报名',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    // 未报名，可点击
    return ElevatedButton(
      onPressed: () => _handleSignup(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE8B84A),
        foregroundColor: const Color(0xFF0A1628),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('报名'),
    );
  }
}

class CreateActivitySheet extends StatefulWidget {
  const CreateActivitySheet({super.key});

  @override
  State<CreateActivitySheet> createState() => _CreateActivitySheetState();
}

class _CreateActivitySheetState extends State<CreateActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  final _maxParticipantsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '创建活动',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _titleController,
                label: '活动标题',
                icon: Icons.title,
                validator: (value) => value?.isEmpty == true ? '请输入标题' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: '活动描述',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: '活动地点',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeButton(
                      text: _startTime == null ? '开始时间' : DateFormat('MM-dd HH:mm').format(_startTime!),
                      icon: Icons.access_time,
                      onTap: () => _selectDateTime(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeButton(
                      text: _endTime == null ? '结束时间' : DateFormat('MM-dd HH:mm').format(_endTime!),
                      icon: Icons.access_time,
                      onTap: () => _selectDateTime(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _maxParticipantsController,
                label: '最大参与人数（0表示不限）',
                icon: Icons.people,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8B84A),
                  foregroundColor: const Color(0xFF0A1628),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                child: const Text('创建活动', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(icon, color: const Color(0xFF1E8C93)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E8C93), width: 2),
        ),
      ),
    );
  }

  Widget _buildTimeButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black26),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1E8C93), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = dateTime;
      } else {
        _endTime = dateTime;
      }
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择开始和结束时间')),
        );
        return;
      }

      // 验证结束时间必须晚于开始时间
      if (_endTime!.isBefore(_startTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('结束时间必须晚于开始时间')),
        );
        return;
      }

      try {
        await ApiService().createActivity(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          location: _locationController.text.isEmpty ? null : _locationController.text,
          startTime: _startTime!,
          endTime: _endTime!,
          maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 0,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('活动创建成功')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }
}
