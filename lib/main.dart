import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/screens/home_history_screen.dart';
import 'providers/reaction_provider.dart';
import 'providers/levels_provider.dart';
import 'screens/auth_wrapper_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/level_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReactionProvider()),
        ChangeNotifierProvider(create: (_) => LevelsProvider()),
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
      initialRoute: '/', // Начальный маршрут
      routes: {
        '/': (context) => const AuthWrapper(), // Начальный экран
        '/settings': (context) => const SettingsScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}