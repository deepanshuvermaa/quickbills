import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 10)
class SubscriptionModel extends HiveObject {
  @HiveField(0)
  final String plan;
  
  @HiveField(1)
  final String status;
  
  @HiveField(2)
  final DateTime startDate;
  
  @HiveField(3)
  final DateTime endDate;
  
  @HiveField(4)
  final List<String> features;
  
  @HiveField(5)
  final double? price;
  
  @HiveField(6)
  final String? billingCycle;

  SubscriptionModel({
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.features,
    this.price,
    this.billingCycle,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      plan: json['plan'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      features: List<String>.from(json['features'] as List),
      price: (json['price'] as num?)?.toDouble(),
      billingCycle: json['billingCycle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'features': features,
      'price': price,
      'billingCycle': billingCycle,
    };
  }

  SubscriptionModel copyWith({
    String? plan,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? features,
    double? price,
    String? billingCycle,
  }) {
    return SubscriptionModel(
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      features: features ?? this.features,
      price: price ?? this.price,
      billingCycle: billingCycle ?? this.billingCycle,
    );
  }

  bool get isActive => status == 'active';
  
  bool get isExpired => endDate.isBefore(DateTime.now());
  
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}