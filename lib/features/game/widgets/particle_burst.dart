import 'dart:math';

import 'package:flutter/material.dart';

import '../models/star_color.dart';

/// 消除粒子爆发特效：CustomPainter + Ticker 驱动短促飞散动画。
class ParticleBurst extends StatefulWidget {
  const ParticleBurst({
    super.key,
    required this.color,
    required this.center,
    required this.onFinished,
  });

  final StarColor color;
  final Offset center;
  final VoidCallback onFinished;

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = _createParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.addStatusListener(_onStatusChanged);
    _controller.forward();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onFinished();
    }
  }

  List<_Particle> _createParticles() {
    final List<_Particle> result = [];
    final Color baseColor = widget.color.toColor();
    const int count = 14;

    for (int i = 0; i < count; i = i + 1) {
      final double angle = _random.nextDouble() * pi * 2;
      final double speed = 30 + _random.nextDouble() * 50;
      result.add(
        _Particle(
          angle: angle,
          speed: speed,
          size: 4 + _random.nextDouble() * 4,
          color: baseColor,
        ),
      );
    }
    return result;
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: _ParticlePainter(
            progress: _controller.value,
            particles: _particles,
            center: widget.center,
          ),
        );
      },
    );
  }
}

class _Particle {
  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });

  final double angle;
  final double speed;
  final double size;
  final Color color;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.progress,
    required this.particles,
    required this.center,
  });

  final double progress;
  final List<_Particle> particles;
  final Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i = i + 1) {
      final _Particle particle = particles[i];
      final double distance = particle.speed * progress;
      final double dx = cos(particle.angle) * distance;
      final double dy = sin(particle.angle) * distance;
      final double opacity = 1.0 - progress;

      final Paint paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(center.dx + dx, center.dy + dy),
        particle.size * (1.0 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
