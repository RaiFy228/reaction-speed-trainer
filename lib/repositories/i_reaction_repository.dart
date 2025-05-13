abstract class IReactionRepository {
  Future<void> addResult({
    required int exerciseTypeId,
    required double time,
    int? repetitions,
    int? errors,
    String? date,
    required List<Map<String, dynamic>> details,
  });

  Future<List<Map<String, dynamic>>> loadResults({
    required int exerciseTypeId,
  });

  Future<void> deleteResultById({
    required String id,
    required int exerciseTypeId,
  });

  Future<void> clearResults({
    required int exerciseTypeId,
  });
   Future<List<Map<String, dynamic>>> loadAllResults();
}