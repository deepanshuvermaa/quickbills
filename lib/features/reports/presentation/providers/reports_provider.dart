import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/report_service.dart';
import '../../data/models/report_models.dart';

final reportServiceProvider = Provider((ref) => ReportService());

// Sales report provider for a date range
final salesReportProvider = FutureProvider.family<SalesReportData, ReportDateRange>((ref, dateRange) async {
  final service = ref.read(reportServiceProvider);
  return await service.generateSalesReport(dateRange);
});

// Inventory report provider
final inventoryReportProvider = FutureProvider<InventoryReportData>((ref) async {
  final service = ref.read(reportServiceProvider);
  return await service.generateInventoryReport();
});

// Profit & Loss report provider
final profitLossReportProvider = FutureProvider.family<ProfitLossReportData, ReportDateRange>((ref, dateRange) async {
  final service = ref.read(reportServiceProvider);
  return await service.generateProfitLossReport(dateRange);
});

// Tax report provider
final taxReportProvider = FutureProvider.family<TaxReportData, ReportDateRange>((ref, dateRange) async {
  final service = ref.read(reportServiceProvider);
  return await service.generateTaxReport(dateRange);
});

// Customer report provider
final customerReportProvider = FutureProvider<CustomerReportData>((ref) async {
  final service = ref.read(reportServiceProvider);
  return await service.generateCustomerReport();
});

// Helper provider for current date range
final currentDateRangeProvider = StateProvider<ReportDateRange>((ref) {
  final now = DateTime.now();
  return ReportDateRange(
    startDate: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7)),
    endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
  );
});