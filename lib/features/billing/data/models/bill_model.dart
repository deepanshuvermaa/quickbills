import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../presentation/screens/billing_screen.dart';
import '../../presentation/widgets/discount_dialog.dart';
import '../../presentation/widgets/split_payment_dialog.dart';
import '../../presentation/widgets/tax_settings_dialog.dart';

part 'bill_model.g.dart';

@HiveType(typeId: 6)
class BillModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String invoiceNumber;
  
  @HiveField(2)
  final List<BillItemModel> items;
  
  @HiveField(3)
  final double subtotal;
  
  @HiveField(4)
  final double discountAmount;
  
  @HiveField(5)
  final DiscountType? discountType;
  
  @HiveField(6)
  final double? discountValue;
  
  @HiveField(7)
  final double tax;
  
  @HiveField(8)
  final TaxType taxType;
  
  @HiveField(9)
  final double cgstRate;
  
  @HiveField(10)
  final double sgstRate;
  
  @HiveField(11)
  final double igstRate;
  
  @HiveField(12)
  final double total;
  
  @HiveField(13)
  final String paymentMethod;
  
  @HiveField(14)
  final List<PaymentSplitModel>? paymentSplits;
  
  @HiveField(15)
  final String? customerId;
  
  @HiveField(16)
  final String? customerName;
  
  @HiveField(17)
  final DateTime createdAt;
  
  @HiveField(18)
  final DateTime? updatedAt;
  
  @HiveField(19)
  final BillStatus status;
  
  @HiveField(20)
  final String? notes;

  BillModel({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    this.discountType,
    this.discountValue,
    required this.tax,
    required this.taxType,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.total,
    required this.paymentMethod,
    this.paymentSplits,
    this.customerId,
    this.customerName,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    this.notes,
  });

  factory BillModel.create({
    required List<CartItem> cartItems,
    required double subtotal,
    required double discountAmount,
    DiscountType? discountType,
    double? discountValue,
    required double tax,
    required TaxType taxType,
    required double cgstRate,
    required double sgstRate,
    required double igstRate,
    required double total,
    required String paymentMethod,
    List<PaymentSplit>? paymentSplits,
    String? customerId,
    String? customerName,
    BillStatus status = BillStatus.completed,
    String? notes,
  }) {
    final now = DateTime.now();
    return BillModel(
      id: const Uuid().v4(),
      invoiceNumber: 'INV-${now.millisecondsSinceEpoch}',
      items: cartItems.map((item) => BillItemModel.fromCartItem(item)).toList(),
      subtotal: subtotal,
      discountAmount: discountAmount,
      discountType: discountType,
      discountValue: discountValue,
      tax: tax,
      taxType: taxType,
      cgstRate: cgstRate,
      sgstRate: sgstRate,
      igstRate: igstRate,
      total: total,
      paymentMethod: paymentMethod,
      paymentSplits: paymentSplits?.map((split) => PaymentSplitModel.fromPaymentSplit(split)).toList(),
      customerId: customerId,
      customerName: customerName,
      createdAt: now,
      status: status,
      notes: notes,
    );
  }

  BillModel copyWith({
    String? invoiceNumber,
    List<BillItemModel>? items,
    double? subtotal,
    double? discountAmount,
    DiscountType? discountType,
    double? discountValue,
    double? tax,
    TaxType? taxType,
    double? cgstRate,
    double? sgstRate,
    double? igstRate,
    double? total,
    String? paymentMethod,
    List<PaymentSplitModel>? paymentSplits,
    String? customerId,
    String? customerName,
    DateTime? updatedAt,
    BillStatus? status,
    String? notes,
  }) {
    return BillModel(
      id: id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      tax: tax ?? this.tax,
      taxType: taxType ?? this.taxType,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      igstRate: igstRate ?? this.igstRate,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentSplits: paymentSplits ?? this.paymentSplits,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

@HiveType(typeId: 7)
class BillItemModel extends HiveObject {
  @HiveField(0)
  final String productId;
  
  @HiveField(1)
  final String productName;
  
  @HiveField(2)
  final double price;
  
  @HiveField(3)
  final int quantity;
  
  @HiveField(4)
  final double total;

  BillItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory BillItemModel.fromCartItem(CartItem cartItem) {
    return BillItemModel(
      productId: cartItem.product.id,
      productName: cartItem.product.name,
      price: cartItem.product.price,
      quantity: cartItem.quantity,
      total: cartItem.product.price * cartItem.quantity,
    );
  }
}

@HiveType(typeId: 8)
class PaymentSplitModel extends HiveObject {
  @HiveField(0)
  final String method;
  
  @HiveField(1)
  final double amount;

  PaymentSplitModel({
    required this.method,
    required this.amount,
  });

  factory PaymentSplitModel.fromPaymentSplit(PaymentSplit split) {
    return PaymentSplitModel(
      method: split.method,
      amount: split.amount,
    );
  }
}

@HiveType(typeId: 9)
enum BillStatus {
  @HiveField(0)
  draft,
  
  @HiveField(1)
  completed,
  
  @HiveField(2)
  cancelled,
  
  @HiveField(3)
  refunded,
}