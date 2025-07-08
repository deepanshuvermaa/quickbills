import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_status_model.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(ref.read(apiClientProvider));
});

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans();
  Future<SubscriptionStatusModel> getSubscriptionStatus();
  Stream<SubscriptionStatusModel?> subscriptionStatusStream();
  Future<Map<String, dynamic>> createOrder(String planCode);
  Future<void> verifyPayment(String orderId, String paymentId, String signature);
  Future<void> cancelSubscription();
}

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final ApiClient _apiClient;
  final _statusController = StreamController<SubscriptionStatusModel?>.broadcast();
  Timer? _statusTimer;
  
  SubscriptionRepositoryImpl(this._apiClient) {
    _startStatusPolling();
  }
  
  void _startStatusPolling() {
    _fetchStatus();
    _statusTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _fetchStatus();
    });
  }
  
  Future<void> _fetchStatus() async {
    try {
      final status = await getSubscriptionStatus();
      _statusController.add(status);
    } catch (e) {
      _statusController.add(null);
    }
  }
  
  @override
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.subscriptionsPlans,
      );
      
      final plans = (response.data['plans'] as List)
          .map((plan) => SubscriptionPlanModel.fromJson(plan))
          .toList();
      
      return plans;
    } on DioException catch (e) {
      throw e.error ?? Exception('Failed to get subscription plans');
    }
  }
  
  @override
  Future<SubscriptionStatusModel> getSubscriptionStatus() async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.subscriptionsStatus,
      );
      
      return SubscriptionStatusModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error ?? Exception('Failed to get subscription status');
    }
  }
  
  @override
  Stream<SubscriptionStatusModel?> subscriptionStatusStream() {
    return _statusController.stream;
  }
  
  @override
  Future<Map<String, dynamic>> createOrder(String planCode) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.subscriptionsCreateOrder,
        data: {'planCode': planCode},
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error ?? Exception('Failed to create order');
    }
  }
  
  @override
  Future<void> verifyPayment(String orderId, String paymentId, String signature) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.subscriptionsVerifyPayment,
        data: {
          'orderId': orderId,
          'paymentId': paymentId,
          'signature': signature,
        },
      );
      
      _fetchStatus();
    } on DioException catch (e) {
      throw e.error ?? Exception('Failed to verify payment');
    }
  }
  
  @override
  Future<void> cancelSubscription() async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.subscriptionsCancel,
      );
      
      _fetchStatus();
    } on DioException catch (e) {
      throw e.error ?? Exception('Failed to cancel subscription');
    }
  }
  
  void dispose() {
    _statusTimer?.cancel();
    _statusController.close();
  }
}