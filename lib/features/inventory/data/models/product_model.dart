import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 2)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final String barcode;
  
  @HiveField(4)
  final String category;
  
  @HiveField(5)
  final String? subCategory;
  
  @HiveField(6)
  final double purchasePrice;
  
  @HiveField(7)
  final double sellingPrice;
  
  @HiveField(8)
  final int currentStock;
  
  @HiveField(9)
  final int minStock;
  
  @HiveField(10)
  final String unit;
  
  @HiveField(11)
  final double? taxRate;
  
  @HiveField(12)
  final bool isActive;
  
  @HiveField(13)
  final String? imageUrl;
  
  @HiveField(14)
  final DateTime createdAt;
  
  @HiveField(15)
  final DateTime? updatedAt;
  
  @HiveField(16)
  final Map<String, dynamic>? variants;
  
  @HiveField(17)
  final String? supplier;
  
  @HiveField(18)
  final String? sku;
  
  @HiveField(19)
  final int? lowStockAlert;
  
  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.barcode,
    required this.category,
    this.subCategory,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    this.taxRate,
    this.isActive = true,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.variants,
    this.supplier,
    this.sku,
    this.lowStockAlert,
  });
  
  factory ProductModel.create({
    required String name,
    String? description,
    required String barcode,
    required String category,
    String? subCategory,
    required double purchasePrice,
    required double sellingPrice,
    required int currentStock,
    required int minStock,
    required String unit,
    double? taxRate,
    String? imageUrl,
    Map<String, dynamic>? variants,
    String? supplier,
    String? sku,
    int? lowStockAlert,
  }) {
    // Generate unique ID using timestamp + random component
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (1000 + (timestamp % 9000)).toString();
    return ProductModel(
      id: '$timestamp$random${barcode.hashCode}',
      name: name,
      description: description,
      barcode: barcode,
      category: category,
      subCategory: subCategory,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      currentStock: currentStock,
      minStock: minStock,
      unit: unit,
      taxRate: taxRate,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      variants: variants,
      supplier: supplier,
      sku: sku,
      lowStockAlert: lowStockAlert,
    );
  }
  
  double get profit => sellingPrice - purchasePrice;
  double get profitMargin => (profit / sellingPrice) * 100;
  bool get isLowStock => currentStock <= minStock;
  bool get isOutOfStock => currentStock == 0;
  
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? barcode,
    String? category,
    String? subCategory,
    double? purchasePrice,
    double? sellingPrice,
    int? currentStock,
    int? minStock,
    String? unit,
    double? taxRate,
    bool? isActive,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? variants,
    String? supplier,
    String? sku,
    int? lowStockAlert,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      taxRate: taxRate ?? this.taxRate,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      variants: variants ?? this.variants,
      supplier: supplier ?? this.supplier,
      sku: sku ?? this.sku,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'barcode': barcode,
      'category': category,
      'subCategory': subCategory,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'currentStock': currentStock,
      'minStock': minStock,
      'unit': unit,
      'taxRate': taxRate,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'variants': variants,
      'supplier': supplier,
    };
  }
}