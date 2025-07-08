import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/usage_repository_impl.dart';
import '../../domain/repositories/usage_repository.dart';

final usageTrackerProvider = Provider<UsageTracker>((ref) {
  final repository = ref.watch(usageRepositoryProvider);
  return UsageTracker(repository);
});

class UsageTracker {
  final UsageRepository _repository;
  String? _sessionId;
  
  UsageTracker(this._repository) {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  Future<void> trackAction(String action, {Map<String, dynamic>? details}) async {
    await _repository.logAction(
      action: action,
      details: details,
      sessionId: _sessionId,
    );
  }
  
  Future<void> trackScreenView(String screenName) async {
    await trackAction('screen_view', details: {'screen': screenName});
  }
  
  Future<void> trackButtonClick(String buttonName, {Map<String, dynamic>? additionalDetails}) async {
    await trackAction('button_click', details: {
      'button': buttonName,
      ...?additionalDetails,
    });
  }
  
  Future<void> trackError(String error, {String? stackTrace}) async {
    await trackAction('error', details: {
      'error': error,
      'stackTrace': stackTrace,
    });
  }
  
  Future<void> syncOfflineData() async {
    await _repository.syncOfflineLogs();
  }
}