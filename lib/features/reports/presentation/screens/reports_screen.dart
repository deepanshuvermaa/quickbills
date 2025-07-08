import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/reports_provider.dart';
import '../../data/models/report_models.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Sales Overview'),
              Tab(text: 'Product Performance'),
              Tab(text: 'Customer Analysis'),
              Tab(text: 'Financial Summary'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SalesOverviewTab(),
            ProductPerformanceTab(),
            CustomerAnalysisTab(),
            FinancialSummaryTab(),
          ],
        ),
      ),
    );
  }
}

class SalesOverviewTab extends ConsumerStatefulWidget {
  const SalesOverviewTab({super.key});

  @override
  ConsumerState<SalesOverviewTab> createState() => _SalesOverviewTabState();
}

class _SalesOverviewTabState extends ConsumerState<SalesOverviewTab> {
  
  void _updateDateRange(ReportDateRange newRange) {
    ref.read(currentDateRangeProvider.notifier).state = newRange;
  }
  
  String _formatDateRange(ReportDateRange range) {
    final start = range.startDate;
    final end = range.endDate;
    final now = DateTime.now();
    final daysDiff = end.difference(start).inDays;
    
    // Check for common ranges
    if (daysDiff == 6 && end.day == now.day && end.month == now.month) {
      return 'Last 7 days';
    } else if (daysDiff == 29 && end.day == now.day && end.month == now.month) {
      return 'Last 30 days';
    } else if (start.day == 1 && end.day == DateTime(end.year, end.month + 1, 0).day) {
      return 'This month';
    } else {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Future<void> _selectDateRange() async {
    final currentRange = ref.read(currentDateRangeProvider);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: currentRange.startDate,
        end: currentRange.endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      _updateDateRange(ReportDateRange(
        startDate: picked.start,
        endDate: picked.end.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = ref.watch(currentDateRangeProvider);
    final salesReportAsync = ref.watch(salesReportProvider(dateRange));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _formatDateRange(dateRange),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _selectDateRange,
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          salesReportAsync.when(
            data: (report) => Column(
              children: [
                // Summary Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 400) {
                      return Column(
                        children: [
                          _buildSummaryCard(
                            'Total Sales',
                            '₹${report.totalSales.toStringAsFixed(2)}',
                            report.totalBills > 0 ? '+${report.totalBills}' : '0',
                            Icons.trending_up,
                            Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryCard(
                            'Total Orders',
                            report.totalBills.toString(),
                            'orders',
                            Icons.shopping_cart,
                            Colors.blue,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Sales',
                            '₹${report.totalSales.toStringAsFixed(2)}',
                            report.totalBills > 0 ? '+${report.totalBills}' : '0',
                            Icons.trending_up,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Orders',
                            report.totalBills.toString(),
                            'orders',
                            Icons.shopping_cart,
                            Colors.blue,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 400) {
                      return Column(
                        children: [
                          _buildSummaryCard(
                            'Average Order',
                            '₹${report.averageBillValue.toStringAsFixed(2)}',
                            'per order',
                            Icons.analytics,
                            Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryCard(
                            'Total Items',
                            report.totalItems.toString(),
                            'items sold',
                            Icons.inventory_2,
                            Colors.purple,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Average Order',
                            '₹${report.averageBillValue.toStringAsFixed(2)}',
                            'per order',
                            Icons.analytics,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Items',
                            report.totalItems.toString(),
                            'items sold',
                            Icons.inventory_2,
                            Colors.purple,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Sales Chart
                if (report.hourlySales.isNotEmpty) ...[
                  const Text(
                    'Sales by Hour',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: report.hourlySales.map((e) => e.amount).reduce((a, b) => a > b ? a : b) * 1.2,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() < report.hourlySales.length) {
                                      return Text(
                                        '${report.hourlySales[value.toInt()].hour}h',
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: report.hourlySales.asMap().entries.map((entry) {
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.amount,
                                    color: Theme.of(context).primaryColor,
                                    width: 16,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Payment Methods
                if (report.paymentMethodBreakdown.isNotEmpty) ...[
                  const Text(
                    'Payment Methods',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: report.paymentMethodBreakdown.entries.map((entry) {
                          final percentage = report.totalSales > 0 
                              ? entry.value / report.totalSales 
                              : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key),
                                    Text('₹${entry.value.toStringAsFixed(2)}'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: percentage,
                                  backgroundColor: Colors.grey[200],
                                  minHeight: 6,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading sales data: $error'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF424242),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF424242),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ProductPerformanceTab extends ConsumerWidget {
  const ProductPerformanceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(currentDateRangeProvider);
    final salesReportAsync = ref.watch(salesReportProvider(dateRange));
    final inventoryReportAsync = ref.watch(inventoryReportProvider);
    
    return salesReportAsync.when(
      data: (salesReport) => inventoryReportAsync.when(
        data: (inventoryReport) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Selling Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),
              if (salesReport.topProducts.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No sales data available',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...salesReport.topProducts.map((product) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${product.quantity} units sold',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    trailing: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${product.revenue.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Revenue',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF424242),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
              const SizedBox(height: 24),
              const Text(
                'Inventory Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInventoryRow('Total Products', inventoryReport.totalItems.toString()),
                      const Divider(),
                      _buildInventoryRow('Total Categories', inventoryReport.totalCategories.toString()),
                      const Divider(),
                      _buildInventoryRow('Total Value', '₹${inventoryReport.totalValue.toStringAsFixed(2)}'),
                      const Divider(),
                      _buildInventoryRow('Out of Stock', inventoryReport.outOfStock.length.toString(), 
                          color: inventoryReport.outOfStock.isNotEmpty ? Colors.red : null),
                      const Divider(),
                      _buildInventoryRow('Low Stock', inventoryReport.lowStock.length.toString(),
                          color: inventoryReport.lowStock.isNotEmpty ? Colors.orange : null),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading inventory data: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading sales data: $error')),
    );
  }
  
  Widget _buildInventoryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerAnalysisTab extends ConsumerWidget {
  const CustomerAnalysisTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerReportAsync = ref.watch(customerReportProvider);
    
    return customerReportAsync.when(
      data: (report) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildMetric('Total Customers', report.totalCustomers.toString()),
                        _buildMetric('Active Customers', report.activeCustomers.toString()),
                        _buildMetric('New This Month', report.newThisMonth.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Customer Segmentation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSegmentRow('VIP Customers', report.segmentation.vip.length, Colors.purple),
                    const Divider(),
                    _buildSegmentRow('Regular Customers', report.segmentation.regular.length, Colors.blue),
                    const Divider(),
                    _buildSegmentRow('Occasional Customers', report.segmentation.occasional.length, Colors.orange),
                    const Divider(),
                    _buildSegmentRow('Inactive Customers', report.segmentation.inactive.length, Colors.grey),
                  ],
                ),
              ),
            ),
            if (report.totalCustomers == 0) ...[
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No customer data available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading customer data: $error')),
    );
  }
  
  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF424242),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSegmentRow(String segment, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(segment)),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class FinancialSummaryTab extends ConsumerWidget {
  const FinancialSummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(currentDateRangeProvider);
    final profitLossAsync = ref.watch(profitLossReportProvider(dateRange));
    final taxReportAsync = ref.watch(taxReportProvider(dateRange));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profitLossAsync.when(
            data: (plReport) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Revenue Breakdown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFinancialRow('Gross Sales', '₹${plReport.revenue.grossSales.toStringAsFixed(2)}', isTotal: true),
                        if (plReport.revenue.discounts > 0) ...[
                          const Divider(),
                          _buildFinancialRow('Discounts', '-₹${plReport.revenue.discounts.toStringAsFixed(2)}', color: Colors.red),
                        ],
                        const Divider(),
                        _buildFinancialRow('Net Sales', '₹${plReport.revenue.netSales.toStringAsFixed(2)}', isTotal: true),
                        const Divider(),
                        _buildFinancialRow('Gross Profit', '₹${plReport.grossProfit.toStringAsFixed(2)}'),
                        _buildFinancialRow('Profit Margin', '${plReport.grossProfitMargin.toStringAsFixed(1)}%', 
                            color: plReport.grossProfitMargin > 20 ? Colors.green : Colors.orange),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, stack) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading financial data: $error'),
              ),
            ),
          ),
          
          taxReportAsync.when(
            data: (taxReport) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tax Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFinancialRow('Total Sales', '₹${taxReport.totalSales.toStringAsFixed(2)}'),
                    _buildFinancialRow('Taxable Sales', '₹${taxReport.taxableSales.toStringAsFixed(2)}'),
                    const Divider(),
                    if (taxReport.outputGST.cgst > 0)
                      _buildFinancialRow('CGST Collected', '₹${taxReport.outputGST.cgst.toStringAsFixed(2)}'),
                    if (taxReport.outputGST.sgst > 0)
                      _buildFinancialRow('SGST Collected', '₹${taxReport.outputGST.sgst.toStringAsFixed(2)}'),
                    if (taxReport.outputGST.igst > 0)
                      _buildFinancialRow('IGST Collected', '₹${taxReport.outputGST.igst.toStringAsFixed(2)}'),
                    const Divider(),
                    _buildFinancialRow('Total Tax Collected', '₹${taxReport.outputGST.total.toStringAsFixed(2)}', isTotal: true),
                  ],
                ),
              ),
            ),
            loading: () => const SizedBox(),
            error: (error, stack) => const SizedBox(),
          ),
          
          if (profitLossAsync.value == null && taxReportAsync.value == null) ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(Icons.assessment_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No financial data available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildFinancialRow(String label, String amount, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          FittedBox(
            child: Text(
              amount,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}