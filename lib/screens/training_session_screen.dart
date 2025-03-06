import 'package:flutter/material.dart';
import '../models/level.dart';

class TrainingSessionScreen extends StatefulWidget {
  final Level level;
  final String difficulty;

  const TrainingSessionScreen({
    super.key,
    required this.level,
    required this.difficulty,
  });

  @override
  State<TrainingSessionScreen> createState() => _TrainingSessionScreenState();
}

class _TrainingSessionScreenState extends State<TrainingSessionScreen> {
  late String _currentDifficulty;

  @override
  void initState() {
    super.initState();
    _currentDifficulty = widget.difficulty;
  }

  Future<void> _showDifficultyDialog(BuildContext context) async {
    final selectedDifficulty = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите сложность'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.level.trainingWidgetBuilders.keys.map((difficulty) {
            return ListTile(
              title: Text(difficulty),
              onTap: () => Navigator.pop(context, difficulty),
            );
          }).toList(),
        ),
      ),
    );

    if (selectedDifficulty != null && selectedDifficulty != _currentDifficulty) {
      setState(() {
        _currentDifficulty = selectedDifficulty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainingWidgetBuilder = widget.level.trainingWidgetBuilders[_currentDifficulty];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.level.name} - $_currentDifficulty'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz), // Иконка для смены сложности
            onPressed: () {
              _showDifficultyDialog(context);
            },
          ),
        ],
      ),
      body: trainingWidgetBuilder != null
          ? trainingWidgetBuilder(context)
          : const Center(
              child: Text('Тренировка для этой сложности недоступна.'),
            ),
    );
  }
}