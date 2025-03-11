
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/theme_provider.dart';
import 'package:reaction_speed_trainer/repositories/firebase_reaction_repository.dart';
import 'package:reaction_speed_trainer/screens/home_history_screen.dart';
import 'package:reaction_speed_trainer/screens/login_screen.dart';
import 'package:reaction_speed_trainer/screens/register_screen.dart';
import 'package:reaction_speed_trainer/screens/tabbed_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/reaction_provider.dart';
import 'providers/levels_provider.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  final repository = FirebaseReactionRepository();

  final prefs = await SharedPreferences.getInstance();
  final initialTheme = prefs.getBool('isDarkMode') ?? false;


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider( // Исправленный провайдер
           create: (_) => ThemeProvider()..initializeTheme(initialTheme),
        ),
        ChangeNotifierProvider(create: (_) => ReactionProvider(repository)),
        ChangeNotifierProvider(create: (_) => LevelsProvider()),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Тренинг Реакции',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/': (context) => const TabbedHomeScreen(), // Начальный экран
        '/settings': (context) => const SettingsScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}


final lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
  ),
  colorScheme: ColorScheme.light(
    primary: Colors.black,
    secondary: Colors.blueAccent,
  ),
);

// Тема для темного режима
final darkTheme = ThemeData(
  primarySwatch: Colors.blueGrey,
  scaffoldBackgroundColor: Colors.black87,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black54,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.white,
    secondary: Colors.blueAccent,
  ),
);