import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/subscription_plan_model.dart';
import '../../data/models/subscription_status_model.dart';
import '../../data/repositories/subscription_repository_impl.dart';

final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlanModel>>((ref) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getSubscriptionPlans();
});

final subscriptionStatusProvider = StreamProvider<SubscriptionStatusModel?>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.subscriptionStatusStream();
});

final subscriptionServiceProvider = Provider((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionService(repository);
});

class SubscriptionService {
  final SubscriptionRepository _repository;
  
  SubscriptionService(this._repository);
  
  Future<void> createSubscriptionOrder(String planCode) async {
    await _repository.createOrder(planCode);
  }
  
  Future<void> verifyPayment(String orderId, String paymentId, String signature) async {
    await _repository.verifyPayment(orderId, paymentId, signature);
  }
  
  Future<void> cancelSubscription() async {
    await _repository.cancelSubscription();
  }
}

