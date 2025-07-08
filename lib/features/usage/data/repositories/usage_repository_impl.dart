import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../domain/repositories/usage_repository.dart';
import '../models/usage_log_model.dart';

final usageRepositoryProvider = Provider<UsageRepository>((ref) {
  return UsageRepositoryImpl(ref.read(apiClientProvider));
});

class UsageRepositoryImpl implements UsageRepository {
  final ApiClient _apiClient;
  late Box<UsageLogModel> _usageBox;
  
  UsageRepositoryImpl(this._apiClient) {
    _initializeBox();
  }
  
  Future<void> _initializeBox() async {
    _usageBox = await Hive.openBox<UsageLogModel>('usage_logs');
  }
  
  @override
  Future<void> logAction({
    required String action,
    Map<String, dynamic>? details,
    String? sessionId,
  }) async {
    final log = UsageLogModel.create(
      action: action,
      details: details,
      sessionId: sessionId,
    );
    
    await _usageBox.put(log.id, log);
    
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await _syncSingleLog(log);
    }
  }
  
  @override
  Future<void> syncOfflineLogs() async {
    final unsyncedLogs = _usageBox.values
        .where((log) => !log.isSynced)
        .toList();
    
    if (unsyncedLogs.isEmpty) return;
    
    try {
      final logsData = unsyncedLogs.map((log) => log.toJson()).toList();
      
      await _apiClient.dio.post(
        ApiEndpoints.usageSync,
        data: {'activities': logsData},
      );
      
      for (final log in unsyncedLogs) {
        log.save();
        await _usageBox.put(
          log.id,
          log.copyWith(isSynced: true),
        );
      }
      
      await _cleanOldLogs();
    } catch (e) {
      print('Failed to sync usage logs: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getUsageStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.usageStats,
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error ?? Exception('Failed to get usage stats');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getHealthMetrics() async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.usageHealth,
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error ?? Exception('Failed to get health metrics');
    }
  }
  
  Future<void> _syncSingleLog(UsageLogModel log) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.usageLog,
        data: log.toJson(),
      );
      
      await _usageBox.put(
        log.id,
        log.copyWith(isSynced: true),
      );
    } catch (e) {
      print('Failed to sync single log: $e');
    }
  }
  
  Future<void> _cleanOldLogs() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final oldLogs = _usageBox.values
        .where((log) => log.isSynced && log.timestamp.isBefore(thirtyDaysAgo))
        .toList();
    
    for (final log in oldLogs) {
      await log.delete();
    }
  }
}