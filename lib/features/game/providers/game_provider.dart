import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/game_engine.dart';
import 'game_notifier.dart';

/// 兼容旧引用的 GameEngine Provider，实际状态请使用 gameNotifierProvider。
final gameEngineProvider = Provider<GameEngine>((ref) {
  return ref.watch(gameNotifierProvider.notifier).engine;
});
