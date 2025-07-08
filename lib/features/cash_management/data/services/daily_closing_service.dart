import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_closing_model.dart';

final dailyClosingServiceProvider = Provider<DailyClosingService>((ref) {
  return DailyClosingService();
});

class DailyClosingService {
  static const String _boxName = 'daily_closings';
  
  Future<Box<DailyClosingModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<DailyClosingModel>(_boxName);
    }
    return Hive.box<DailyClosingModel>(_boxName);
  }
  
  Future<void> saveDraft(DailyClosingModel closing) async {
    final box = await _getBox();
    final dateKey = closing.date.toIso8601String().split('T')[0];
    await box.put(dateKey, closing);
  }
  
  Future<void> closeDay(DailyClosingModel closing) async {
    final box = await _getBox();
    final dateKey = closing.date.toIso8601String().split('T')[0];
    final closedModel = closing.copyWith(
      isDraft: false,
      closedAt: DateTime.now(),
    );
    await box.put(dateKey, closedModel);
  }
  
  Future<DailyClosingModel?> getClosingForDate(DateTime date) async {
    final box = await _getBox();
    final dateKey = date.toIso8601String().split('T')[0];
    return box.get(dateKey);
  }
  
  Future<List<DailyClosingModel>> getAllClosings() async {
    final box = await _getBox();
    return box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  
  Future<List<DailyClosingModel>> getClosingsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final box = await _getBox();
    return box.values
        .where((closing) =>
            closing.date.isAfter(start.subtract(const Duration(days: 1))) &&
            closing.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  
  Future<double> getLastClosingCash() async {
    final closings = await getAllClosings();
    final completedClosings = closings.where((c) => !c.isDraft).toList();
    
    if (completedClosings.isEmpty) {
      return 0;
    }
    
    // Find the most recent completed closing
    completedClosings.sort((a, b) => b.date.compareTo(a.date));
    return completedClosings.first.actualCash;
  }
}