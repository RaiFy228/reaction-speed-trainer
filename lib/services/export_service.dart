import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExportService {

  Future<File?> exportToCsv(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) return null;

    final List<List<dynamic>> csvData = [];
    final headers = data.isNotEmpty ? data.first.keys.toList() : [];
    csvData.add(headers);

    for (var row in data) {
      csvData.add(row.values.map((e) => e.toString()).toList());
    }

    final String csv = const ListToCsvConverter().convert(csvData);
    return _saveFile('csv', csv);
  }

  Future<File?> exportToJson(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) return null;

    final jsonData = JsonEncoder.withIndent('  ').convert(data);
    return _saveFile('json', jsonData);
  }

  Future<File?> _saveFile(String format, String content) async {
    try {
      // Получаем id пользователя и текущую дату
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('currentUserId') ?? 'unknown_user';
      final currentDate = DateTime.now().toString().split(' ')[0];

      // Генерируем имя файла
      final filename = '${userId}_${currentDate}_export.$format';
      
      // Путь для сохранения файла
      final directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/$filename';
      final file = File(path);

      // Записываем содержимое в файл
      return await file.writeAsString(content);
    } catch (e) {
      return null;
    }
  }
}
