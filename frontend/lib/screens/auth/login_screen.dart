import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authProvider.notifier).login(
      _usernameController.text,
      _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        context.go('/home');
      } else {
        final authState = ref.read(authProvider);
        setState(() {
          _errorMessage = authState.errorMessage ?? '用户名或密码错误';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final providerError = authState.errorMessage;

    return Scaffold(
      body: Stack(
        children: [
          // 海洋渐变背景（全屏）
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(AppConstants.deepOcean),
                  Color(AppConstants.midnightBlue),
                  Color(0xFF0D1F35),
                ],
              ),
            ),
          ),

          // 动态波浪背景
          _buildWaveBackground(),

          // 漂浮粒子效果
          _buildFloatingParticles(),

          // 左右分栏主内容
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Row(
                children: [
                  // 左侧区域：澳门大学品牌形象
                  Expanded(
                    flex: 1,
                    child: _buildLeftBrandSection(),
                  ),
                  // 右侧区域：登录表单
                  Expanded(
                    flex: 1,
                    child: _buildRightLoginSection(providerError),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBackground() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 200),
            painter: WavePainter(
              animationValue: _waveAnimation.value,
              color: const Color(AppConstants.tealAzure).withValues(alpha: 0.15),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return Stack(
      children: List.generate(5, (index) {
        return Positioned(
          top: 50 + (index * 120).toDouble(),
          left: 20 + (index * 80).toDouble(),
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              final offset = Offset(
                0,
                10 * (_waveAnimation.value + index * 0.2),
              );
              return Transform.translate(
                offset: offset,
                child: Opacity(
                  opacity: 0.3 + (index * 0.1),
                  child: Icon(
                    index % 2 == 0 ? Icons.sailing : Icons.waves,
                    color: const Color(AppConstants.tealAzure),
                    size: 24 - (index * 3).toDouble(),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildLeftBrandSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // UM校徽图标
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.school,
                size: 60,
                color: Color(AppConstants.coralGold),
              ),
            ),
            const SizedBox(height: 40),

            // UM LOGO 文字
            Text(
              'UM',
              style: GoogleFonts.playfairDisplay(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 8,
              ),
            ),
            Text(
              'LOGO',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: const Color(AppConstants.coralGold),
                letterSpacing: 12,
              ),
            ),
            const SizedBox(height: 40),

            // University of Macau 英文
            Text(
              'University of Macau',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),

            // 澳门大学 中文
            Text(
              '澳门大学',
              style: GoogleFonts.notoSansSc(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),

            // 葡文名称
            Text(
              'Universidade de Macau',
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Colors.white.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightLoginSection(String? providerError) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(36),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 欢迎标题
                const Text(
                  '欢迎回来',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请登录您的账户',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 36),

                // 错误消息
                if (providerError != null || _errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(AppConstants.errorRed).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(AppConstants.errorRed).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(AppConstants.errorRed),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            providerError ?? _errorMessage!,
                            style: const TextStyle(
                              color: Color(AppConstants.errorRed),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: 0),

                if (providerError != null || _errorMessage != null)
                  const SizedBox(height: 24)
                else
                  const SizedBox(height: 16),

                // 用户名输入框
                _buildTextField(
                  controller: _usernameController,
                  label: '用户名',
                  icon: Icons.person_outline,
                  hint: '请输入用户名',
                ),
                const SizedBox(height: 20),

                // 密码输入框
                _buildTextField(
                  controller: _passwordController,
                  label: '密码',
                  icon: Icons.lock_outline_rounded,
                  hint: '请输入密码',
                  isPassword: true,
                ),
                const SizedBox(height: 32),

                // 登录按钮
                _buildLoginButton(),
                const SizedBox(height: 24),

                // 注册链接
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color(AppConstants.tealAzure),
                size: 22,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(AppConstants.tealAzure),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入$label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.coralGold),
          foregroundColor: const Color(AppConstants.deepOcean),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(AppConstants.deepOcean),
                  ),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_boat,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '启航',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: '还没有账户？',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          children: [
            const TextSpan(text: ' '),
            TextSpan(
              text: '立即注册',
              style: const TextStyle(
                color: Color(AppConstants.coralGold),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  context.push('/register');
                },
            ),
            const TextSpan(text: ' '),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.rocket_launch,
                size: 16,
                color: Color(AppConstants.coralGold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 自定义波浪画家
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // 第一层波浪
    path.moveTo(0, size.height * 0.7);
    for (double i = 0; i <= size.width; i += 10) {
      final y = size.height * 0.7 +
          15 * (1 + animationValue) * (i / size.width) * (1 - i / size.width) +
          10 * (i / size.width);
      path.lineTo(i, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // 第二层波浪（偏移）
    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    for (double i = 0; i <= size.width; i += 10) {
      final y = size.height * 0.75 +
          12 * (1 - animationValue + 0.5) * (i / size.width) * (1 - i / size.width) +
          8 * (1 - i / size.width);
      path2.lineTo(i, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
