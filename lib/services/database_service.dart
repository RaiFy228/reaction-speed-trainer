import 'dart:convert';

import 'package:reaction_speed_trainer/models/reaction_result.dart';
import 'package:reaction_speed_trainer/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static const String keyResults = 'reaction_results';

  Future<void> saveResult(ReactionResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getString(keyResults) ?? '[]';
    final resultsList = jsonDecode(resultsJson) as List<dynamic>;
    resultsList.add(result.toJson());
    await prefs.setString(keyResults, jsonEncode(resultsList));
  }

  Future<List<ReactionResult>> getAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getString(keyResults) ?? '[]';
    final resultsList = jsonDecode(resultsJson) as List<dynamic>;
    return resultsList.map((json) => ReactionResult.fromJson(json)).toList();
  }
}