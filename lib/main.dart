import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/levels_provider.dart';
import 'package:reaction_speed_trainer/screens/home_history_screen.dart';
import 'package:reaction_speed_trainer/screens/tabbed_home_screen.dart';
import 'providers/reaction_provider.dart';
import 'screens/home_screen.dart';
import 'screens/measure_reaction_screen.dart';
import 'screens/level_list_screen.dart';
import 'screens/level_history_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final reactionProvider = ReactionProvider();
  await reactionProvider.loadResults();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => reactionProvider),
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
        '/': (context) => const TabbedHomeScreen(),
        '/measure-reaction': (context) => const MeasureReactionScreen(),
        '/history': (context) => const HistoryScreen(),
        '/level-history': (context) => const LevelHistoryScreen(),
      },
    );
  }
}
