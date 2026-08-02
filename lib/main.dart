import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'home.dart';
import 'main_shell.dart';
import 'profile.dart';
import 'table.dart';
import 'theme.dart';

/// 应用入口与路由配置。
/// ShellRoute 统一承载液态玻璃底部菜单，三个 Tab 共享外壳。
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) {
            return const Home();
          },
        ),
        GoRoute(
          path: '/table',
          builder: (BuildContext context, GoRouterState state) {
            return const TablePage();
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const Profile();
          },
        ),
      ],
    ),
  ],
);

void main() {
  runApp(const ProviderScope(child: PopStarApp()));
}

/// 根 Widget：配置主题与路由。
class PopStarApp extends StatelessWidget {
  const PopStarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'app',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
