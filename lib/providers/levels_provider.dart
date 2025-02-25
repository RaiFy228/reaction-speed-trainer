import 'package:flutter/material.dart';
import 'package:reaction_speed_trainer/widgets/levels/level_1_widget.dart';
import 'package:reaction_speed_trainer/widgets/levels/level_2_widget.dart';
import 'package:reaction_speed_trainer/widgets/levels/level_3_widget.dart';
import '../models/level.dart';

class LevelsProvider with ChangeNotifier {
  final List<Level> _levels = [
    Level(
      id: 1,
      name: 'Уровень 1',
      difficulty: 'Легко',
      description: 'Нажмите на блок, когда он изменит цвет.',
      trainingWidgetBuilder: (context) => const Level1Widget(),
    ),
    Level(
      id: 2,
      name: 'Уровень 2',
      difficulty: 'Средне',
      description: 'Поймайте движущийся объект.',
      trainingWidgetBuilder: (context) => const Level2Widget(),
    ),
    Level(
      id: 3,
      name: 'Уровень 3',
      difficulty: 'Сложно',
      description: 'Взаимодействуйте с кругами.',
      trainingWidgetBuilder: (context) => const Level3Widget(),
    ),
    // Добавьте остальные уровни аналогично
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
}