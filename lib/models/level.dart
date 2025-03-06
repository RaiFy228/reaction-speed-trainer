import 'package:flutter/material.dart';

class Level {
  final int id;
  final String name;
  final String description;
  final Map<String, WidgetBuilder> trainingWidgetBuilders;
  final Map<String, List<LevelResult>> history;
  final int repetitions; // Количество повторений

  Level({
    required this.id,
    required this.name,
    required this.description,
    required this.trainingWidgetBuilders,
    this.history = const {},
    this.repetitions = 5, // По умолчанию 5 повторений
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