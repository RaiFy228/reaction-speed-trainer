class ReactionResult {
  final DateTime date;
  final double reactionTime;

  ReactionResult({required this.date, required this.reactionTime});

  factory ReactionResult.fromJson(Map<String, dynamic> json) {
    return ReactionResult(
      date: DateTime.parse(json['date']),
      reactionTime: json['reactionTime'],
    );
  }
}