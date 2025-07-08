class SubscriptionStatusModel {
  final bool hasActiveSubscription;
  final SubscriptionDetails? subscription;
  final int daysRemaining;
  final bool isInGracePeriod;
  final String? nextPlanCode;
  
  SubscriptionStatusModel({
    required this.hasActiveSubscription,
    this.subscription,
    required this.daysRemaining,
    required this.isInGracePeriod,
    this.nextPlanCode,
  });
  
  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatusModel(
      hasActiveSubscription: json['hasActiveSubscription'] as bool,
      subscription: json['subscription'] != null
          ? SubscriptionDetails.fromJson(json['subscription'] as Map<String, dynamic>)
          : null,
      daysRemaining: json['daysRemaining'] as int,
      isInGracePeriod: json['isInGracePeriod'] as bool,
      nextPlanCode: json['nextPlanCode'] as String?,
    );
  }
}

class SubscriptionDetails {
  final int id;
  final String planCode;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final bool autoRenew;
  final Map<String, dynamic> features;
  
  SubscriptionDetails({
    required this.id,
    required this.planCode,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.autoRenew,
    required this.features,
  });
  
  factory SubscriptionDetails.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetails(
      id: json['id'] as int,
      planCode: json['plan_code'] as String,
      planName: json['plan_name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
      autoRenew: json['auto_renew'] as bool,
      features: json['features'] as Map<String, dynamic>,
    );
  }
  
  bool get isExpired => endDate.isBefore(DateTime.now());
  bool get isActive => status == 'active' && !isExpired;
}