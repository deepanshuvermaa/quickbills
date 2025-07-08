import 'package:hive/hive.dart';
import '../../../billing/presentation/screens/billing_screen.dart';

part 'quotation_model.g.dart';

@HiveType(typeId: 12)
class QuotationModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String quotationNumber;
  
  @HiveField(2)
  final DateTime createdDate;
  
  @HiveField(3)
  final DateTime validityDate;
  
  @HiveField(4)
  final String? customerId;
  
  @HiveField(5)
  final String? customerName;
  
  @HiveField(6)
  final String? customerPhone;
  
  @HiveField(7)
  final String? customerEmail;
  
  @HiveField(8)
  final List<QuotationItem> items;
  
  @HiveField(9)
  final double subtotal;
  
  @HiveField(10)
  final double discount;
  
  @HiveField(11)
  final double tax;
  
  @HiveField(12)
  final double total;
  
  @HiveField(13)
  final String status; // draft, sent, accepted, rejected, expired
  
  @HiveField(14)
  final String? notes;
  
  @HiveField(15)
  final String? terms;
  
  @HiveField(16)
  final DateTime? convertedDate;
  
  @HiveField(17)
  final String? convertedBillId;
  
  @HiveField(18)
  final Map<String, dynamic>? taxDetails;
  
  QuotationModel({
    required this.id,
    required this.quotationNumber,
    required this.createdDate,
    required this.validityDate,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.status,
    this.notes,
    this.terms,
    this.convertedDate,
    this.convertedBillId,
    this.taxDetails,
  });
  
  factory QuotationModel.create({
    required DateTime validityDate,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    required List<QuotationItem> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    String? notes,
    String? terms,
    Map<String, dynamic>? taxDetails,
  }) {
    final now = DateTime.now();
    final quotationNumber = 'QT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
    
    return QuotationModel(
      id: now.millisecondsSinceEpoch.toString(),
      quotationNumber: quotationNumber,
      createdDate: now,
      validityDate: validityDate,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      status: 'draft',
      notes: notes,
      terms: terms,
      taxDetails: taxDetails,
    );
  }
  
  bool get isExpired => DateTime.now().isAfter(validityDate);
  bool get isConverted => convertedBillId != null;
  int get daysUntilExpiry => validityDate.difference(DateTime.now()).inDays;
  
  QuotationModel copyWith({
    DateTime? validityDate,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    List<QuotationItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    String? status,
    String? notes,
    String? terms,
    DateTime? convertedDate,
    String? convertedBillId,
    Map<String, dynamic>? taxDetails,
  }) {
    return QuotationModel(
      id: id,
      quotationNumber: quotationNumber,
      createdDate: createdDate,
      validityDate: validityDate ?? this.validityDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      convertedDate: convertedDate ?? this.convertedDate,
      convertedBillId: convertedBillId ?? this.convertedBillId,
      taxDetails: taxDetails ?? this.taxDetails,
    );
  }
}

@HiveType(typeId: 13)
class QuotationItem {
  @HiveField(0)
  final String productId;
  
  @HiveField(1)
  final String productName;
  
  @HiveField(2)
  final double price;
  
  @HiveField(3)
  final int quantity;
  
  @HiveField(4)
  final double discount;
  
  @HiveField(5)
  final double total;
  
  QuotationItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.discount = 0,
    required this.total,
  });
  
  factory QuotationItem.fromCartItem(CartItem cartItem) {
    final subtotal = cartItem.product.price * cartItem.quantity;
    return QuotationItem(
      productId: cartItem.product.id,
      productName: cartItem.product.name,
      price: cartItem.product.price,
      quantity: cartItem.quantity,
      discount: 0,
      total: subtotal,
    );
  }
}