import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/export_history_model.dart';
import '../../data/services/export_service.dart';

final exportServiceProvider = Provider((ref) => ExportService());

final exportHistoryProvider = StreamProvider<List<ExportHistoryModel>>((ref) async* {
  final box = await Hive.openBox<ExportHistoryModel>(ExportService.exportHistoryBox);
  
  // Initial data
  yield box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  
  // Listen to changes
  await for (final event in box.watch()) {
    yield box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }
});