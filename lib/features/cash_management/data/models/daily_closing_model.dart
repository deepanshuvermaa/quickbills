import 'package:hive/hive.dart';

part 'daily_closing_model.g.dart';

@HiveType(typeId: 14)
class DailyClosingModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime date;
  
  @HiveField(2)
  final double openingCash;
  
  @HiveField(3)
  final double actualCash;
  
  @HiveField(4)
  final double totalSales;
  
  @HiveField(5)
  final double cashSales;
  
  @HiveField(6)
  final double cardSales;
  
  @HiveField(7)
  final double upiSales;
  
  @HiveField(8)
  final double totalExpenses;
  
  @HiveField(9)
  final double expectedCash;
  
  @HiveField(10)
  final double difference;
  
  @HiveField(11)
  final String? notes;
  
  @HiveField(12)
  final bool isDraft;
  
  @HiveField(13)
  final DateTime createdAt;
  
  @HiveField(14)
  final DateTime? closedAt;
  
  DailyClosingModel({
    required this.id,
    required this.date,
    required this.openingCash,
    required this.actualCash,
    required this.totalSales,
    required this.cashSales,
    required this.cardSales,
    required this.upiSales,
    required this.totalExpenses,
    required this.expectedCash,
    required this.difference,
    this.notes,
    required this.isDraft,
    required this.createdAt,
    this.closedAt,
  });
  
  DailyClosingModel copyWith({
    String? id,
    DateTime? date,
    double? openingCash,
    double? actualCash,
    double? totalSales,
    double? cashSales,
    double? cardSales,
    double? upiSales,
    double? totalExpenses,
    double? expectedCash,
    double? difference,
    String? notes,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? closedAt,
  }) {
    return DailyClosingModel(
      id: id ?? this.id,
      date: date ?? this.date,
      openingCash: openingCash ?? this.openingCash,
      actualCash: actualCash ?? this.actualCash,
      totalSales: totalSales ?? this.totalSales,
      cashSales: cashSales ?? this.cashSales,
      cardSales: cardSales ?? this.cardSales,
      upiSales: upiSales ?? this.upiSales,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      expectedCash: expectedCash ?? this.expectedCash,
      difference: difference ?? this.difference,
      notes: notes ?? this.notes,
      isDraft: isDraft ?? this.isDraft,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }
}