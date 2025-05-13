import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/theme_provider.dart';
import 'package:reaction_speed_trainer/repositories/api_reaction_repository.dart';
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

  final prefs = await SharedPreferences.getInstance();
  final initialTheme = prefs.getBool('isDarkMode') ?? false;
  final isLoggedIn = prefs.containsKey('currentUserId');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initializeTheme(initialTheme),
        ),
        ChangeNotifierProvider(create: (_) => ReactionProvider(ApiReactionRepository())),
        ChangeNotifierProvider(create: (_) => LevelsProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Тренинг Реакции',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: isLoggedIn ? '/' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/': (context) => const TabbedHomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/history': (context) => const HistoryScreen(
              exerciseTypeId: 1,
              exerciseName: 'Базовая реакция',
            ),
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
  scaffoldBackgroundColor: Color.fromARGB(255, 36, 35, 35),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 36, 35, 35),
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
    bodyMedium: TextStyle(color: Colors.white),
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.white,
    secondary: Colors.blueAccent,
  ),
);