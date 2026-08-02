import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// 主壳层：承载 Tab 页面内容与液态玻璃底部菜单。
/// 由 go_router 的 ShellRoute 注入 child。
/// 底栏用 Stack 叠放，避免 Scaffold.bottomNavigationBar 的不透明 Material 挡住毛玻璃。
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _indexFromLocation(String location) {
    if (location.startsWith('/table')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0;
  }

  void _onTabTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/table');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int currentIndex = _indexFromLocation(location);

    return GlassScaffold(
      backgroundColor: Colors.transparent,
      body: child,
      bottomBar: GlassTabBar.bottom(
        quality: GlassQuality.standard,
        selectedIndex: currentIndex,
        onTabSelected: (int index) {
          _onTabTap(context, index);
        },
        tabs: [
          GlassTab(icon: const Icon(Icons.home_rounded), label: '首页'),
          GlassTab(icon: const Icon(Icons.grid_view_rounded), label: '列表'),
          GlassTab(icon: const Icon(Icons.person_rounded), label: '我的'),
        ],
      ),
    );
  }
}
