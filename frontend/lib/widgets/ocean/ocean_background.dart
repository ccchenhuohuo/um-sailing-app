import 'dart:math';
import 'package:flutter/material.dart';
import 'wave_painter.dart';

/// 海洋渐变背景组件
class OceanBackground extends StatefulWidget {
  final Widget child;
  final bool enableWave;
  final bool enableParticles;
  final List<ParticleType> particleTypes;
  final int particleCount;
  final Color? waveColor;
  final double? waveOpacity;

  const OceanBackground({
    super.key,
    required this.child,
    this.enableWave = true,
    this.enableParticles = false,
    this.particleTypes = const [ParticleType.sailboat, ParticleType.wave],
    this.particleCount = 6,
    this.waveColor,
    this.waveOpacity,
  });

  @override
  State<OceanBackground> createState() => _OceanBackgroundState();
}

class _OceanBackgroundState extends State<OceanBackground> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();

    // 波浪动画控制器
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // 渐变动画控制器
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1628), // 深蓝
            Color(0xFF15203B), // 中蓝
            Color(0xFF0D1F35), // 浅蓝
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 波浪效果
          if (widget.enableWave)
            Positioned.fill(
              bottom: 0,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WavePainter(
                      animationValue: _waveController.value * 2 * 3.14159,
                      waveColor: widget.waveColor ?? const Color(0xFF1E8C93),
                      opacity: widget.waveOpacity ?? 0.3,
                    ),
                  );
                },
              ),
            ),

          // 漂浮粒子效果
          if (widget.enableParticles)
            FloatingParticlesWidget(
              child: const SizedBox.shrink(),
              particleTypes: widget.particleTypes,
              particleCount: widget.particleCount,
            ),

          // 主内容
          widget.child,
        ],
      ),
    );
  }
}

/// 白色卡片容器
class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const WhiteCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation = 2,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: cardContent,
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: cardContent);
    }

    return cardContent;
  }
}

/// 登录/注册分栏布局左侧品牌区域
class BrandSection extends StatelessWidget {
  final double screenWidth;
  final bool isDarkMode;

  const BrandSection({
    super.key,
    required this.screenWidth,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.4,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1628),
            Color(0xFF15203B),
            Color(0xFF0D1F35),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 背景波浪
          Positioned.fill(
            child: CustomPaint(
              painter: WavePainter(
                animationValue: 0,
                waveColor: const Color(0xFF1E8C93),
                opacity: 0.2,
              ),
            ),
          ),
          // 中心内容
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // UM Logo 占位
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE8B84A),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 60,
                    color: Color(0xFFE8B84A),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'UMA',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'University of Macau',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sailing Association',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFE8B84A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '澳门大学帆船协会',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Associação de Vela da UM',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 表单卡片容器
class FormCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsets? padding;

  const FormCard({
    super.key,
    required this.child,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: width ?? min(screenWidth * 0.45, 450),
 padding: padding ?? const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// 海洋主题按钮
class OceanButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;

  const OceanButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.width,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFFE8B84A),
          foregroundColor: textColor ?? const Color(0xFF0A1628),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF0A1628),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 海洋主题输入框
class OceanTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const OceanTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black54),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF1E8C93))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1E8C93),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 内容区域卡片
class ContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const ContentCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

/// 标题栏
class PageTitle extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const PageTitle({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
