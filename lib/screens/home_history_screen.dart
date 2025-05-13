import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reaction_provider.dart';
import 'chart_screen.dart';

class HistoryScreen extends StatefulWidget {
  final int exerciseTypeId;
  final String exerciseName;

  const HistoryScreen({
    super.key,
    required this.exerciseTypeId,
    required this.exerciseName,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReactionProvider>(context, listen: false)
          .loadResults(widget.exerciseTypeId);
    });
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final reactionProvider = Provider.of<ReactionProvider>(context);
    final results = reactionProvider.getResults(widget.exerciseTypeId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.exerciseName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: results.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChartScreen(
                          initialResults: results, // Передаем исходные данные
                          exerciseName: widget.exerciseName,
                        ),
                      ),
                    );
                  },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<SortOrder>(
                  value: reactionProvider.sortOrder,
                  onChanged: (value) => reactionProvider.setSortOrder(value!),
                  items: const [
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
                  onPressed: () => _showClearHistoryDialog(context, reactionProvider),
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
                  key: Key(result['Id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                   onDismissed: (_) async {
                    final deletedItem = result;
                    final deletedItemIndex = results.indexOf(result);

                    reactionProvider.removeLocalResult(
                      exerciseTypeId: widget.exerciseTypeId,
                      resultId: result['Id'].toString(),
                    );

                    final scaffold = ScaffoldMessenger.of(context);
                    late SnackBarClosedReason reason;

                    try {
                      reason = await scaffold.showSnackBar(
                        SnackBar(
                          content: const Text('Запись удалена'),
                          action: SnackBarAction(
                            label: 'Отмена',
                            onPressed: () {
                              reason = SnackBarClosedReason.action;
                            },
                          ),
                          duration: const Duration(seconds: 5),
                        ),
                      ).closed;
                    } catch (_) {
                      reason = SnackBarClosedReason.remove;
                    }

                    if (reason != SnackBarClosedReason.action) {
                      try {
                        await reactionProvider.deleteResultById(
                          id: deletedItem['Id'].toString(),
                          exerciseTypeId: widget.exerciseTypeId,
                        );
                      } catch (e) {
                        // Восстанавливаем при ошибке
                        reactionProvider.restoreLocalResult(
                          exerciseTypeId: widget.exerciseTypeId,
                          result: deletedItem,
                          index: deletedItemIndex,
                        );
                      }
                    }
                    else {
                      reactionProvider.restoreLocalResult(
                          exerciseTypeId: widget.exerciseTypeId,
                          result: deletedItem,
                          index: deletedItemIndex,
                      );
                    }
                  },
                  child: ListTile(
                    title: Text(
                      '${result['AverageReactionTimeMs']} мс, '
                      'Ошибки: ${result['ErrorCount']}',
                    ),
                    subtitle: Text(_formatDate(result['CompletedAt'])),
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
              provider.clearResults(widget.exerciseTypeId);
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}