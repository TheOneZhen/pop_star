import 'grid_position.dart';
import 'star_color.dart';

/// 一次有效点击消除的结果。
/// 由 GameEngine.tap 返回，供 UI 层播放消除动画与粒子特效。
class EliminateResult {
  const EliminateResult({
    required this.positions,
    required this.scoreDelta,
    required this.color,
  });

  /// 被消除的格子坐标列表。
  final List<GridPosition> positions;

  /// 本次消除增加的分数。
  final int scoreDelta;

  /// 被消除方块的颜色（用于粒子配色）。
  final StarColor color;
}
