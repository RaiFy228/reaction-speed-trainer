import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/levels_provider.dart';
import '../models/level.dart';

class LevelHistoryScreen extends StatelessWidget {
  const LevelHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем данные уровня из аргументов маршрута
    final Level level = ModalRoute.of(context)!.settings.arguments as Level;

    return Scaffold(
      appBar: AppBar(
        title: Text('История результатов: ${level.name}'),
      ),
      body: Consumer<LevelsProvider>(
        builder: (context, levelsProvider, child) {
          // Фильтруем историю результатов для текущего уровня
          final history = level.history;

          if (history.isEmpty) {
            return const Center(
              child: Text('Нет результатов'),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final result = history[index];
              return ListTile(
                title: Text('Время реакции: ${result.reactionTime.toStringAsFixed(2)} сек'),
                subtitle: Text('Дата: ${_formatDate(result.date)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Удаляем результат из истории
                    levelsProvider.clearHistory(level.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Функция для форматирования даты
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}';
  }
}