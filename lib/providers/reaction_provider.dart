import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
enum SortOrder { ascending, descending }

class ReactionProvider with ChangeNotifier {
  List<Map<String, dynamic>> _results = [];
  SortOrder _sortOrder = SortOrder.descending;

  SortOrder get sortOrder => _sortOrder;

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  List<Map<String, dynamic>> get results {
    final sortedResults = List<Map<String, dynamic>>.from(_results); // Ensure correct type
    if (_sortOrder == SortOrder.descending) {
      sortedResults.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    } else {
      sortedResults.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
    }
    return sortedResults;
  }

  void addResult(double time) async {
    final prefs = await SharedPreferences.getInstance();
    final newResult = {'time': time, 'date': DateTime.now().toString()};
    _results.add(newResult);
    notifyListeners();

    // Сохраняем историю в SharedPreferences в формате JSON
    final resultsJson = jsonEncode(_results);
    prefs.setString('reactionHistory', resultsJson);
  }

  Future<void> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getString('reactionHistory');

    if (resultsJson != null) {
      try {
        final List<dynamic> decodedResults = jsonDecode(resultsJson);
        _results = decodedResults
            .map((e) => {
                  'time': e['time'].toDouble(),
                  'date': e['date'],
                })
            .toList();
      } catch (e) {
        _results = [];
      }
    } else {
      _results = [];
    }

    notifyListeners();
  }

  void deleteResult(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _results.removeAt(index);
    notifyListeners();

    // Обновляем историю в SharedPreferences
    final resultsJson = jsonEncode(_results);
    prefs.setString('reactionHistory', resultsJson);
  }

  void clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    _results.clear();
    notifyListeners();

    // Очищаем историю в SharedPreferences
    prefs.remove('reactionHistory');
  }
}