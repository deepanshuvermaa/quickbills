abstract class UsageRepository {
  Future<void> logAction({
    required String action,
    Map<String, dynamic>? details,
    String? sessionId,
  });
  
  Future<void> syncOfflineLogs();
  
  Future<Map<String, dynamic>> getUsageStats({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Future<Map<String, dynamic>> getHealthMetrics();
}