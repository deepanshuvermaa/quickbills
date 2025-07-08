class ProductVariant {
  final String id;
  final String name;
  final String value;
  final double priceAdjustment;
  final int stockQuantity;
  final String? sku;
  final String? barcode;
  
  ProductVariant({
    required this.id,
    required this.name,
    required this.value,
    this.priceAdjustment = 0,
    required this.stockQuantity,
    this.sku,
    this.barcode,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'value': value,
    'priceAdjustment': priceAdjustment,
    'stockQuantity': stockQuantity,
    'sku': sku,
    'barcode': barcode,
  };
  
  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
    id: json['id'],
    name: json['name'],
    value: json['value'],
    priceAdjustment: (json['priceAdjustment'] ?? 0).toDouble(),
    stockQuantity: json['stockQuantity'] ?? 0,
    sku: json['sku'],
    barcode: json['barcode'],
  );
}

class VariantGroup {
  final String name;
  final List<String> options;
  
  VariantGroup({
    required this.name,
    required this.options,
  });
}