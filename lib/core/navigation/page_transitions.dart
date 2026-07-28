import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';

/// 页面切换动画工具：为 go_router 提供统一的 CustomTransitionPage 工厂方法。
/// 使用显式 Tween + Transition Widget，不依赖第三方动画 DSL。
class PageTransitions {
  PageTransitions._();

  /// 淡入淡出，适合返回首页或轻量切换。
  static CustomTransitionPage<void> fade({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(
        milliseconds: AppConstants.pageTransitionMs,
      ),
      reverseTransitionDuration: const Duration(
        milliseconds: AppConstants.pageReverseTransitionMs,
      ),
      transitionsBuilder: _buildFadeTransition,
    );
  }

  /// 自下而上轻微滑入并淡入，适合进入游戏页。
  static CustomTransitionPage<void> fadeSlideUp({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(
        milliseconds: AppConstants.pageTransitionMs,
      ),
      reverseTransitionDuration: const Duration(
        milliseconds: AppConstants.pageReverseTransitionMs,
      ),
      transitionsBuilder: _buildFadeSlideUpTransition,
    );
  }

  /// 从右侧滑入，适合进入设置页。
  static CustomTransitionPage<void> slideFromRight({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(
        milliseconds: AppConstants.pageTransitionMs,
      ),
      reverseTransitionDuration: const Duration(
        milliseconds: AppConstants.pageReverseTransitionMs,
      ),
      transitionsBuilder: _buildSlideFromRightTransition,
    );
  }

  /// 缩放并淡入，适合启动页进入首页。
  static CustomTransitionPage<void> fadeScale({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(
        milliseconds: AppConstants.pageTransitionMs,
      ),
      reverseTransitionDuration: const Duration(
        milliseconds: AppConstants.pageReverseTransitionMs,
      ),
      transitionsBuilder: _buildFadeScaleTransition,
    );
  }

  static Widget _buildFadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    );
    return FadeTransition(opacity: curved, child: child);
  }

  static Widget _buildFadeSlideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    final Animation<Offset> offset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curved);

    return SlideTransition(
      position: offset,
      child: FadeTransition(opacity: curved, child: child),
    );
  }

  static Widget _buildSlideFromRightTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    final Animation<Offset> offset = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(curved);

    return SlideTransition(position: offset, child: child);
  }

  static Widget _buildFadeScaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    final Animation<double> scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      curved,
    );

    return ScaleTransition(
      scale: scale,
      child: FadeTransition(opacity: curved, child: child),
    );
  }
}
