import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/reaction_provider.dart';
import 'package:reaction_speed_trainer/providers/theme_provider.dart';
import 'package:reaction_speed_trainer/services/export_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reaction_speed_trainer/services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedRepetitions = 5;

  @override
  void initState() {
    super.initState();
    _loadSelectedRepetitions();
  }

  Future<void> _loadSelectedRepetitions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedRepetitions = prefs.getInt('selectedRepetitions') ?? 5;
    });
  }

  void _saveSelectedRepetitions(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedRepetitions', value);
    
    if (mounted) {
      Provider.of<ReactionProvider>(context, listen: false).loadSelectedRepetitions();
    }
  }

  void _decreaseRepetitions() {
    if (_selectedRepetitions > 1) {
      setState(() => _selectedRepetitions--);
      _saveSelectedRepetitions(_selectedRepetitions);
    }
  }

  void _increaseRepetitions() {
    if (_selectedRepetitions < 10) {
      setState(() => _selectedRepetitions++);
      _saveSelectedRepetitions(_selectedRepetitions);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final authService = AuthService();
      await authService.logout();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выходе: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _exportData(BuildContext context) async {
  final provider = Provider.of<ReactionProvider>(context, listen: false);
  final exportService = ExportService();

  final format = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Формат экспорта'),
      content: const Text('Выберите желаемый формат файла:'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'CSV'),
          child: const Text('CSV'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'JSON'),
          child: const Text('JSON'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
      ],
    ),
  );

  if (format == null || !context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    await provider.loadAllResults();

    if (provider.allResults.isEmpty) {
    if (!context.mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Нет данных для сохранения'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

    final result = format == 'CSV'
        ? await exportService.exportToCsv(provider.allResults)
        : await exportService.exportToJson(provider.allResults);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result != null
              ? 'Данные успешно экспортированы в $format'
              : 'Ошибка при создании файла'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка экспорта: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Основные настройки'),
          _buildRepetitionsControl(theme),
          const Divider(thickness: 1),
          
          _buildSectionHeader('Внешний вид'),
          SwitchListTile(
            title: const Text('Темная тема'),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          const Divider(thickness: 1),
          
          _buildSectionHeader('Данные'),
          _buildExportButton(theme),
          const Divider(thickness: 1),
          
          _buildSectionHeader('Аккаунт'),
          _buildLogoutButton(theme),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildRepetitionsControl(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Количество повторений',
              style: theme.textTheme.bodyLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _decreaseRepetitions,
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceVariant,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$_selectedRepetitions',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _increaseRepetitions,
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(ThemeData theme) {
    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text('Экспорт данных'),
      subtitle: const Text('CSV или JSON формат'),
      onTap: () => _exportData(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      tileColor: theme.colorScheme.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.red)),
      onTap: () => _signOut(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      tileColor: theme.colorScheme.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}