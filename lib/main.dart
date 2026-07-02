import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/game/game_screen.dart';
import 'features/game/result_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/game', builder: (context, state) => GameScreen()),
    GoRoute(
      path: '/game/result',
      builder: (context, state) => ResultScreen(score: 0),
    ), // TODO: 将分数保存在游戏状态中并传递分数
  ],
);

void main() {
  runApp(const PopStarApp());
}

class PopStarApp extends StatelessWidget {
  const PopStarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '消灭星星',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
