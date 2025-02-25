import 'package:flutter/material.dart';

class Level {
  final int id;
  final String name;
  final String difficulty;
  final String description;
  final WidgetBuilder trainingWidgetBuilder; 
  final List<LevelResult> history;

  Level({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.description,
    required this.trainingWidgetBuilder,
    this.history = const [],
  });
}

class LevelResult {
  final double reactionTime;
  final DateTime date;

  LevelResult({
    required this.reactionTime,
    required this.date,
  });
} 