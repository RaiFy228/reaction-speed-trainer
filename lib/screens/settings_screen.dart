import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedRepetitions = 5; // Значение по умолчанию
  final List<int> _repetitionOptions = List.generate(15, (index) => index + 1); // От 1 до 15

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
  Future<void> _saveSelectedRepetitions(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedRepetitions', value);
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Проверяем, что виджет все еще существует перед навигацией
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
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
            DropdownButton<int>(
              value: _selectedRepetitions,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRepetitions = value;
                  });
                  _saveSelectedRepetitions(value); // Сохраняем выбранное значение
                }
              },
              items: _repetitionOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value повторений'),
                );
              }).toList(),
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