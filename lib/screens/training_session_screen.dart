import 'package:flutter/material.dart';
import 'package:reaction_speed_trainer/models/level.dart';
import 'package:reaction_speed_trainer/screens/home_history_screen.dart';


class TrainingSessionScreen extends StatelessWidget {
  final Level level;

  const TrainingSessionScreen({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(level.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.history), // Иконка "History"
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(
                   exerciseTypeId: level.id,
                   exerciseName: level.name,
                  ),
                ),
              );// Открываем историю
            },
          ),
        ],
      ),
      body: level.trainingWidgetBuilder(context),
    );
  }
}
