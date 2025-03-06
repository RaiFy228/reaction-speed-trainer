import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/models/level.dart';
import '../providers/levels_provider.dart';
import '../screens/training_session_screen.dart';
import '../screens/level_history_screen.dart';

class LevelsListScreen extends StatelessWidget {
  const LevelsListScreen({super.key});

  Future<void> _showDifficultyDialog(BuildContext context, Level level) async {
    final selectedDifficulty = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите сложность'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: level.trainingWidgetBuilders.keys.map((difficulty) {
            return ListTile(
              title: Text(difficulty),
              onTap: () => Navigator.pop(context, difficulty),
            );
          }).toList(),
        ),
      ),
    );

    if (selectedDifficulty != null) {
      // Переходим на экран тренировки с выбранным уровнем и сложностью
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrainingSessionScreen(
            level: level,
            difficulty: selectedDifficulty,
          ),
        ),
      );
    }
  }

  void _openHistoryScreen(BuildContext context, Level level) {
  // Берем первую доступную сложность по умолчанию
  final defaultDifficulty = level.trainingWidgetBuilders.keys.first;

  // Переходим на экран истории с выбранным уровнем, сложностью и названием уровня
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LevelHistoryScreen(
        levelId: level.id,
        difficulty: defaultDifficulty, // Передаем первую сложность
        levelName: level.name, // Передаем название уровня
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final levelsProvider = Provider.of<LevelsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Список уровней'),
      ),
      body: ListView.builder(
        itemCount: levelsProvider.levels.length,
        itemBuilder: (context, index) {
          final level = levelsProvider.levels[index];
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(level.description),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow), // Иконка "Play"
                      onPressed: () {
                        _showDifficultyDialog(context, level);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.history), // Иконка "History"
                      onPressed: () {
                        _openHistoryScreen(context, level); // Открываем историю
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}