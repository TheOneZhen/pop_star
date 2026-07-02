import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/game/game_screen.dart';
import 'features/home/home_screen.dart';
import 'features/settings/settings_screen.dart';

/// 应用入口与路由配置。
/// 使用 go_router 管理首页、新游戏、继续游戏与设置页跳转。
final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/game',
      builder: (BuildContext context, GoRouterState state) {
        return const GameScreen(continueGame: false);
      },
    ),
    GoRoute(
      path: '/game/continue',
      builder: (BuildContext context, GoRouterState state) {
        return const GameScreen(continueGame: true);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsScreen();
      },
    ),
  ],
);

void main() {
  runApp(
    const ProviderScope(
      child: PopStarApp(),
    ),
  );
}

/// 根 Widget：配置主题与路由。
class PopStarApp extends StatelessWidget {
  const PopStarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '消灭星星',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
