import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/reaction_provider.dart';
import 'package:reaction_speed_trainer/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedRepetitions = 5; // Значение по умолчанию

  @override
  void initState() {
    super.initState();
    _loadSelectedRepetitions();
  }

  // Загрузка сохраненного значения из SharedPreferences
  Future<void> _loadSelectedRepetitions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRepetitions = prefs.getInt('selectedRepetitions');
    if (savedRepetitions != null) {
      setState(() {
        _selectedRepetitions = savedRepetitions;
      });
    }
  }

  // Сохранение выбранного значения в SharedPreferences
  void _saveSelectedRepetitions(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedRepetitions', value);

    if (mounted) {
      final reactionProvider = Provider.of<ReactionProvider>(context, listen: false);
      reactionProvider.setSelectedRepetitions();
    }
  }

  // Уменьшение количества повторений
  void _decreaseRepetitions() {
    if (_selectedRepetitions > 1) {
      setState(() {
        _selectedRepetitions--;
      });
      _saveSelectedRepetitions(_selectedRepetitions);
    }
  }

  // Увеличение количества повторений
  void _increaseRepetitions() {
    if (_selectedRepetitions < 10) {
      setState(() {
        _selectedRepetitions++;
      });
      _saveSelectedRepetitions(_selectedRepetitions);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Проверяем, что виджет все еще существует перед навигацией
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Проверяем, что виджет все еще существует перед показом SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выходе: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Количество повторений:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Кнопка уменьшения
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: _decreaseRepetitions,
                ),
                // Отображение текущего значения
                Text(
                  '$_selectedRepetitions',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Кнопка увеличения
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: _increaseRepetitions,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
            title: const Text('Темная тема'),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Выйти из аккаунта'),
              trailing: const Icon(Icons.logout),
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}