import 'package:flutter/material.dart';
import 'package:reaction_speed_trainer/screens/home_screen.dart';
import 'package:reaction_speed_trainer/screens/level_list_screen.dart';

class TabbedHomeScreen extends StatefulWidget {
  const TabbedHomeScreen({super.key});

  @override
  State<TabbedHomeScreen> createState() => _TabbedHomeScreenState();
}

class _TabbedHomeScreenState extends State<TabbedHomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Измерь реакцию'), // Название первой вкладки
            Tab(text: 'Тренировка'), // Название второй вкладки
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomeScreen(), // Главный экран
          LevelsListScreen(), // Экран с уровнями
        ],
      ),
    );
  }
}