import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum SortOrder { ascending, descending }

class ReactionProvider with ChangeNotifier {
  List<Map<String, dynamic>> _results = [];
  SortOrder _sortOrder = SortOrder.descending;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  String get userId => currentUser?.uid ?? 'default_user_id';

  SortOrder get sortOrder => _sortOrder;

  ReactionProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadResults();
      } else {
        _results.clear();
        notifyListeners();
      }
    });
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  List<Map<String, dynamic>> get results {
    final sortedResults = List<Map<String, dynamic>>.from(_results);
    if (_sortOrder == SortOrder.descending) {
      sortedResults.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    } else {
      sortedResults.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
    }
    return sortedResults;
  }

  

 Future<void> loadResults({
  String type = 'measurements',
  String? levelId,
  String? difficulty,
}) async {
  if (_auth.currentUser == null) {
    _results = [];
    notifyListeners();
    return;
  }

  try {
    DatabaseReference ref;

    if (type == 'measurements') {
      ref = _database.child('users/$userId/results/measurements');
    } else if (type == 'levels' && levelId != null) {
      if (difficulty != null) {
        ref = _database.child('users/$userId/results/levels/$levelId/$difficulty');
      } else {
        ref = _database.child('users/$userId/results/levels/$levelId');
      }
    } else {
      throw Exception('Некорректный тип результата');
    }

    final snapshot = await ref.orderByChild('date').get();

    if (snapshot.exists) {
      _results = snapshot.children.map((doc) {
        if (doc.value is Map) {
          final data = Map<String, dynamic>.from(doc.value as Map);
          data['id'] = doc.key;
          return data;
        } else {
          throw Exception('Некорректный формат данных');
        }
      }).toList();
    } else {
      _results = [];
    }
  } catch (e) {
    print('Ошибка загрузки данных: $e');
    _results = [];
  } finally {
    notifyListeners();
  }
}

  Future<void> addResult({
    required String type,
    required double time,
    String? levelId,
    String? difficulty,
  }) async {
    if (currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }

    final Map<String, dynamic> newResult = {
      'userId': userId,
      'time': time,
      'date': DateTime.now().toString(),
    };

    try {
      DatabaseReference resultRef;

      if (type == 'measurements') {
        resultRef = _database.child('users/$userId/results/measurements').push();
      } else if (type == 'levels' && levelId != null && difficulty != null) {
        resultRef = _database
            .child('users/$userId/results/levels/$levelId/$difficulty')
            .push();
      } else {
        throw Exception('Некорректный тип результата');
      }

      await resultRef.set(newResult);
      print('Данные успешно записаны в базу: $newResult');

      newResult['id'] = resultRef.key;
      _results.add(newResult);
      notifyListeners();
    } catch (e) {
      print('Ошибка при добавлении результата: $e');
    }
  }

  Future<void> deleteResultById({
    required String id,
    required String type,
    String? levelId,
    String? difficulty,
  }) async {
    if (currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }

    try {
      DatabaseReference ref;

      if (type == 'measurements') {
        ref = _database.child('users/$userId/results/measurements/$id');
      } else if (type == 'levels' && levelId != null && difficulty != null) {
        ref = _database.child('users/$userId/results/levels/$levelId/$difficulty/$id');
      } else {
        throw Exception('Некорректный тип результата');
      }

      await ref.remove();
      _results.removeWhere((result) => result['id'] == id);
      notifyListeners();
    } catch (e) {
      print('Ошибка удаления результата по ID: $e');
    }
  }

  Future<void> clearResults() async {
    if (currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }

    try {
      await _database.child('users/$userId/results').remove();
      _results.clear();
      notifyListeners();
    } catch (e) {
      print('Ошибка очистки результатов: $e');
    }
  }
}