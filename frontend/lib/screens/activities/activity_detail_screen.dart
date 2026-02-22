import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/activity.dart';
import '../../models/activity_signup.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../widgets/ocean/ocean_background.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final int activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  ConsumerState<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  final _apiService = ApiService();
  late Future<Activity> _activityFuture;
  ActivitySignup? _signup;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _activityFuture = _apiService.getActivity(widget.activityId);
    // 预加载活动数据以确保它可用
    await _activityFuture;
    final signup = await _apiService.getSignupStatus(widget.activityId);
    if (mounted) {
      setState(() {
        _signup = signup;
      });
    }
  }

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
                Text('活动详情', style: TextStyle(color: Colors.black)),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: FutureBuilder<Activity>(
            future: _activityFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1E8C93)),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        '加载失败，请稍后重试',
                        style: const TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final activity = snapshot.data!;
              return _buildContent(activity);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Activity activity) {
    final now = DateTime.now();
    final isUpcoming = now.isBefore(activity.startTime);
    final isOngoing = now.isAfter(activity.startTime) && now.isBefore(activity.endTime);
    final isEnded = now.isAfter(activity.endTime);

    String statusText;
    Color statusColor;
    if (isUpcoming) {
      statusText = '未开始';
      statusColor = Colors.blue;
    } else if (isOngoing) {
      statusText = '进行中';
      statusColor = const Color(0xFF1E8C93);
    } else {
      statusText = '已结束';
      statusColor = Colors.grey;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WhiteCard(
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (activity.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    activity.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          WhiteCard(
            child: Column(
              children: [
                _buildInfoRow(Icons.location_on, '地点', activity.location ?? '未指定'),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.access_time,
                  '开始时间',
                  DateFormat('yyyy-MM-dd HH:mm').format(activity.startTime),
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.access_time_filled,
                  '结束时间',
                  DateFormat('yyyy-MM-dd HH:mm').format(activity.endTime),
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.people,
                  '最大人数',
                  activity.maxParticipants > 0 ? '${activity.maxParticipants} 人' : '不限',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (!isEnded) _buildActionButtons(activity, isOngoing),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E8C93).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1E8C93), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(Activity activity, bool isOngoing) {
    if (_signup == null) {
      // 未报名 - 显示报名按钮
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8B84A),
          foregroundColor: const Color(0xFF0A1628),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isLoading ? null : () => _handleSignup(activity.id),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A1628)),
              )
            : const Text('立即报名', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      );
    } else {
      // 已报名 - 显示取消报名和签到按钮
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 签到按钮 - 仅在活动进行中且未签到时显示
          if (isOngoing && !_signup!.checkedIn)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8C93),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : () => _handleCheckin(activity.id),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('签到', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          // 取消报名按钮
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isLoading ? null : () => _handleCancelSignup(activity.id),
            child: const Text('取消报名', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    }
  }

  Future<void> _handleSignup(int activityId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.signupActivity(activityId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('报名成功')),
        );
        // 刷新数据
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('报名失败，请稍后重试')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCheckin(int activityId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.checkinActivity(activityId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('签到成功')),
        );
        // 刷新数据
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('签到失败，请稍后重试')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCancelSignup(int activityId) async {
    // 确认取消报名
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消报名'),
        content: const Text('确定要取消报名吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.cancelSignup(activityId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已取消报名')),
        );
        // 刷新数据
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('取消报名失败，请稍后重试')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
