import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/game_engine.dart';

final gameEngineProvider = Provider<GameEngine>((ref) => GameEngine());
