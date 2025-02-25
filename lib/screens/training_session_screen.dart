// lib/screens/training_session_screen.dart
import 'package:flutter/material.dart';
import '../models/level.dart';

class TrainingSessionScreen extends StatelessWidget {
  final Level level;

  const TrainingSessionScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(level.name),
      ),
      body: level.trainingWidgetBuilder(context),
    );
  }
}