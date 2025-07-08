// Date range for reports
enum DateRangePreset {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  last30Days,
  last90Days,
  thisYear,
  custom,
}

class ReportDateRange {
  final DateTime startDate;
  final DateTime endDate;
  final DateRangePreset? preset;

  ReportDateRange({
    required this.startDate,
    required this.endDate,
    this.preset,
  });

  static ReportDateRange fromPreset(DateRangePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (preset) {
      case DateRangePreset.today:
        return ReportDateRange(
          startDate: today,
          endDate: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
          preset: preset,
        );
      case DateRangePreset.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return ReportDateRange(
          startDate: yesterday,
          endDate: today.subtract(const Duration(seconds: 1)),
          preset: preset,
        );
      case DateRangePreset.thisWeek:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        return ReportDateRange(
          startDate: monday,
          endDate: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
          preset: preset,
        );
      case DateRangePreset.lastWeek:
        final lastMonday = today.subtract(Duration(days: today.weekday + 6));
        final lastSunday = lastMonday.add(const Duration(days: 6));
        return ReportDateRange(
          startDate: lastMonday,
          endDate: lastSunday.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
          preset: preset,
        );
      case DateRangePreset.thisMonth:
        final firstDay = DateTime(today.year, today.month, 1);
        return ReportDateRange(
          startDate: firstDay,
          endDate: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
          preset: preset,
        );
      case DateRangePreset.lastMonth:
        final firstDay = DateTime(today.year, today.month - 1, 1);
        final lastDay = DateTime(today.year, today.month, 0);
        return ReportDateRange(
          startDate: firstDay,
          endDate: lastDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
          preset: preset,
        );
      case DateRangePreset.last30Days:
        return ReportDateRange(
          startDate: today.subtract(const Duration(days: 29)),
          endDate: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
          preset: preset,
        );
      case DateRangePreset.last90Days:
        return ReportDateRange(
          startDate: today.subtract(const Duration(days: 89)),
          endDate: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
          preset: preset,
        );
      case DateRangePreset.thisYear:
        final firstDay = DateTime(today.year, 1, 1);
        return ReportDateRange(
          startDate: firstDay,
          endDate: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
          preset: preset,
        );
      case DateRangePreset.custom:
        return ReportDateRange(
          startDate: today,
          endDate: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
          preset: preset,
        );
    }
  }

  String get label {
    if (preset != null && preset != DateRangePreset.custom) {
      switch (preset!) {
        case DateRangePreset.today:
          return 'Today';
        case DateRangePreset.yesterday:
          return 'Yesterday';
        case DateRangePreset.thisWeek:
          return 'This Week';
        case DateRangePreset.lastWeek:
          return 'Last Week';
        case DateRangePreset.thisMonth:
          return 'This Month';
        case DateRangePreset.lastMonth:
          return 'Last Month';
        case DateRangePreset.last30Days:
          return 'Last 30 Days';
        case DateRangePreset.last90Days:
          return 'Last 90 Days';
        case DateRangePreset.thisYear:
          return 'This Year';
        default:
          break;
      }
    }
    
    // Format custom date range
    final startStr = '${startDate.day}/${startDate.month}/${startDate.year}';
    final endStr = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$startStr - $endStr';
  }
}

// Sales Report Models
class SalesReportData {
  final double totalSales;
  final int totalBills;
  final int totalItems;
  final double totalProfit;
  final double averageBillValue;
  final List<HourlySalesData> hourlySales;
  final Map<String, double> paymentMethodBreakdown;
  final List<ProductSalesData> topProducts;
  final String? topSellingItem;
  final double profitMargin;
  
  SalesReportData({
    required this.totalSales,
    required this.totalBills,
    required this.totalItems,
    required this.totalProfit,
    required this.averageBillValue,
    required this.hourlySales,
    required this.paymentMethodBreakdown,
    required this.topProducts,
    this.topSellingItem,
    required this.profitMargin,
  });
}

class HourlySalesData {
  final int hour;
  final double amount;
  final int billCount;
  
  HourlySalesData({
    required this.hour,
    required this.amount,
    required this.billCount,
  });
}

class ProductSalesData {
  final String productId;
  final String productName;
  final int quantity;
  final double revenue;
  final double profit;
  
  ProductSalesData({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.revenue,
    required this.profit,
  });
}

// Inventory Report Models
class InventoryReportData {
  final double totalValue;
  final int totalItems;
  final int totalCategories;
  final List<StockAlertItem> outOfStock;
  final List<StockAlertItem> lowStock;
  final List<StockAlertItem> expiringSoon;
  final List<StockMovementData> stockMovements;
  final ABCAnalysisData abcAnalysis;
  
  InventoryReportData({
    required this.totalValue,
    required this.totalItems,
    required this.totalCategories,
    required this.outOfStock,
    required this.lowStock,
    required this.expiringSoon,
    required this.stockMovements,
    required this.abcAnalysis,
  });
}

class StockAlertItem {
  final String productId;
  final String productName;
  final int currentStock;
  final int reorderLevel;
  final DateTime? expiryDate;
  
  StockAlertItem({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.reorderLevel,
    this.expiryDate,
  });
}

class StockMovementData {
  final String productId;
  final String productName;
  final int openingStock;
  final int purchased;
  final int sold;
  final int returned;
  final int damaged;
  final int closingStock;
  final double stockValue;
  
  StockMovementData({
    required this.productId,
    required this.productName,
    required this.openingStock,
    required this.purchased,
    required this.sold,
    required this.returned,
    required this.damaged,
    required this.closingStock,
    required this.stockValue,
  });
}

class ABCAnalysisData {
  final ABCCategory aItems;
  final ABCCategory bItems;
  final ABCCategory cItems;
  
  ABCAnalysisData({
    required this.aItems,
    required this.bItems,
    required this.cItems,
  });
}

class ABCCategory {
  final List<String> productIds;
  final double value;
  final double percentage;
  final String category; // 'A', 'B', or 'C'
  
  ABCCategory({
    required this.productIds,
    required this.value,
    required this.percentage,
    required this.category,
  });
}

// Financial Report Models
class ProfitLossReportData {
  final RevenueData revenue;
  final COGSData costOfGoodsSold;
  final double grossProfit;
  final double grossProfitMargin;
  final ExpensesData expenses;
  final double netProfit;
  final double netProfitMargin;
  final List<CategoryProfitability> categoryProfitability;
  
  ProfitLossReportData({
    required this.revenue,
    required this.costOfGoodsSold,
    required this.grossProfit,
    required this.grossProfitMargin,
    required this.expenses,
    required this.netProfit,
    required this.netProfitMargin,
    required this.categoryProfitability,
  });
}

class RevenueData {
  final double grossSales;
  final double returns;
  final double discounts;
  final double netSales;
  
  RevenueData({
    required this.grossSales,
    required this.returns,
    required this.discounts,
    required this.netSales,
  });
}

class COGSData {
  final double openingStock;
  final double purchases;
  final double closingStock;
  final double totalCOGS;
  
  COGSData({
    required this.openingStock,
    required this.purchases,
    required this.closingStock,
    required this.totalCOGS,
  });
}

class ExpensesData {
  final Map<String, double> categories;
  final double total;
  
  ExpensesData({
    required this.categories,
    required this.total,
  });
}

class CategoryProfitability {
  final String category;
  final double revenue;
  final double cost;
  final double profit;
  final double margin;
  final double contribution;
  
  CategoryProfitability({
    required this.category,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.margin,
    required this.contribution,
  });
}

// Tax Report Models
class TaxReportData {
  final double totalSales;
  final double taxableSales;
  final OutputGSTData outputGST;
  final InputGSTData inputGST;
  final double netPayable;
  final List<HSNSummaryData> hsnSummary;
  
  TaxReportData({
    required this.totalSales,
    required this.taxableSales,
    required this.outputGST,
    required this.inputGST,
    required this.netPayable,
    required this.hsnSummary,
  });
}

class OutputGSTData {
  final double cgst;
  final double sgst;
  final double igst;
  final double total;
  
  OutputGSTData({
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.total,
  });
}

class InputGSTData {
  final double onPurchases;
  final double onExpenses;
  final double total;
  
  InputGSTData({
    required this.onPurchases,
    required this.onExpenses,
    required this.total,
  });
}

class HSNSummaryData {
  final String hsnCode;
  final String description;
  final double taxRate;
  final double taxableAmount;
  final double cgst;
  final double sgst;
  final double igst;
  
  HSNSummaryData({
    required this.hsnCode,
    required this.description,
    required this.taxRate,
    required this.taxableAmount,
    required this.cgst,
    required this.sgst,
    required this.igst,
  });
}

// Customer Report Models
class CustomerReportData {
  final int totalCustomers;
  final int activeCustomers;
  final int newThisMonth;
  final double churnRate;
  final CustomerSegmentation segmentation;
  final PurchasePatterns purchasePatterns;
  final List<CustomerCreditData> creditReport;
  
  CustomerReportData({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.newThisMonth,
    required this.churnRate,
    required this.segmentation,
    required this.purchasePatterns,
    required this.creditReport,
  });
}

class CustomerSegmentation {
  final List<String> vip; // Top 10%
  final List<String> regular; // Next 30%
  final List<String> occasional; // Next 40%
  final List<String> inactive; // Bottom 20%
  
  CustomerSegmentation({
    required this.vip,
    required this.regular,
    required this.occasional,
    required this.inactive,
  });
}

class PurchasePatterns {
  final double averageBasketSize;
  final double purchaseFrequency;
  final List<String> favoriteProducts;
  final String preferredPaymentMethod;
  
  PurchasePatterns({
    required this.averageBasketSize,
    required this.purchaseFrequency,
    required this.favoriteProducts,
    required this.preferredPaymentMethod,
  });
}

class CustomerCreditData {
  final String customerId;
  final String customerName;
  final String? phone;
  final double creditLimit;
  final double currentDue;
  final DateTime? lastPayment;
  final int daysOverdue;
  final CreditAging aging;
  
  CustomerCreditData({
    required this.customerId,
    required this.customerName,
    this.phone,
    required this.creditLimit,
    required this.currentDue,
    this.lastPayment,
    required this.daysOverdue,
    required this.aging,
  });
}

class CreditAging {
  final double current;
  final double days30;
  final double days60;
  final double days90Plus;
  
  CreditAging({
    required this.current,
    required this.days30,
    required this.days60,
    required this.days90Plus,
  });
}