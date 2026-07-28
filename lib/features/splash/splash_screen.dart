import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../home/home_screen.dart';

/// 应用启动页：Logo 缩放、标题淡入、装饰星星动画。
/// 动画结束后自动跳转首页；点击屏幕可跳过。
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _starController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _starRotation;

  bool _navigated = false;
  final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _mainController.addStatusListener(_onMainAnimationStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainController.forward();
      _starController.repeat();
    });
  }

  void _initAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.splashAnimationMs),
    );
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );
    _titleSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _starRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _starController,
    );
  }

  void _onMainAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goHome();
    }
  }

  Future<void> _goHome() async {
    if (_navigated) {
      return;
    }

    final int elapsed = DateTime.now().difference(_startTime).inMilliseconds;
    final int remaining = AppConstants.splashMinDisplayMs - elapsed;
    if (remaining > 0) {
      await Future<void>.delayed(Duration(milliseconds: remaining));
    }

    if (!mounted) {
      return;
    }
    if (_navigated) {
      return;
    }

    _navigated = true;
    context.go('/home');
  }

  void _onTapSkip() {
    _goHome();
  }

  @override
  void dispose() {
    _mainController.removeStatusListener(_onMainAnimationStatus);
    _mainController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapSkip,
      child: Scaffold(
        body: Container(
          decoration: AppBackground.decoration,
          child: AnimatedBuilder(
            animation: Listenable.merge([_mainController, _starController]),
            builder: (BuildContext context, Widget? child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  ..._buildDecorStars(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: _buildLogo(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Transform.translate(
                        offset: Offset(0, _titleSlide.value),
                        child: Opacity(
                          opacity: _titleOpacity.value,
                          child: Text(
                            '消灭星星',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: _titleOpacity.value * 0.7,
                        child: const Text(
                          '点击屏幕跳过',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD54F), Color(0xFFFF6F00)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.5),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(Icons.star, color: Colors.white, size: 56),
    );
  }

  List<Widget> _buildDecorStars() {
    final List<Widget> stars = [];
    final List<_StarDecor> decors = [
      _StarDecor(left: 40, top: 120, size: 20, color: Colors.redAccent),
      _StarDecor(right: 50, top: 180, size: 16, color: Colors.lightBlueAccent),
      _StarDecor(left: 80, bottom: 200, size: 14, color: Colors.greenAccent),
      _StarDecor(right: 70, bottom: 160, size: 22, color: Colors.purpleAccent),
      _StarDecor(left: 30, top: 300, size: 12, color: Colors.yellowAccent),
      _StarDecor(right: 40, top: 350, size: 18, color: Colors.orangeAccent),
    ];

    for (int i = 0; i < decors.length; i = i + 1) {
      final _StarDecor decor = decors[i];
      final double angle = _starRotation.value * 3.14159 * 2 + i * 0.8;
      final double pulse = 0.8 + 0.2 * ((angle % 1.0));

      Widget star = Icon(
        Icons.star,
        color: decor.color.withValues(alpha: 0.7),
        size: decor.size * pulse,
      );
      star = Transform.rotate(angle: angle, child: star);

      if (decor.left != null) {
        stars.add(Positioned(left: decor.left, top: decor.top, child: star));
      } else {
        stars.add(Positioned(right: decor.right, top: decor.top, child: star));
      }
    }

    return stars;
  }
}

class _StarDecor {
  const _StarDecor({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
    required this.color,
  });

  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double size;
  final Color color;
}
