import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/profile/profile_edit_screen.dart';
import 'screens/profile/my_activities_screen.dart';
import 'screens/profile/my_rentals_screen.dart';
import 'screens/profile/transaction_history_screen.dart';
import 'screens/activities/activity_detail_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 等待加载完成
    if (authState.isLoading) {
      return MaterialApp(
        title: 'UMA Sailing App',
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // 初始化时先显示 splash
    return MaterialApp.router(
      title: 'UMA Sailing App',
      theme: AppTheme.lightTheme,
      routerConfig: GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(
            path: '/splash',
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminScreen(),
          ),
          GoRoute(
            path: '/profile/edit',
            builder: (context, state) => const ProfileEditScreen(),
          ),
          GoRoute(
            path: '/my/activities',
            builder: (context, state) => const MyActivitiesScreen(),
          ),
          GoRoute(
            path: '/my/rentals',
            builder: (context, state) => const MyRentalsScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionHistoryScreen(),
          ),
          GoRoute(
            path: '/activity/:id',
            builder: (context, state) {
              final idParam = state.pathParameters['id'];
              final activityId = int.tryParse(idParam ?? '');
              if (activityId == null || activityId <= 0) {
                return const Scaffold(
                  body: Center(child: Text('无效的活动ID')),
                );
              }
              return ActivityDetailScreen(activityId: activityId);
            },
          ),
        ],
      ),
    );
  }
}
