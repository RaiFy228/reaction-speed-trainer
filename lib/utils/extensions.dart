import 'package:reaction_speed_trainer/models/reaction_result.dart';

extension ReactionResultExtensions on ReactionResult {
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'reactionTime': reactionTime,
  };
}