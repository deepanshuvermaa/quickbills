class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  
  static const String apiVersion = '/api';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

class ApiEndpoints {
  static const String health = '/health';
  
  static const String authBase = '${ApiConfig.apiVersion}/auth';
  static const String authRegister = '$authBase/register';
  static const String authLogin = '$authBase/login';
  static const String authRefresh = '$authBase/refresh';
  
  static const String subscriptionsBase = '${ApiConfig.apiVersion}/subscriptions';
  static const String subscriptionsPlans = '$subscriptionsBase/plans';
  static const String subscriptionsStatus = '$subscriptionsBase/status';
  static const String subscriptionsCreateOrder = '$subscriptionsBase/create-order';
  static const String subscriptionsVerifyPayment = '$subscriptionsBase/verify-payment';
  static const String subscriptionsCancel = '$subscriptionsBase/cancel';
  
  static const String usageBase = '${ApiConfig.apiVersion}/usage';
  static const String usageLog = '$usageBase/log';
  static const String usageStats = '$usageBase/stats';
  static const String usageSync = '$usageBase/sync';
  static const String usageHealth = '$usageBase/health';
}