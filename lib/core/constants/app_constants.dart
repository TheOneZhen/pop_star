/// 应用级常量：启动动画、页面切换动画时长等。
/// 与游戏内动画常量（GameConstants）分离，便于统一调整体验节奏。
class AppConstants {
  AppConstants._();

  /// 启动页主动画时长（毫秒）。
  static const int splashAnimationMs = 2000;

  /// 启动页最短展示时间（毫秒），动画结束前先达到此时长。
  static const int splashMinDisplayMs = 1200;

  /// 页面切换动画时长（毫秒）。
  static const int pageTransitionMs = 350;

  /// 页面返回动画时长（毫秒）。
  static const int pageReverseTransitionMs = 300;
}
