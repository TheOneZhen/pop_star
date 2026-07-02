/// 游戏全局常量：棋盘尺寸、颜色数量、计分规则、动画时长等。
/// 逻辑层与 UI 层均从此处读取配置，避免魔法数字散落各处。
class GameConstants {
  GameConstants._();

  static const int defaultRows = 10;
  static const int defaultCols = 10;
  static const int defaultColorCount = 5;

  /// 开局随机生成棋盘的最大重试次数（避免初始死局）。
  static const int maxBoardGenerationRetries = 50;

  /// 消除动画时长（毫秒）。
  static const int eliminateAnimationMs = 250;

  /// 下落动画时长（毫秒）。
  static const int gravityAnimationMs = 300;

  /// 粒子特效时长（毫秒）。
  static const int particleBurstMs = 400;

  /// 经典消灭星星计分公式：消除 n 个得 n * (n - 1) * 5 分。
  static int scoreForCount(int count) {
    return count * (count - 1) * 5;
  }
}
