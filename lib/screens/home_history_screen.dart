import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reaction_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

   @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

@override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReactionProvider>(context, listen: false).loadResults( type: 'measurements');
    });
  }

  @override
  Widget build(BuildContext context) {
    final reactionProvider = Provider.of<ReactionProvider>(context);
    final results = reactionProvider.measurementResults;

    return Scaffold(
     appBar: AppBar(
        title: Text(
          'История результатов',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40), // Высота нижней части
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () {
                    _showClearHistoryDialog(context, reactionProvider);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: results.isEmpty
          ? const Center(child: Text('Нет сохраненных результатов'))
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return Dismissible(
                  key: Key(result['id']), // Уникальный ключ для каждого элемента
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
                      id: result['id'], // Передаем уникальный ID
                      type: 'measurements', // Указываем тип результата
                    
                    );

                    // Показываем SnackBar с возможностью отмены
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Запись удалена'),
                        action: SnackBarAction(
                          label: 'Отмена',
                          onPressed: () async {
                            // Восстанавливаем удаленный элемент
                            await reactionProvider.addResult(
                              type: 'measurements', // Указываем тип результата
                              time: result['time'].toDouble(),
                              date: result['date'], // Передаем оригинальную дату
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text('${result['time'].toStringAsFixed(0)} мс, Ошибки: ${result['errors']}'),
                    subtitle: Text(result['date']),
                  ),
                );
              },
            ),
    );
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
}