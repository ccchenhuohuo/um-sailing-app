import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ocean/ocean_background.dart';
import 'package:flutter/scheduler.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  bool _hasNavigated = false;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 淡入动画控制器
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // 缩放动画控制器
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // 开始动画
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _scaleController.forward();
    });

    // 延迟后检查认证
    Future.delayed(const Duration(milliseconds: 1500), () {
      _checkAndNavigate();
    });
  }

  void _checkAndNavigate() {
    if (_hasNavigated) return;

    final state = ref.read(authProvider);
    if (!state.isLoading) {
      _hasNavigated = true;
      if (state.isAuthenticated) {
        if (mounted) context.go('/home');
      } else {
        if (mounted) context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听认证状态变化
    ref.listen(authProvider, (previous, next) {
      if (!next.isLoading && !_hasNavigated) {
        _hasNavigated = true;
        if (next.isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    });

    return OceanBackground(
      enableWave: true,
      enableParticles: true,
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B84A).withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // UM 校徽区域
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE8B84A),
                width: 3,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A1628),
                  Color(0xFF15203B),
                ],
              ),
            ),
            child: const Icon(
              Icons.school,
              size: 60,
              color: Color(0xFFE8B84A),
            ),
          ),
          const SizedBox(height: 30),

          // 主标题
          const Text(
            'UMA',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A1628),
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 8),

          // 英文名称
          const Text(
            'University of Macau',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),

          // 中文名称
          const Text(
            '澳门大学帆船协会',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0A1628),
            ),
          ),
          const SizedBox(height: 6),

          // 葡萄牙语名称
          const Text(
            'Associação de Vela da UM',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black45,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 40),

          // 加载指示器
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Color(0xFF1E8C93),
              strokeWidth: 3,
            ),
          ),
        ],
      ),
    );
  }
}
