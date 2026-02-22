import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/activity_signup.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../widgets/ocean/ocean_background.dart';

class MyActivitiesScreen extends ConsumerStatefulWidget {
  const MyActivitiesScreen({super.key});

  @override
  ConsumerState<MyActivitiesScreen> createState() => _MyActivitiesScreenState();
}

class _MyActivitiesScreenState extends ConsumerState<MyActivitiesScreen> {
  final _apiService = ApiService();
  late Future<List<ActivitySignup>> _signupsFuture;

  @override
  void initState() {
    super.initState();
    _loadSignups();
  }

  void _loadSignups() {
    _signupsFuture = _apiService.getMyActivitySignups();
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
                Text('我的活动', style: TextStyle(color: Colors.black)),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: FutureBuilder<List<ActivitySignup>>(
            future: _signupsFuture,
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
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadSignups();
                          });
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }

              final signups = snapshot.data ?? [];
              if (signups.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.black26),
                      const SizedBox(height: 16),
                      const Text(
                        '暂无报名活动',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final future = _apiService.getMyActivitySignups();
                  setState(() {
                    _signupsFuture = future;
                  });
                  await future;
                },
                color: const Color(0xFF1E8C93),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: signups.length,
                  itemBuilder: (context, index) {
                    final signup = signups[index];
                    return _buildSignupCard(signup);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignupCard(ActivitySignup signup) {
    final activity = signup.activity;
    final statusColor = _getStatusColor(signup.activityStatus);
    final statusText = signup.activityStatus;
    final checkedIn = signup.checkedIn;

    return WhiteCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和状态
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activity?.title ?? '未知活动',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 活动详情
          if (activity?.description != null)
            Text(
              activity!.description!,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 12),

          // 时间和地点
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.black38),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  activity?.location ?? '未指定',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.black38),
              const SizedBox(width: 4),
              Text(
                activity != null
                    ? '${DateFormat('MM-dd HH:mm').format(activity.startTime)} - ${DateFormat('MM-dd HH:mm').format(activity.endTime)}'
                    : '未知时间',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 报名信息和签到状态
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.black38),
                  const SizedBox(width: 4),
                  Text(
                    '报名时间: ${DateFormat('yyyy-MM-dd HH:mm').format(signup.signupTime)}',
                    style: const TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: checkedIn ? const Color(0xFF4CAF50).withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      checkedIn ? Icons.check_circle : Icons.pending,
                      size: 14,
                      color: checkedIn ? const Color(0xFF4CAF50) : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      checkedIn ? '已签到' : '未签到',
                      style: TextStyle(
                        color: checkedIn ? const Color(0xFF4CAF50) : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 签到按钮
          if (signup.canCheckin) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8C93),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _checkin(signup),
                child: const Text('立即签到'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '进行中':
        return const Color(0xFF1E8C93);
      case '未开始':
        return Colors.blue;
      case '已结束':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _checkin(ActivitySignup signup) async {
    try {
      await _apiService.checkinActivity(signup.activityId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('签到成功')),
        );
        setState(() {
          _loadSignups();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('签到失败，请稍后重试')),
        );
      }
    }
  }
}
