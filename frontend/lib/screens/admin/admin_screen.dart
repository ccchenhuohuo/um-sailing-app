import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../widgets/ocean/ocean_background.dart';

import 'users_tab.dart';
import 'finance_tab.dart';
import 'boats_tab.dart';
import 'activities_tab.dart';
import 'notices_tab.dart';
import 'stats_tab.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user?.isAdmin != true) {
      return Theme(
        data: AppTheme.whiteCardTheme,
        child: Scaffold(
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings, color: Color(0xFF1E8C93)),
                SizedBox(width: 10),
                Text(
                  '管理员后台',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          body: Center(
            child: WhiteCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.block,
                      size: 64,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '权限不足',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '您没有管理员权限访问此页面',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                Icon(Icons.admin_panel_settings, color: Color(0xFF1E8C93)),
                SizedBox(width: 10),
                Text(
                  '管理员后台',
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
              isScrollable: true,
              tabs: [
                Tab(text: '用户'),
                Tab(text: '财务'),
                Tab(text: '船只'),
                Tab(text: '活动'),
                Tab(text: '公告'),
                Tab(text: '统计'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              UsersTab(),
              FinanceTab(),
              BoatsTab(),
              ActivitiesTab(),
              NoticesTab(),
              StatsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
