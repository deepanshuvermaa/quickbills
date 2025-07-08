import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 3)
class CustomerModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? email;
  
  @HiveField(3)
  final String? phone;
  
  @HiveField(4)
  final String? address;
  
  @HiveField(5)
  final String? gstNumber;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final DateTime? updatedAt;
  
  @HiveField(8)
  final double totalPurchases;
  
  @HiveField(9)
  final int totalTransactions;
  
  @HiveField(10)
  final bool isActive;
  
  @HiveField(11)
  final DateTime? lastPurchaseDate;
  
  CustomerModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.gstNumber,
    required this.createdAt,
    this.updatedAt,
    this.totalPurchases = 0,
    this.totalTransactions = 0,
    this.isActive = true,
    this.lastPurchaseDate,
  });
  
  factory CustomerModel.create({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? gstNumber,
  }) {
    return CustomerModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      address: address,
      gstNumber: gstNumber,
      createdAt: DateTime.now(),
      totalPurchases: 0,
      totalTransactions: 0,
      lastPurchaseDate: null,
    );
  }
  
  CustomerModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? gstNumber,
    DateTime? updatedAt,
    double? totalPurchases,
    int? totalTransactions,
    bool? isActive,
    DateTime? lastPurchaseDate,
  }) {
    return CustomerModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      isActive: isActive ?? this.isActive,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
    );
  }
}