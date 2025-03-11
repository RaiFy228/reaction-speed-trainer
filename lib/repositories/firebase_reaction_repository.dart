import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:reaction_speed_trainer/repositories/i_reaction_repository.dart';

class FirebaseReactionRepository implements IReactionRepository {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? 'default_user_id';

  @override
  Future<void> addResult({
    required String type,
    required double time,
    int? repetitions,
    int? errors,
    String? levelId,
    String? date, // Add this parameter to match the interface
  }) async {
    if (_auth.currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }
    final Map<String, dynamic> newResult = {
      'userId': userId,
      'time': time,
      'repetitions': repetitions ?? 5, // Количество повторений (по умолчанию 5)
      'errors': errors ?? 0, // Количество ошибок (по умолчанию 0)
      'date': date ?? DateTime.now().toString(), // Use provided date or current date
    };
    try {
      DatabaseReference resultRef;
      if (type == 'measurements') {
        resultRef = _database.child('users/$userId/results/measurements').push();
      } else if (type == 'levels' && levelId != null) {
        resultRef = _database
            .child('users/$userId/results/levels/$levelId')
            .push();
      } else {
        throw Exception('Некорректный тип результата');
      }
      await resultRef.set(newResult);
      if (kDebugMode) {
        print('Данные успешно записаны в базу: $newResult');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при добавлении результата: $e');
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadResults({
    required String type,
    String? levelId,
  }) async {
    if (_auth.currentUser == null) {
      return [];
    }

    try {
      DatabaseReference ref;

      if (type == 'measurements') {
        ref = _database.child('users/$userId/results/measurements');
      } else if (type == 'levels' && levelId != null) {
        ref = _database.child('users/$userId/results/levels/$levelId');
      } else {
        throw Exception('Некорректный тип результата');
      }

      final snapshot = await ref.orderByChild('date').get();

      if (snapshot.exists) {
        return snapshot.children.map((doc) {
          if (doc.value is Map) {
            final data = Map<String, dynamic>.from(doc.value as Map);
            data['id'] = doc.key;
            return data;
          } else {
            throw Exception('Некорректный формат данных');
          }
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка загрузки данных: $e');
      }
      return [];
    }
  }

  @override
  Future<void> deleteResultById({
    required String id,
    required String type,
    String? levelId,
  }) async {
    if (_auth.currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }

    try {
      DatabaseReference ref;

      if (type == 'measurements') {
        ref = _database.child('users/$userId/results/measurements/$id');
      } else if (type == 'levels' && levelId != null) {
        ref = _database.child('users/$userId/results/levels/$levelId/$id');
      } else {
        throw Exception('Некорректный тип результата');
      }

      await ref.remove();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка удаления результата по ID: $e');
      }
    }
  }

  @override
  Future<void> clearResults() async {
    if (_auth.currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }

    try {
      await _database.child('users/$userId/results').remove();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка очистки результатов: $e');
      }
    }
  }
}
