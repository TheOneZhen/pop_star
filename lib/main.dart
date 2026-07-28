import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/navigation/page_transitions.dart';
import 'core/theme/app_theme.dart';
import 'features/game/game_screen.dart';
import 'features/home/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';

/// 应用入口与路由配置。
/// 使用 go_router 管理启动页、首页、游戏、设置及页面切换动画。
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return PageTransitions.fadeScale(
          key: state.pageKey,
          child: const HomePage(),
        );
      },
    ),
    GoRoute(
      path: '/game',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return PageTransitions.fadeSlideUp(
          key: state.pageKey,
          child: const GameScreen(continueGame: false),
        );
      },
    ),
    GoRoute(
      path: '/game/continue',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return PageTransitions.fadeSlideUp(
          key: state.pageKey,
          child: const GameScreen(continueGame: true),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return PageTransitions.slideFromRight(
          key: state.pageKey,
          child: const SettingsScreen(),
        );
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
