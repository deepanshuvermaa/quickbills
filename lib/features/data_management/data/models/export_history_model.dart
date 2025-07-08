import 'package:hive/hive.dart';

part 'export_history_model.g.dart';

@HiveType(typeId: 20)
class ExportHistoryModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String type;
  
  @HiveField(2)
  final String format;
  
  @HiveField(3)
  final String paperSize;
  
  @HiveField(4)
  final DateTime date;
  
  @HiveField(5)
  final String status;
  
  @HiveField(6)
  final int records;
  
  @HiveField(7)
  final String filePath;
  
  @HiveField(8)
  final DateTime? dateRangeStart;
  
  @HiveField(9)
  final DateTime? dateRangeEnd;
  
  ExportHistoryModel({
    required this.id,
    required this.type,
    required this.format,
    required this.paperSize,
    required this.date,
    required this.status,
    required this.records,
    required this.filePath,
    this.dateRangeStart,
    this.dateRangeEnd,
  });
}