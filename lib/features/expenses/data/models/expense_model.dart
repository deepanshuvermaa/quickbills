import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 5)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final double amount;
  
  @HiveField(4)
  final DateTime date;
  
  @HiveField(5)
  final String? description;
  
  @HiveField(6)
  final String paymentMethod;
  
  @HiveField(7)
  final String? receiptUrl;
  
  @HiveField(8)
  final bool isRecurring;
  
  @HiveField(9)
  final String? recurringFrequency;
  
  @HiveField(10)
  final String? vendor;
  
  @HiveField(11)
  final DateTime createdAt;
  
  ExpenseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    required this.paymentMethod,
    this.receiptUrl,
    this.isRecurring = false,
    this.recurringFrequency,
    this.vendor,
    required this.createdAt,
  });
  
  factory ExpenseModel.create({
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    String? description,
    required String paymentMethod,
    String? receiptUrl,
    bool isRecurring = false,
    String? recurringFrequency,
    String? vendor,
  }) {
    return ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      amount: amount,
      date: date,
      description: description,
      paymentMethod: paymentMethod,
      receiptUrl: receiptUrl,
      isRecurring: isRecurring,
      recurringFrequency: recurringFrequency,
      vendor: vendor,
      createdAt: DateTime.now(),
    );
  }
  
  ExpenseModel copyWith({
    String? title,
    String? category,
    double? amount,
    DateTime? date,
    String? description,
    String? paymentMethod,
    String? receiptUrl,
    bool? isRecurring,
    String? recurringFrequency,
    String? vendor,
  }) {
    return ExpenseModel(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      vendor: vendor ?? this.vendor,
      createdAt: createdAt,
    );
  }
}

class ExpenseCategory {
  static const String rent = 'Rent';
  static const String salaries = 'Salaries';
  static const String utilities = 'Utilities';
  static const String purchase = 'Purchase';
  static const String marketing = 'Marketing';
  static const String maintenance = 'Maintenance';
  static const String transport = 'Transport';
  static const String other = 'Other';
  
  static List<String> get all => [
    rent,
    salaries,
    utilities,
    purchase,
    marketing,
    maintenance,
    transport,
    other,
  ];
}