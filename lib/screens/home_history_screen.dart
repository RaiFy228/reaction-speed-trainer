import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reaction_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reactionProvider = Provider.of<ReactionProvider>(context);

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
                              reactionProvider.clearResults();
                              Navigator.pop(context);
                            },
                            child: const Text('Удалить'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: reactionProvider.results.isEmpty
    ? const Center(child: Text('Нет сохраненных результатов'))
    : Column(
        children: [
          
          Expanded(
            child: ListView.builder(
              itemCount: reactionProvider.results.length,
              itemBuilder: (context, index) {
                final result = reactionProvider.results[index];
                return Dismissible(
                  key: Key(result['date']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    reactionProvider.deleteResult(index);
                  },
                  child: ListTile(
                    title: Text('${result['time'].toStringAsFixed(0)} мс'),
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