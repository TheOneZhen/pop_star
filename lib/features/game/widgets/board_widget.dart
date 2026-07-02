import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../models/animation_phase.dart';
import '../models/cell.dart';
import '../models/eliminate_result.dart';
import '../models/game_session_state.dart';
import '../models/game_status.dart';
import '../providers/game_notifier.dart';
import 'particle_burst.dart';
import 'star_cell.dart';

/// 游戏棋盘 Widget：渲染格子、处理点击、驱动消除与下落动画。
class BoardWidget extends ConsumerStatefulWidget {
  const BoardWidget({super.key});

  @override
  ConsumerState<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends ConsumerState<BoardWidget>
    with TickerProviderStateMixin {
  late AnimationController _eliminateController;
  late AnimationController _gravityController;
  Animation<double> _eliminateAnimation =
      const AlwaysStoppedAnimation<double>(1.0);
  Animation<double> _gravityAnimation =
      const AlwaysStoppedAnimation<double>(1.0);

  EliminateResult? _activeEliminate;
  bool _eliminateStarted = false;

  @override
  void initState() {
    super.initState();
    _eliminateController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: GameConstants.eliminateAnimationMs,
      ),
    );
    _gravityController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: GameConstants.gravityAnimationMs,
      ),
    );
    _eliminateController.addStatusListener(_onEliminateStatus);
    _gravityController.addStatusListener(_onGravityStatus);
  }

  void _onEliminateStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    _eliminateStarted = false;
    _activeEliminate = null;
    ref.read(gameNotifierProvider.notifier).finishEliminateAnimation();
    _startGravityAnimation();
  }

  void _onGravityStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    ref.read(gameNotifierProvider.notifier).finishGravityAnimation();
  }

  void _startEliminateAnimation(EliminateResult result) {
    _activeEliminate = result;
    _eliminateAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _eliminateController, curve: Curves.easeIn),
    );
    _eliminateController.reset();
    _eliminateController.forward();
  }

  void _startGravityAnimation() {
    _gravityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gravityController, curve: Curves.easeOut),
    );
    _gravityController.reset();
    _gravityController.forward();
  }

  @override
  void dispose() {
    _eliminateController.removeStatusListener(_onEliminateStatus);
    _gravityController.removeStatusListener(_onGravityStatus);
    _eliminateController.dispose();
    _gravityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GameSessionState session = ref.watch(gameNotifierProvider);

    if (session.animationPhase == AnimationPhase.eliminating &&
        session.lastEliminate != null &&
        !_eliminateStarted) {
      _eliminateStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _startEliminateAnimation(session.lastEliminate!);
      });
    }

    final List<List<Cell>> board = session.gameState.board;
    if (board.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int rowCount = board.length;
        final int colCount = board[0].length;
        final double cellSize = _calcCellSize(
          constraints.maxWidth,
          constraints.maxHeight,
          colCount,
          rowCount,
        );
        final double boardWidth = cellSize * colCount;
        final double boardHeight = cellSize * rowCount;

        return AnimatedBuilder(
          animation: Listenable.merge([
            _eliminateController,
            _gravityController,
          ]),
          builder: (BuildContext context, Widget? child) {
            return RepaintBoundary(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: boardWidth,
                    height: boardHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B3E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: _buildCells(session, cellSize, rowCount, colCount),
                    ),
                  ),
                  if (session.animationPhase == AnimationPhase.eliminating &&
                      _activeEliminate != null)
                    ..._buildParticleBursts(
                      _activeEliminate!,
                      cellSize,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _calcCellSize(
    double maxWidth,
    double maxHeight,
    int colCount,
    int rowCount,
  ) {
    final double widthBased = maxWidth / colCount;
    final double heightBased = maxHeight / rowCount;
    if (widthBased < heightBased) {
      return widthBased;
    }
    return heightBased;
  }

  List<Widget> _buildParticleBursts(
    EliminateResult result,
    double cellSize,
  ) {
    final List<Widget> bursts = [];
    for (int i = 0; i < result.positions.length; i = i + 1) {
      final int row = result.positions[i].row;
      final int col = result.positions[i].col;
      bursts.add(
        Positioned(
          left: col * cellSize,
          top: row * cellSize,
          width: cellSize,
          height: cellSize,
          child: ParticleBurst(
            color: result.color,
            center: Offset(cellSize / 2, cellSize / 2),
            onFinished: () {},
          ),
        ),
      );
    }
    return bursts;
  }

  List<Widget> _buildCells(
    GameSessionState session,
    double cellSize,
    int rowCount,
    int colCount,
  ) {
    final List<Widget> widgets = [];
    final List<List<Cell>> board = session.gameState.board;
    final Set<String> eliminatingKeys = {};

    if (_activeEliminate != null &&
        session.animationPhase == AnimationPhase.eliminating) {
      for (int i = 0; i < _activeEliminate!.positions.length; i = i + 1) {
        eliminatingKeys.add(_activeEliminate!.positions[i].key);
      }
    }

    for (int row = 0; row < rowCount; row = row + 1) {
      for (int col = 0; col < colCount; col = col + 1) {
        final Cell cell = board[row][col];
        if (cell.color == null) {
          continue;
        }

        double top = row * cellSize;
        final String cellKey = '$row,$col';
        bool isHighlighted = _isHighlighted(session, cellKey);

        double scale = 1.0;
        double opacity = 1.0;

        if (eliminatingKeys.contains(cellKey) &&
            session.animationPhase == AnimationPhase.eliminating) {
          opacity = _eliminateAnimation.value;
          scale = _eliminateAnimation.value;
        }

        if (session.animationPhase == AnimationPhase.gravity) {
          final int? oldRow = _findOldRow(session.gravityMoves, row, col);
          if (oldRow != null) {
            final double startTop = oldRow * cellSize;
            final double endTop = row * cellSize;
            final double progress = _gravityAnimation.value;
            top = startTop + (endTop - startTop) * progress;
          }
        }

        final bool canTap =
            session.gameState.status == GameStatus.playing &&
            session.animationPhase == AnimationPhase.none;

        widgets.add(
          Positioned(
            left: col * cellSize,
            top: top,
            width: cellSize,
            height: cellSize,
            child: Padding(
              padding: EdgeInsets.all(cellSize * 0.06),
              child: StarCell(
                color: cell.color,
                size: cellSize * 0.88,
                isHighlighted: isHighlighted,
                scale: scale,
                opacity: opacity,
                onTap: canTap
                    ? () {
                        ref
                            .read(gameNotifierProvider.notifier)
                            .onCellTap(row, col);
                      }
                    : null,
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  bool _isHighlighted(GameSessionState session, String cellKey) {
    for (int i = 0; i < session.highlightedPositions.length; i = i + 1) {
      if (session.highlightedPositions[i].key == cellKey) {
        return true;
      }
    }
    return false;
  }

  int? _findOldRow(Map<String, int> moves, int newRow, int col) {
    for (final String oldKey in moves.keys) {
      final int? targetRow = moves[oldKey];
      if (targetRow != newRow) {
        continue;
      }
      final List<String> parts = oldKey.split(',');
      if (parts.length != 2) {
        continue;
      }
      final int oldCol = int.parse(parts[1]);
      if (oldCol == col) {
        return int.parse(parts[0]);
      }
    }
    return null;
  }
}
