import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/report_models.dart';
import '../../data/services/report_service.dart';

// Report Service Provider
final reportServiceProvider = Provider((ref) => ReportService());

// Date Range Provider
final selectedDateRangeProvider = StateProvider<ReportDateRange>((ref) {
  return ReportDateRange.fromPreset(DateRangePreset.today);
});

// Sales Report Provider
final salesReportProvider = FutureProvider<SalesReportData>((ref) async {
  final reportService = ref.read(reportServiceProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return await reportService.generateSalesReport(dateRange);
});

// Inventory Report Provider
final inventoryReportProvider = FutureProvider<InventoryReportData>((ref) async {
  final reportService = ref.read(reportServiceProvider);
  return await reportService.generateInventoryReport();
});

// Profit & Loss Report Provider
final profitLossReportProvider = FutureProvider<ProfitLossReportData>((ref) async {
  final reportService = ref.read(reportServiceProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return await reportService.generateProfitLossReport(dateRange);
});

// Tax Report Provider
final taxReportProvider = FutureProvider<TaxReportData>((ref) async {
  final reportService = ref.read(reportServiceProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return await reportService.generateTaxReport(dateRange);
});

// Customer Report Provider
final customerReportProvider = FutureProvider<CustomerReportData>((ref) async {
  final reportService = ref.read(reportServiceProvider);
  return await reportService.generateCustomerReport();
});

// Report Export Provider
enum ExportFormat { pdf, excel, csv }

final reportExportProvider = Provider((ref) => ReportExportService());

class ReportExportService {
  Future<void> exportReport({
    required String reportType,
    required ExportFormat format,
    required dynamic reportData,
  }) async {
    // TODO: Implement actual export functionality
    // For now, we'll just simulate the export
    await Future.delayed(const Duration(seconds: 1));
    
    switch (format) {
      case ExportFormat.pdf:
        // Generate PDF
        break;
      case ExportFormat.excel:
        // Generate Excel
        break;
      case ExportFormat.csv:
        // Generate CSV
        break;
    }
  }
}

// Report Filter Providers
final salesFilterProvider = StateProvider((ref) => SalesReportFilter());

class SalesReportFilter {
  final String? paymentMethod;
  final String? billStatus;
  final String? customerType;
  final double? minAmount;
  final double? maxAmount;
  final List<String> categories;

  SalesReportFilter({
    this.paymentMethod,
    this.billStatus,
    this.customerType,
    this.minAmount,
    this.maxAmount,
    this.categories = const [],
  });

  SalesReportFilter copyWith({
    String? paymentMethod,
    String? billStatus,
    String? customerType,
    double? minAmount,
    double? maxAmount,
    List<String>? categories,
  }) {
    return SalesReportFilter(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      billStatus: billStatus ?? this.billStatus,
      customerType: customerType ?? this.customerType,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      categories: categories ?? this.categories,
    );
  }
}

final inventoryFilterProvider = StateProvider((ref) => InventoryReportFilter());

class InventoryReportFilter {
  final String? stockStatus;
  final List<String> categories;
  final List<String> suppliers;
  final double? minPrice;
  final double? maxPrice;

  InventoryReportFilter({
    this.stockStatus,
    this.categories = const [],
    this.suppliers = const [],
    this.minPrice,
    this.maxPrice,
  });

  InventoryReportFilter copyWith({
    String? stockStatus,
    List<String>? categories,
    List<String>? suppliers,
    double? minPrice,
    double? maxPrice,
  }) {
    return InventoryReportFilter(
      stockStatus: stockStatus ?? this.stockStatus,
      categories: categories ?? this.categories,
      suppliers: suppliers ?? this.suppliers,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}