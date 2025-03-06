import 'package:flutter/material.dart';
import 'package:reaction_speed_trainer/widgets/levels/level_1_widget.dart';
import '../models/level.dart';

class LevelsProvider with ChangeNotifier {
  final List<Level> _levels = [
    Level(
      id: 1,
      name: 'Уровень 1',
      description: 'Нажмите на блок, когда он изменит цвет.',
      trainingWidgetBuilders: {
        'Легко': (context) => const Level1EasyWidget(),
        'Средне': (context) => const Level1MediumWidget(),
        'Сложно': (context) => const Level1HardWidget(),
      },
      history: {
        'Легко': [],
        'Средне': [],
        'Сложно': [],
      },
    ),
    Level(
      id: 2,
      name: 'Уровень 2',
      description: 'Поймайте движущийся объект.',
      trainingWidgetBuilders: {
        // 'Легко': (context) => const Level2EasyWidget(),
        // 'Средне': (context) => const Level2MediumWidget(),
        // 'Сложно': (context) => const Level2HardWidget(),
      },
      history: {
        'Легко': [],
        'Средне': [],
        'Сложно': [],
      },
    ),
    // Добавьте остальные уровни аналогично
  ];

  List<Level> get levels => _levels;

  void addResult(int levelId, String difficulty, double reactionTime) {
    final level = _levels.firstWhere((l) => l.id == levelId);
    if (!level.history.containsKey(difficulty)) {
      level.history[difficulty] = [];
    }
    level.history[difficulty]?.add(LevelResult(reactionTime: reactionTime, date: DateTime.now()));
    notifyListeners();
  }

  void clearHistory(int levelId, String difficulty) {
    final level = _levels.firstWhere((l) => l.id == levelId);
    level.history[difficulty]?.clear();
    notifyListeners();
  }

  double getAverageReactionTime(int levelId, String difficulty) {
    final level = _levels.firstWhere((l) => l.id == levelId);
    final results = level.history[difficulty];
    if (results == null || results.isEmpty) return 0;
    final total = results.map((r) => r.reactionTime).reduce((a, b) => a + b);
    return total / results.length;
  }
}