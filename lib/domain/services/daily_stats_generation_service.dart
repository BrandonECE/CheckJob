abstract class DailyStatsGenerationService {
  Future<bool> checkAndGenerateDailyStats();
  Future<void> forceGenerateDailyStats(DateTime date);
  Future<Map<String, dynamic>> calculateDailyMetrics(DateTime date);
  Future<bool> isGenerationNeeded(DateTime date);
}