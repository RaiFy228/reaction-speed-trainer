import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reaction_provider.dart';

class LevelHistoryScreen extends StatefulWidget {
  final int levelId;
  final String difficulty;
  final String levelName;

  const LevelHistoryScreen({
    super.key,
    required this.levelId,
    required this.difficulty, 
    required this.levelName,
  });

  @override
  State<LevelHistoryScreen> createState() => _LevelHistoryScreenState();
}

class _LevelHistoryScreenState extends State<LevelHistoryScreen> {
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.difficulty; // Устанавливаем начальную сложность
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReactionProvider>(context, listen: false).loadResults(
        type: 'levels',
        levelId: widget.levelId.toString(),
        difficulty: widget.difficulty,
      );
    });
  }

  void _onDifficultyChanged(String? value) {
    setState(() {
      _selectedDifficulty = value;
    });

    if (value != null) {
      Provider.of<ReactionProvider>(context, listen: false).loadResults(
        type: 'levels',
        levelId: widget.levelId.toString(),
        difficulty: value,
      );
    }
  }

  void _showClearHistoryDialog(BuildContext context, ReactionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить историю?'),
        content: const Text('Вы уверены, что хотите удалить все результаты?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              provider.clearResults();
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reactionProvider = Provider.of<ReactionProvider>(context);
    final results = reactionProvider.levelResults;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'История: ${widget.levelName}', // Используем название уровня в заголовке
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40), // Высота нижней части
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 45,
                  children: [
                    DropdownButton<SortOrder>(
                      value: reactionProvider.sortOrder,
                      onChanged: (value) {
                        reactionProvider.setSortOrder(value!);
                      },
                      items: [
                        DropdownMenuItem(
                          value: SortOrder.descending,
                          child: Text('Новые сверху'),
                        ),
                        DropdownMenuItem(
                          value: SortOrder.ascending,
                          child: Text('Старые сверху'),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                        value: _selectedDifficulty,
                        onChanged: _onDifficultyChanged,
                        items: ['Легко', 'Средне', 'Сложно']
                            .map((difficulty) => DropdownMenuItem(
                                  value: difficulty,
                                  child: Text(difficulty),
                                ))
                            .toList(),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () {
                        _showClearHistoryDialog(context, reactionProvider);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: _selectedDifficulty == null
          ? const Center(child: Text('Выберите сложность'))
          : results.isEmpty
              ? const Center(child: Text('Нет сохраненных результатов'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          return Dismissible(
                            key: Key(result['id']), // Используем уникальный ID из Firebase
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              // Удаляем элемент по его уникальному ID
                              reactionProvider.deleteResultById(
                                id: result['id'],
                                type: 'levels',
                                levelId: widget.levelId.toString(),
                                difficulty: _selectedDifficulty!,
                              );

                              // Показываем SnackBar с возможностью отмены
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Запись удалена'),
                                  action: SnackBarAction(
                                    label: 'Отмена',
                                    onPressed: () {
                                      // Восстанавливаем удаленный элемент
                                      reactionProvider.addResult(
                                        type: 'levels',
                                        time: result['time'].toDouble(),
                                        levelId: widget.levelId.toString(),
                                        difficulty: _selectedDifficulty!,
                                        date: result['date'], // Передаем оригинальную дату
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text('${result['time'].toStringAsFixed(0)} мс, Ошибки: ${result['errors']} из ${result['repetitions']}'),
                              subtitle: Text(result['date']),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Свайпните влево, чтобы удалить запись',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
    );
  }
}