import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/models/level.dart';
import '../providers/levels_provider.dart';
import '../screens/training_session_screen.dart';
import '../screens/level_history_screen.dart';

class LevelsListScreen extends StatelessWidget {
  const LevelsListScreen({super.key});

  void _openHistoryScreen(BuildContext context, Level level) {
    // Переходим на экран истории с выбранным уровнем
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelHistoryScreen(
          levelId: level.id,
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
        automaticallyImplyLeading: false,
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
                        '${index + 1}. ${level.name}',
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
                        // Переходим на экран тренировки
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrainingSessionScreen(
                              level: level,
                            ),
                          ),
                        );
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
