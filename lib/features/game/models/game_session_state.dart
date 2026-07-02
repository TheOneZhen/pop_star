import '../models/animation_phase.dart';
import '../models/eliminate_result.dart';
import '../models/game_state.dart';
import '../models/grid_position.dart';

/// 游戏会话 UI 状态：在 GameState 基础上附加动画与预览信息。
/// 由 GameNotifier 维护，供 GameScreen 与 BoardWidget 读取。
class GameSessionState {
  const GameSessionState({
    required this.gameState,
    this.animationPhase = AnimationPhase.none,
    this.lastEliminate,
    this.gravityMoves = const {},
    this.highlightedPositions = const [],
    this.isNewRecord = false,
  });

  final GameState gameState;
  final AnimationPhase animationPhase;
  final EliminateResult? lastEliminate;
  final Map<String, int> gravityMoves;
  final List<GridPosition> highlightedPositions;
  final bool isNewRecord;

  GameSessionState copyWith({
    GameState? gameState,
    AnimationPhase? animationPhase,
    EliminateResult? lastEliminate,
    bool clearLastEliminate = false,
    Map<String, int>? gravityMoves,
    List<GridPosition>? highlightedPositions,
    bool? isNewRecord,
  }) {
    EliminateResult? newEliminate = lastEliminate;
    if (clearLastEliminate) {
      newEliminate = null;
    } else if (lastEliminate == null && !clearLastEliminate) {
      newEliminate = this.lastEliminate;
    }

    return GameSessionState(
      gameState: gameState ?? this.gameState,
      animationPhase: animationPhase ?? this.animationPhase,
      lastEliminate: newEliminate,
      gravityMoves: gravityMoves ?? this.gravityMoves,
      highlightedPositions:
          highlightedPositions ?? this.highlightedPositions,
      isNewRecord: isNewRecord ?? this.isNewRecord,
    );
  }
}
