import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reaction_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reactionProvider = Provider.of<ReactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренинг Реакции'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Лучший результат: ${reactionProvider.bestResult.toStringAsFixed(2)} сек',
              style: const TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/measure-reaction');
              },
              child: const Text('Измерить скорость реакции'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/training');
              },
              child: const Text('Тренировка'),
            ),
          ],
        ),
      ),
    );
  }
}