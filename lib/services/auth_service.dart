import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.0.103:56925/api/auth';
  static const String _userKey = 'currentUserId';

  Future<void> register(String email, String password, String fullName) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Email': email,
        'Password': password,
        'FullName': fullName
      }),
    );

    if (response.statusCode == 200) {
      final userId = jsonDecode(response.body)['Id'].toString();
      await _saveUserId(userId);
    } else {
      throw _parseError(response.body);
    }
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Email': email,
        'Password': password
      }),
    );

    if (response.statusCode == 200) {
      final userId = jsonDecode(response.body)['Id'].toString();
      await _saveUserId(userId);
    } else {
      throw _parseError(response.body);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
    
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userId);
  }

  String _parseError(String body) {
    try {
      final error = jsonDecode(body)['Message'];
      return error ?? 'Неизвестная ошибка сервера';
    } catch (e) {
      return 'Ошибка подключения к серверу';
    }
  }
}