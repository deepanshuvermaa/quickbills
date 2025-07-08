import 'package:hive/hive.dart';
import '../models/report_models.dart';
import '../../../billing/data/models/bill_model.dart';
import '../../../inventory/data/models/product_model.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../billing/presentation/widgets/tax_settings_dialog.dart';
import '../../../../core/constants/app_constants.dart';

class ReportService {
  Box<BillModel>? _billsBox;
  Box<ProductModel>? _productsBox;
  Box<CustomerModel>? _customersBox;

  Future<Box<BillModel>> _getBillsBox() async {
    if (_billsBox != null && _billsBox!.isOpen) {
      return _billsBox!;
    }
    
    if (Hive.isBoxOpen(AppConstants.billsBox)) {
      _billsBox = Hive.box<BillModel>(AppConstants.billsBox);
    } else {
      _billsBox = await Hive.openBox<BillModel>(AppConstants.billsBox);
    }
    
    return _billsBox!;
  }

  Future<Box<ProductModel>> _getProductsBox() async {
    if (_productsBox != null && _productsBox!.isOpen) {
      return _productsBox!;
    }
    
    if (Hive.isBoxOpen(AppConstants.productsBox)) {
      _productsBox = Hive.box<ProductModel>(AppConstants.productsBox);
    } else {
      _productsBox = await Hive.openBox<ProductModel>(AppConstants.productsBox);
    }
    
    return _productsBox!;
  }

  Future<Box<CustomerModel>> _getCustomersBox() async {
    if (_customersBox != null && _customersBox!.isOpen) {
      return _customersBox!;
    }
    
    if (Hive.isBoxOpen(AppConstants.customersBox)) {
      _customersBox = Hive.box<CustomerModel>(AppConstants.customersBox);
    } else {
      _customersBox = await Hive.openBox<CustomerModel>(AppConstants.customersBox);
    }
    
    return _customersBox!;
  }

  // Sales Reports
  Future<SalesReportData> generateSalesReport(ReportDateRange dateRange) async {
    final billsBox = await _getBillsBox();
    final bills = billsBox.values.where((bill) {
      return bill.createdAt.isAfter(dateRange.startDate) &&
             bill.createdAt.isBefore(dateRange.endDate) &&
             bill.status == BillStatus.completed;
    }).toList();

    // Calculate totals
    double totalSales = 0;
    int totalItems = 0;
    double totalProfit = 0;
    final Map<String, double> paymentBreakdown = {};
    final Map<int, HourlySalesData> hourlySalesMap = {};
    final Map<String, ProductSalesData> productSalesMap = {};

    for (final bill in bills) {
      totalSales += bill.total;
      totalItems += bill.items.fold(0, (sum, item) => sum + item.quantity);
      
      // Payment method breakdown
      if (bill.paymentSplits != null) {
        for (final split in bill.paymentSplits!) {
          paymentBreakdown[split.method] = (paymentBreakdown[split.method] ?? 0) + split.amount;
        }
      } else {
        paymentBreakdown[bill.paymentMethod] = (paymentBreakdown[bill.paymentMethod] ?? 0) + bill.total;
      }

      // Hourly sales
      final hour = bill.createdAt.hour;
      if (!hourlySalesMap.containsKey(hour)) {
        hourlySalesMap[hour] = HourlySalesData(hour: hour, amount: 0, billCount: 0);
      }
      hourlySalesMap[hour] = HourlySalesData(
        hour: hour,
        amount: hourlySalesMap[hour]!.amount + bill.total,
        billCount: hourlySalesMap[hour]!.billCount + 1,
      );

      // Product sales
      for (final item in bill.items) {
        final productId = item.productId;
        if (!productSalesMap.containsKey(productId)) {
          productSalesMap[productId] = ProductSalesData(
            productId: productId,
            productName: item.productName,
            quantity: 0,
            revenue: 0,
            profit: 0,
          );
        }
        
        final currentData = productSalesMap[productId]!;
        final revenue = item.price * item.quantity;
        // Assuming 30% profit margin for now
        final profit = revenue * 0.3;
        
        productSalesMap[productId] = ProductSalesData(
          productId: productId,
          productName: item.productName,
          quantity: currentData.quantity + item.quantity,
          revenue: currentData.revenue + revenue,
          profit: currentData.profit + profit,
        );
        
        totalProfit += profit;
      }
    }

    // Sort and get top products
    final topProducts = productSalesMap.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    final averageBillValue = bills.isEmpty ? 0.0 : totalSales / bills.length;
    final profitMargin = totalSales > 0 ? (totalProfit / totalSales) * 100 : 0.0;

    return SalesReportData(
      totalSales: totalSales,
      totalBills: bills.length,
      totalItems: totalItems,
      totalProfit: totalProfit,
      averageBillValue: averageBillValue,
      hourlySales: hourlySalesMap.values.toList()..sort((a, b) => a.hour.compareTo(b.hour)),
      paymentMethodBreakdown: paymentBreakdown,
      topProducts: topProducts.take(10).toList(),
      topSellingItem: topProducts.isNotEmpty ? topProducts.first.productName : null,
      profitMargin: profitMargin,
    );
  }

  // Inventory Reports
  Future<InventoryReportData> generateInventoryReport() async {
    final productsBox = await _getProductsBox();
    final products = productsBox.values.toList();

    double totalValue = 0;
    final outOfStock = <StockAlertItem>[];
    final lowStock = <StockAlertItem>[];
    final expiringSoon = <StockAlertItem>[];
    final categories = <String>{};

    for (final product in products) {
      totalValue += product.sellingPrice * product.currentStock;
      categories.add(product.category);

      if (product.isOutOfStock) {
        outOfStock.add(StockAlertItem(
          productId: product.id,
          productName: product.name,
          currentStock: product.currentStock,
          reorderLevel: product.lowStockAlert ?? 10,
        ));
      } else if (product.isLowStock) {
        lowStock.add(StockAlertItem(
          productId: product.id,
          productName: product.name,
          currentStock: product.currentStock,
          reorderLevel: product.lowStockAlert ?? 10,
        ));
      }

      // Check expiry (if expiry date field exists)
      // For now, we'll skip this as ProductModel doesn't have expiry date
    }

    // Generate stock movements (simplified for now)
    final stockMovements = products.map((product) {
      return StockMovementData(
        productId: product.id,
        productName: product.name,
        openingStock: product.currentStock,
        purchased: 0,
        sold: 0,
        returned: 0,
        damaged: 0,
        closingStock: product.currentStock,
        stockValue: product.sellingPrice * product.currentStock,
      );
    }).toList();

    // ABC Analysis (simplified)
    final sortedProducts = products.toList()
      ..sort((a, b) => (b.sellingPrice * b.currentStock).compareTo(a.sellingPrice * a.currentStock));
    
    final aItemsCount = (products.length * 0.2).ceil();
    final bItemsCount = (products.length * 0.3).ceil();
    
    final aItems = sortedProducts.take(aItemsCount).toList();
    final bItems = sortedProducts.skip(aItemsCount).take(bItemsCount).toList();
    final cItems = sortedProducts.skip(aItemsCount + bItemsCount).toList();

    final aValue = aItems.fold<double>(0, (sum, p) => sum + (p.sellingPrice * p.currentStock));
    final bValue = bItems.fold<double>(0, (sum, p) => sum + (p.sellingPrice * p.currentStock));
    final cValue = cItems.fold<double>(0, (sum, p) => sum + (p.sellingPrice * p.currentStock));

    final abcAnalysis = ABCAnalysisData(
      aItems: ABCCategory(
        productIds: aItems.map((p) => p.id).toList(),
        value: aValue,
        percentage: totalValue > 0 ? (aValue / totalValue) * 100 : 0,
        category: 'A',
      ),
      bItems: ABCCategory(
        productIds: bItems.map((p) => p.id).toList(),
        value: bValue,
        percentage: totalValue > 0 ? (bValue / totalValue) * 100 : 0,
        category: 'B',
      ),
      cItems: ABCCategory(
        productIds: cItems.map((p) => p.id).toList(),
        value: cValue,
        percentage: totalValue > 0 ? (cValue / totalValue) * 100 : 0,
        category: 'C',
      ),
    );

    return InventoryReportData(
      totalValue: totalValue,
      totalItems: products.length,
      totalCategories: categories.length,
      outOfStock: outOfStock,
      lowStock: lowStock,
      expiringSoon: expiringSoon,
      stockMovements: stockMovements,
      abcAnalysis: abcAnalysis,
    );
  }

  // Financial Reports
  Future<ProfitLossReportData> generateProfitLossReport(ReportDateRange dateRange) async {
    final billsBox = await _getBillsBox();
    
    final bills = billsBox.values.where((bill) {
      return bill.createdAt.isAfter(dateRange.startDate) &&
             bill.createdAt.isBefore(dateRange.endDate) &&
             bill.status == BillStatus.completed;
    }).toList();

    // Revenue calculation
    double grossSales = 0;
    double discounts = 0;
    final Map<String, CategoryProfitability> categoryMap = {};

    for (final bill in bills) {
      grossSales += bill.subtotal;
      discounts += bill.discountAmount;
      
      // Category profitability (simplified)
      for (final item in bill.items) {
        final category = 'General'; // We'd need to get actual category from product
        if (!categoryMap.containsKey(category)) {
          categoryMap[category] = CategoryProfitability(
            category: category,
            revenue: 0,
            cost: 0,
            profit: 0,
            margin: 0,
            contribution: 0,
          );
        }
        
        final revenue = item.price * item.quantity;
        final cost = revenue * 0.7; // Assuming 30% margin
        final profit = revenue - cost;
        
        final current = categoryMap[category]!;
        categoryMap[category] = CategoryProfitability(
          category: category,
          revenue: current.revenue + revenue,
          cost: current.cost + cost,
          profit: current.profit + profit,
          margin: 0, // Will calculate later
          contribution: 0, // Will calculate later
        );
      }
    }

    final revenue = RevenueData(
      grossSales: grossSales,
      returns: 0, // Would need to track returns
      discounts: discounts,
      netSales: grossSales - discounts,
    );

    // COGS (simplified)
    final cogs = COGSData(
      openingStock: 0,
      purchases: 0,
      closingStock: 0,
      totalCOGS: revenue.netSales * 0.7, // Assuming 30% margin
    );

    // Expenses (simplified - no expense tracking yet)
    final expenseCategories = <String, double>{};
    double totalExpenses = 0;

    final expensesData = ExpensesData(
      categories: expenseCategories,
      total: totalExpenses,
    );

    // Calculate profits
    final grossProfit = revenue.netSales - cogs.totalCOGS;
    final grossProfitMargin = revenue.netSales > 0 ? (grossProfit / revenue.netSales) * 100 : 0.0;
    final netProfit = grossProfit - expensesData.total;
    final netProfitMargin = revenue.netSales > 0 ? (netProfit / revenue.netSales) * 100 : 0.0;

    // Update category profitability percentages
    final categoryProfitability = categoryMap.values.map((cat) {
      return CategoryProfitability(
        category: cat.category,
        revenue: cat.revenue,
        cost: cat.cost,
        profit: cat.profit,
        margin: cat.revenue > 0 ? (cat.profit / cat.revenue) * 100 : 0,
        contribution: revenue.netSales > 0 ? (cat.revenue / revenue.netSales) * 100 : 0,
      );
    }).toList();

    return ProfitLossReportData(
      revenue: revenue,
      costOfGoodsSold: cogs,
      grossProfit: grossProfit,
      grossProfitMargin: grossProfitMargin,
      expenses: expensesData,
      netProfit: netProfit,
      netProfitMargin: netProfitMargin,
      categoryProfitability: categoryProfitability,
    );
  }

  // Tax Reports
  Future<TaxReportData> generateTaxReport(ReportDateRange dateRange) async {
    final billsBox = await _getBillsBox();
    final bills = billsBox.values.where((bill) {
      return bill.createdAt.isAfter(dateRange.startDate) &&
             bill.createdAt.isBefore(dateRange.endDate) &&
             bill.status == BillStatus.completed;
    }).toList();

    double totalSales = 0;
    double totalCGST = 0;
    double totalSGST = 0;
    double totalIGST = 0;
    final Map<String, HSNSummaryData> hsnMap = {};

    for (final bill in bills) {
      totalSales += bill.total;
      
      if (bill.taxType == TaxType.cgstSgst) {
        final cgst = bill.tax / 2;
        totalCGST += cgst;
        totalSGST += cgst;
      } else if (bill.taxType == TaxType.igst) {
        totalIGST += bill.tax;
      }

      // HSN Summary (simplified - would need actual HSN codes)
      final hsnCode = '9999'; // Default HSN
      if (!hsnMap.containsKey(hsnCode)) {
        hsnMap[hsnCode] = HSNSummaryData(
          hsnCode: hsnCode,
          description: 'General Goods',
          taxRate: bill.taxType == TaxType.cgstSgst ? bill.cgstRate + bill.sgstRate : bill.igstRate,
          taxableAmount: 0,
          cgst: 0,
          sgst: 0,
          igst: 0,
        );
      }
      
      final current = hsnMap[hsnCode]!;
      hsnMap[hsnCode] = HSNSummaryData(
        hsnCode: hsnCode,
        description: current.description,
        taxRate: current.taxRate,
        taxableAmount: current.taxableAmount + bill.subtotal - bill.discountAmount,
        cgst: current.cgst + (bill.taxType == TaxType.cgstSgst ? bill.tax / 2 : 0),
        sgst: current.sgst + (bill.taxType == TaxType.cgstSgst ? bill.tax / 2 : 0),
        igst: current.igst + (bill.taxType == TaxType.igst ? bill.tax : 0),
      );
    }

    final outputGST = OutputGSTData(
      cgst: totalCGST,
      sgst: totalSGST,
      igst: totalIGST,
      total: totalCGST + totalSGST + totalIGST,
    );

    // Input GST (would need to track from purchases/expenses)
    final inputGST = InputGSTData(
      onPurchases: 0,
      onExpenses: 0,
      total: 0,
    );

    return TaxReportData(
      totalSales: totalSales,
      taxableSales: totalSales - (totalCGST + totalSGST + totalIGST),
      outputGST: outputGST,
      inputGST: inputGST,
      netPayable: outputGST.total - inputGST.total,
      hsnSummary: hsnMap.values.toList(),
    );
  }

  // Customer Reports
  Future<CustomerReportData> generateCustomerReport() async {
    final customersBox = await _getCustomersBox();
    final billsBox = await _getBillsBox();
    
    final customers = customersBox.values.toList();
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    
    // Calculate customer metrics
    final newThisMonth = customers.where((c) => c.createdAt.isAfter(thisMonthStart)).length;
    
    // Active customers (had transaction in last 90 days)
    final activeCustomers = <String>{};
    final last90Days = now.subtract(const Duration(days: 90));
    
    final recentBills = billsBox.values.where((bill) {
      return bill.createdAt.isAfter(last90Days) && bill.customerId != null;
    }).toList();
    
    for (final bill in recentBills) {
      if (bill.customerId != null) {
        activeCustomers.add(bill.customerId!);
      }
    }

    // Customer segmentation based on purchase value
    final customerPurchases = <String, double>{};
    for (final customer in customers) {
      customerPurchases[customer.id] = customer.totalPurchases;
    }
    
    final sortedCustomers = customerPurchases.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final totalCustomers = sortedCustomers.length;
    final vipCount = (totalCustomers * 0.1).ceil();
    final regularCount = (totalCustomers * 0.3).ceil();
    final occasionalCount = (totalCustomers * 0.4).ceil();
    
    final segmentation = CustomerSegmentation(
      vip: sortedCustomers.take(vipCount).map((e) => e.key).toList(),
      regular: sortedCustomers.skip(vipCount).take(regularCount).map((e) => e.key).toList(),
      occasional: sortedCustomers.skip(vipCount + regularCount).take(occasionalCount).map((e) => e.key).toList(),
      inactive: sortedCustomers.skip(vipCount + regularCount + occasionalCount).map((e) => e.key).toList(),
    );

    // Purchase patterns (simplified)
    final purchasePatterns = PurchasePatterns(
      averageBasketSize: 802.75, // Would calculate from actual data
      purchaseFrequency: 2.5, // Times per month
      favoriteProducts: [], // Would analyze from bills
      preferredPaymentMethod: 'UPI', // Would analyze from bills
    );

    // Credit report (simplified - would need actual credit tracking)
    final creditReport = <CustomerCreditData>[];

    return CustomerReportData(
      totalCustomers: customers.length,
      activeCustomers: activeCustomers.length,
      newThisMonth: newThisMonth,
      churnRate: 5.2, // Would calculate actual churn
      segmentation: segmentation,
      purchasePatterns: purchasePatterns,
      creditReport: creditReport,
    );
  }
}