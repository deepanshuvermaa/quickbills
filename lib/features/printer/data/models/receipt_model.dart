import 'package:esc_pos_utils/esc_pos_utils.dart';

class ReceiptModel {
  final String businessName;
  final String? businessAddress;
  final String? businessPhone;
  final String? taxNumber;
  final String? logoPath;
  final String invoiceNumber;
  final String date;
  final String? customerName;
  final String? customerPhone;
  final List<ReceiptItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double taxRate;
  final double total;
  final String paymentMethod;
  final String? footerText;
  final PaperSize paperSize;
  
  ReceiptModel({
    required this.businessName,
    this.businessAddress,
    this.businessPhone,
    this.taxNumber,
    this.logoPath,
    required this.invoiceNumber,
    required this.date,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    required this.tax,
    required this.taxRate,
    required this.total,
    required this.paymentMethod,
    this.footerText,
    this.paperSize = PaperSize.mm58,
  });
}

class ReceiptItem {
  final String name;
  final int quantity;
  final double price;
  final double total;
  
  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });
}