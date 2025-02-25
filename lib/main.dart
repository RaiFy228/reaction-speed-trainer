import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/levels_provider.dart';
import 'providers/reaction_provider.dart';
import 'screens/home_screen.dart';
import 'screens/measure_reaction_screen.dart';
import 'screens/level_list_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReactionProvider()),
        ChangeNotifierProvider(create: (_) => LevelsProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Тренинг Реакции',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/measure-reaction': (context) => const MeasureReactionScreen(),
        '/levels-list': (context) => const LevelsListScreen(),

        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}