import 'package:hive/hive.dart';
import 'subscription_model.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String? phone;
  
  @HiveField(4)
  final String role;
  
  @HiveField(5)
  final String? businessId;
  
  @HiveField(10)
  final String? businessName;
  
  @HiveField(6)
  final bool isActive;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime? lastLoginAt;
  
  @HiveField(9)
  final Map<String, dynamic>? permissions;
  
  @HiveField(11)
  final SubscriptionModel? subscription;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.role = 'user',
    this.businessId,
    this.businessName,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    this.permissions,
    this.subscription,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      businessId: json['businessId'] as String?,
      businessName: json['businessName'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      permissions: json['permissions'] as Map<String, dynamic>?,
      subscription: json['subscription'] != null
          ? SubscriptionModel.fromJson(json['subscription'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'businessId': businessId,
      'businessName': businessName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'permissions': permissions,
      'subscription': subscription?.toJson(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? businessId,
    String? businessName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? permissions,
    SubscriptionModel? subscription,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      permissions: permissions ?? this.permissions,
      subscription: subscription ?? this.subscription,
    );
  }
}