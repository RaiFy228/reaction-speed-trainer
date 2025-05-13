import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reaction_speed_trainer/repositories/i_reaction_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiReactionRepository implements IReactionRepository {
  final String _baseUrl = 'http://192.168.0.103:56925/api';
  static const String _userKey = 'currentUserId';

  Future<String> get _userId async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userKey);
    if (userId == null) throw Exception('Пользователь не авторизован');
    return userId;
  }

  @override
  Future<void> addResult({
    required int exerciseTypeId,
    required double time,
    int? repetitions,
    int? errors,
    String? date,
    required List<Map<String, dynamic>> details,
  }) async {
    final uri = Uri.parse('$_baseUrl/session/add');
    final userId = await _userId;

    final payload = {
      'userId': userId,
      'exerciseTypeId': exerciseTypeId,
      'averageReactionTimeMs': time.toInt(),
      'errorCount': errors ?? 0,
      'repeatsCount': repetitions ?? 5,
      'date': date ?? DateTime.now().toIso8601String(),
      'details': details.map((detail) => {
        'reactionTimeMs': detail['reactionTimeMs'],
        'attemptNumber': detail['attemptNumber'],
      }).toList(),
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Ошибка при добавлении результата: ${response.body}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadResults({
    required int exerciseTypeId,
  }) async {
    final userId = await _userId;
    final uri = Uri.parse('$_baseUrl/session/by-type/$exerciseTypeId?userId=$userId');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Ошибка при получении данных: ${response.body}');
    }

    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  @override
  Future<void> deleteResultById({
    required String id,
    required int exerciseTypeId,
  }) async {
    final userId = await _userId;
    final uri = Uri.parse('$_baseUrl/session/$id?userId=$userId');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Ошибка при удалении результата: ${response.body}');
    }
  }

  @override
  Future<void> clearResults({
    required int exerciseTypeId,
  }) async {
    final userId = await _userId;
    final uri = Uri.parse('$_baseUrl/session/by-type/$exerciseTypeId?userId=$userId');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Ошибка при очистке данных: ${response.body}');
    }
  }
   @override
  Future<List<Map<String, dynamic>>> loadAllResults() async {
    final userId = await _userId;
    final uri = Uri.parse('$_baseUrl/session/by-user/$userId');
    
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Ошибка при получении всех результатов: ${response.body}');
    }

    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }
}