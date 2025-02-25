import 'package:flutter/material.dart';
import 'package:reaction_speed_trainer/screens/training_session_screen.dart';
import '../models/level.dart';

class LevelItemWidget extends StatelessWidget {
  final Level level;

  const LevelItemWidget({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(level.name),
      subtitle: Text('Сложность: ${level.difficulty}'),
      trailing: IconButton(
        icon: const Icon(Icons.history),
        onPressed: () {
          // Открыть экран истории результатов
          Navigator.pushNamed(
            context,
            '/level-history',
            arguments: level,
          );
        },
      ),
      onTap: () {
        // Открыть экран уровня
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingSessionScreen(level: level),
          ),
        );
      },
    );
  }
}