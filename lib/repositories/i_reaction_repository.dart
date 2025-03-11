abstract class IReactionRepository {
  Future<void> addResult({
    required String type,
    required double time,
    int? repetitions,
    int? errors,
    String? levelId,
    String? date,
  });

  Future<List<Map<String, dynamic>>> loadResults({
    required String type,
    String? levelId,
  });

  Future<void> deleteResultById({
    required String id,
    required String type,
    String? levelId,
  });

  Future<void> clearResults();
}