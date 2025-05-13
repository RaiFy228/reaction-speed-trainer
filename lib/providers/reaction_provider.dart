import 'package:flutter/foundation.dart';
import 'package:reaction_speed_trainer/repositories/i_reaction_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SortOrder { ascending, descending }

class ReactionProvider with ChangeNotifier {
  final Map<int, List<Map<String, dynamic>>> _results = {};
  SortOrder _sortOrder = SortOrder.descending;
  final IReactionRepository _repository;
  int _selectedRepetitions = 0;

  ReactionProvider(this._repository) {
    loadSelectedRepetitions();
  }

  int get selectedRepetitions => _selectedRepetitions;
  SortOrder get sortOrder => _sortOrder;

  List<Map<String, dynamic>> getResults(int exerciseTypeId) {
    return _getSortedResults(_results[exerciseTypeId] ?? []);
  }

  List<Map<String, dynamic>> _getSortedResults(List<Map<String, dynamic>> results) {
    final sortedResults = List<Map<String, dynamic>>.from(results);
    sortedResults.sort((a, b) => _sortOrder == SortOrder.descending
        ? DateTime.parse(b['CompletedAt']).compareTo(DateTime.parse(a['CompletedAt']))
        : DateTime.parse(a['CompletedAt']).compareTo(DateTime.parse(b['CompletedAt'])));
    return sortedResults;
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  Future<void> loadResults(int exerciseTypeId) async {
    try {
      final results = await _repository.loadResults(exerciseTypeId: exerciseTypeId);
      _results[exerciseTypeId] = results;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка загрузки данных: $e');
      }
    }
  }

  Future<void> addResult({
  required int exerciseTypeId,
  required double time,
  int? repetitions,
  int? errors,
  String? date,
  required List<Map<String, dynamic>> details,
  }) async {
    try {
      await _repository.addResult(
        exerciseTypeId: exerciseTypeId,
        time: time,
        repetitions: repetitions,
        errors: errors,
        date: date,
        details: details,
      );
      await loadResults(exerciseTypeId);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при добавлении результата: $e');
      }
    }
  }

  Future<void> deleteResultById({
    required String id,
    required int exerciseTypeId,
  }) async {
    try {
      await _repository.deleteResultById(
        id: id,
        exerciseTypeId: exerciseTypeId,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка удаления результата по ID: $e');
      }
    }
  }

  Future<void> clearResults(int exerciseTypeId) async {
    try {
      await _repository.clearResults(exerciseTypeId: exerciseTypeId);
      _results.remove(exerciseTypeId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка очистки результатов: $e');
      }
    }
  }

  void removeLocalResult({required int exerciseTypeId, required String resultId}) {
    _results[exerciseTypeId]?.removeWhere((result) => result['Id'].toString() == resultId);
    notifyListeners();
  }

  void restoreLocalResult({
    required int exerciseTypeId,
    required Map<String, dynamic> result,
    required int index,
  }) {
    _results[exerciseTypeId]?.insert(index, result);
    notifyListeners();
  }

  Future<int> getSelectedRepetitions() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedRepetitions = prefs.getInt('selectedRepetitions') ?? 5;
    notifyListeners();
    return _selectedRepetitions;
  }

  void loadSelectedRepetitions() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedRepetitions = prefs.getInt('selectedRepetitions') ?? 5;
    notifyListeners();
  }

  List<Map<String, dynamic>> get allResults => 
    _results.values.expand((e) => e).toList();

  Future<void> loadAllResults() async {
    try {
      final results = await _repository.loadAllResults();
      
      // Группируем результаты по ExerciseTypeId
      _results.clear();
      for (var result in results) {
        final typeId = result['ExerciseTypeId'];
        _results.putIfAbsent(typeId, () => []).add(result);
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка загрузки всех данных: $e');
      }
    }
  }
}