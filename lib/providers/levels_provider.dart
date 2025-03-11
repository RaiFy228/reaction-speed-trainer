import 'package:flutter/material.dart';
import 'package:reaction_speed_trainer/widgets/levels/level_1_widget.dart';
import 'package:reaction_speed_trainer/widgets/levels/level_2_widget.dart';
import 'package:reaction_speed_trainer/widgets/levels/level_3_widget.dart';
import 'package:reaction_speed_trainer/widgets/levels/level_4_widget.dart';
import 'package:reaction_speed_trainer/widgets/levels/level_5_widget.dart';
import '../models/level.dart';

class LevelsProvider with ChangeNotifier {
  final List<Level> _levels = [
    Level(
      id: 1,
      name: 'Ложный сигнал',
      description: 'Нажимай только на зелёный',
      trainingWidgetBuilder: (context) => const Level1Widget(),
      history: [],
    ),
    Level(
      id: 2,
      name: 'Выбери цвет',
      description: 'Выбери правильный цвет',
      trainingWidgetBuilder: (context) => const Level2Widget(),
      history: [],
    ),
    Level(
      id: 3,
      name: 'Внезавное появление',
      description: 'Нажми на появивщийся объект',
      trainingWidgetBuilder: (context) => const Level3Widget(),
      history: [],
    ),
    Level(
      id: 4,
      name: 'Динамический рост',
      description: 'Нажми, когда круг вырастет',
      trainingWidgetBuilder: (context) => const Level4Widget(),
      history: [],
    ),
    Level(
      id: 5,
      name: 'Поиск цвета',
      description: 'Найди нужный цвет',
      trainingWidgetBuilder: (context) => const Level5Widget(),
      history: [],
    ),
  ];

  List<Level> get levels => _levels;

  void addResult(int levelId, double reactionTime) {
    final level = _levels.firstWhere((l) => l.id == levelId);
    level.history.add(LevelResult(reactionTime: reactionTime, date: DateTime.now()));
    notifyListeners();
  }

  void clearHistory(int levelId) {
    final level = _levels.firstWhere((l) => l.id == levelId);
    level.history.clear();
    notifyListeners();
  }

  double getAverageReactionTime(int levelId) {
    final level = _levels.firstWhere((l) => l.id == levelId);
    if (level.history.isEmpty) return 0;
    final total = level.history.map((r) => r.reactionTime).reduce((a, b) => a + b);
    return total / level.history.length;
  }
}
