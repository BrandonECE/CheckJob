
import 'package:check_job/domain/entities/statistics_entity.dart';

abstract class DailyStatsGenerationRepository {
  Future<bool> needsDailyGeneration(DateTime date);
  Future<void> generateDailyStatistics(DateTime date);
  Future<List<String>> getMissingMetricsForDate(DateTime date);
  Future<void> saveDailyMetric(StatisticEntity statistic);
  Future<DateTime?> getLastGenerationDate();
  Future<void> updateLastGenerationDate(DateTime date);
}