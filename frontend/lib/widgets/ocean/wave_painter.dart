import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 波浪动画画家
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;
  final double opacity;

  WavePainter({
    required this.animationValue,
    this.waveColor = const Color(0xFF1E8C93),
    this.opacity = 0.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // 第一层波浪
    _drawWave(canvas, paint, size, animationValue, 0.5, 0.8);

    // 第二层波浪（不同相位）
    final paint2 = Paint()
      ..color = waveColor.withValues(alpha: opacity * 0.6)
      ..style = PaintingStyle.fill;
    _drawWave(canvas, paint2, size, animationValue + 1.5, 0.6, 1.2);

    // 第三层波浪（更淡）
    final paint3 = Paint()
      ..color = waveColor.withValues(alpha: opacity * 0.4)
      ..style = PaintingStyle.fill;
    _drawWave(canvas, paint3, size, animationValue + 3.0, 0.7, 1.0);
  }

  void _drawWave(
    Canvas canvas,
    Paint paint,
    Size size,
    double animation,
    double amplitudeFactor,
    double frequencyFactor,
  ) {
    final path = Path();

    final width = size.width;
    final height = size.height;
    final baseHeight = height * 0.75;

    path.moveTo(0, height);
    path.lineTo(0, baseHeight);

    // 绘制正弦波浪
    for (double x = 0; x <= width; x += 5) {
      final normalizedX = x / width;
      final angle = normalizedX * frequencyFactor * 2 * pi + animation;
      final y = baseHeight + sin(angle) * 20 * amplitudeFactor;
      path.lineTo(x, y);
    }

    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// 波浪动画控制器
class WaveAnimationWidget extends StatefulWidget {
  final Widget child;
  final Color waveColor;
  final double opacity;
  final bool enableWave;

  const WaveAnimationWidget({
    super.key,
    required this.child,
    this.waveColor = const Color(0xFF1E8C93),
    this.opacity = 0.3,
    this.enableWave = true,
  });

  @override
  State<WaveAnimationWidget> createState() => _WaveAnimationWidgetState();
}

class _WaveAnimationWidgetState extends State<WaveAnimationWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker((elapsed) {
      if (mounted) {
        setState(() {
          _animationValue = elapsed.inMilliseconds / 1000.0;
        });
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.enableWave)
          Positioned.fill(
            bottom: 0,
            child: CustomPaint(
              painter: WavePainter(
                animationValue: _animationValue,
                waveColor: widget.waveColor,
                opacity: widget.opacity,
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}

/// 粒子效果类型
enum ParticleType { sailboat, wave, bubble }

/// 漂浮粒子数据
class FloatingParticle {
  final ParticleType type;
  Offset position;
  final double size;
  final double speed;
  final double opacity;
  final String? icon;

  FloatingParticle({
    required this.type,
    required this.position,
    required this.size,
    required this.speed,
    required this.opacity,
    this.icon,
  });
}

/// 漂浮粒子动画组件
class FloatingParticlesWidget extends StatefulWidget {
  final Widget child;
  final List<ParticleType> particleTypes;
  final int particleCount;
  final Color particleColor;

  const FloatingParticlesWidget({
    super.key,
    required this.child,
    this.particleTypes = const [ParticleType.sailboat, ParticleType.wave],
    this.particleCount = 8,
    this.particleColor = const Color(0xFFE8B84A),
  });

  @override
  State<FloatingParticlesWidget> createState() => _FloatingParticlesWidgetState();
}

class _FloatingParticlesWidgetState extends State<FloatingParticlesWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final Random _random = Random();
  List<FloatingParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initParticles();
    _ticker = Ticker((elapsed) {
      _updateParticles(elapsed);
    });
    _ticker.start();
  }

  void _initParticles() {
    _particles = List.generate(
      widget.particleCount,
      (index) => FloatingParticle(
        type: widget.particleTypes[index % widget.particleTypes.length],
        position: Offset(
          _random.nextDouble() * 400 + 50,
          _random.nextDouble() * 800 + 50,
        ),
        size: _random.nextDouble() * 30 + 20,
        speed: _random.nextDouble() * 30 + 20,
        opacity: _random.nextDouble() * 0.3 + 0.1,
      ),
    );
  }

  void _updateParticles(Duration elapsed) {
    if (!mounted) return;

    final duration = elapsed.inMilliseconds / 1000.0;
    setState(() {
      for (var particle in _particles) {
        // 向上漂浮
        final newY = particle.position.dy - particle.speed * 0.01;
        // 轻微左右摆动
        final swing = sin(duration * 2 + particle.position.dy) * 0.5;
        final newX = particle.position.dx + swing;

        // 如果超出顶部，重置到底部
        if (newY < -50) {
          particle.position = Offset(
            _random.nextDouble() * 400 + 50,
            900.0 + _random.nextDouble() * 100,
          );
        } else {
          particle.position = Offset(newX, newY);
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ..._particles.map((particle) => _buildParticle(particle)),
        widget.child,
      ],
    );
  }

  Widget _buildParticle(FloatingParticle particle) {
    IconData iconData;
    switch (particle.type) {
      case ParticleType.sailboat:
        iconData = Icons.sailing;
      case ParticleType.wave:
        iconData = Icons.waves;
      case ParticleType.bubble:
        iconData = Icons.bubble_chart;
    }

    return Positioned(
      left: particle.position.dx,
      top: particle.position.dy,
      child: Opacity(
        opacity: particle.opacity,
        child: Icon(
          iconData,
          size: particle.size,
          color: widget.particleColor,
        ),
      ),
    );
  }
}
