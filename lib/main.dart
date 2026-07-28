import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import 'home.dart';
import 'table.dart';
import 'profile.dart';

/// 应用入口与路由配置。
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: 'home', builder: (context, state) => const Home()),
    GoRoute(path: 'table', builder: (context, state) => const TablePage()),
    GoRoute(path: 'profile', builder: (context, state) => const Profile()),
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
