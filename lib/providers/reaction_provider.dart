import 'package:flutter/material.dart';
import '../models/reaction_result.dart';

class ReactionProvider with ChangeNotifier {
  final List<ReactionResult> _results = [];

  List<ReactionResult> get results => _results;

  double get bestResult {
    if (_results.isEmpty) return 0.0;
    return _results.map((r) => r.reactionTime).reduce((a, b) => a < b ? a : b);
  }

  void addResult(double reactionTime) {
    _results.add(ReactionResult(date: DateTime.now(), reactionTime: reactionTime));
    notifyListeners();
  }
}