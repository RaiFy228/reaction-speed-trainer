import 'package:flutter/foundation.dart';
import 'package:reaction_speed_trainer/repositories/i_reaction_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SortOrder { ascending, descending }

class ReactionProvider with ChangeNotifier {
  // Отдельные списки для хранения данных разных типов
  int _selectedRepetitions = 0;


  List<Map<String, dynamic>> _measurementResults = [];
  List<Map<String, dynamic>> _levelResults = [];

  SortOrder _sortOrder = SortOrder.descending;

  final IReactionRepository _repository;

  ReactionProvider(this._repository){
    setSelectedRepetitions();
  }

  int get selectedRepetitions => _selectedRepetitions;

  SortOrder get sortOrder => _sortOrder;

  // Геттеры для получения отсортированных данных
  List<Map<String, dynamic>> get measurementResults => _getSortedResults(_measurementResults);
  List<Map<String, dynamic>> get levelResults => _getSortedResults(_levelResults);

  // Общая логика сортировки
  List<Map<String, dynamic>> _getSortedResults(List<Map<String, dynamic>> results) {
    final sortedResults = List<Map<String, dynamic>>.from(results);
    if (_sortOrder == SortOrder.descending) {
      sortedResults.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    } else {
      sortedResults.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
    }
    return sortedResults;
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  Future<void> loadResults({
    required String type,
    String? levelId,
  }) async {
    try {
      final results = await _repository.loadResults(
        type: type,
        levelId: levelId,
      );

      if (type == 'measurements') {
        _measurementResults = results;
      } else if (type == 'levels') {
        _levelResults = results;
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка загрузки данных: $e');
      }
    }
  }

  Future<void> addResult({
    required String type,
    required double time,
    int? repetitions,
    int? errors,
    String? levelId,
    String? date,
  }) async {
    try {
      await _repository.addResult(
        type: type,
        time: time,
        repetitions: repetitions,
        errors: errors,
        levelId: levelId,
        date: date,
      );
      await loadResults(type: type, levelId: levelId);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при добавлении результата: $e');
      }
    }
  }

  Future<void> deleteResultById({
    required String id,
    required String type,
    String? levelId,
  }) async {
    try {
      await _repository.deleteResultById(
        id: id,
        type: type,
        levelId: levelId,
      );

      if (type == 'measurements') {
        _measurementResults.removeWhere((result) => result['id'] == id);
      } else if (type == 'levels') {
        _levelResults.removeWhere((result) => result['id'] == id);
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка удаления результата по ID: $e');
      }
    }
  }

  Future<void> clearResults() async {
    try {
      await _repository.clearResults();
      _measurementResults.clear();
      _levelResults.clear();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка очистки результатов: $e');
      }
    }
  }

  // Метод для получения выбранного количества повторений
  Future<int> getSelectedRepetitions() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedRepetitions = prefs.getInt('selectedRepetitions') ?? 5;
    notifyListeners();
    return prefs.getInt('selectedRepetitions') ?? 5;

  }

  void setSelectedRepetitions() async {
     final prefs = await SharedPreferences.getInstance();
    _selectedRepetitions = prefs.getInt('selectedRepetitions') ?? 5;
    notifyListeners();
  }
  
}
