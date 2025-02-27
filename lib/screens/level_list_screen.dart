import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/levels_provider.dart';
import '../widgets/level_item_widget.dart';

class LevelsListScreen extends StatelessWidget {
  const LevelsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levelsProvider = Provider.of<LevelsProvider>(context);

    return Scaffold(
      body: ListView.builder(
        itemCount: levelsProvider.levels.length,
        itemBuilder: (context, index) {
          final level = levelsProvider.levels[index];
          return LevelItemWidget(level: level);
        },
      ),
    );
  }
}