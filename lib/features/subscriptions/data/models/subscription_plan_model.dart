class SubscriptionPlanModel {
  final int id;
  final String planCode;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final Map<String, dynamic> features;
  final bool isActive;
  final int displayOrder;
  
  SubscriptionPlanModel({
    required this.id,
    required this.planCode,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.features,
    required this.isActive,
    required this.displayOrder,
  });
  
  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as int,
      planCode: json['plan_code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationDays: json['duration_days'] as int,
      features: json['features'] as Map<String, dynamic>,
      isActive: json['is_active'] as bool,
      displayOrder: json['display_order'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_code': planCode,
      'name': name,
      'description': description,
      'price': price,
      'duration_days': durationDays,
      'features': features,
      'is_active': isActive,
      'display_order': displayOrder,
    };
  }
  
  bool get isFree => planCode == 'trial';
  
  String get formattedPrice {
    if (isFree) return 'Free';
    return '₹${price.toStringAsFixed(0)}';
  }
  
  String get duration {
    if (durationDays == 30) return 'Monthly';
    if (durationDays == 90) return 'Quarterly';
    if (durationDays == 365) return 'Yearly';
    return '$durationDays days';
  }
}