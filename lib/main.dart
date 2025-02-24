import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/reaction_provider.dart';
import 'screens/home_screen.dart';
import 'screens/measure_reaction_screen.dart';
import 'screens/training_screen.dart';
import 'screens/level_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReactionProvider()),
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
        // '/training': (context) => const TrainingScreen(),
        // '/level': (context) => const LevelScreen(),
        // '/history': (context) => const HistoryScreen(),
      },
    );
  }
}