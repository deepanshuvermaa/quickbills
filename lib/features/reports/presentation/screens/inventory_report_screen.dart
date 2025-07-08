import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/report_providers.dart';
import '../../data/models/report_models.dart';

class InventoryReportScreen extends ConsumerWidget {
  const InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryReportAsync = ref.watch(inventoryReportProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Report'),
        actions: [
          PopupMenuButton<ExportFormat>(
            icon: const Icon(Icons.share),
            onSelected: (format) async {
              final exportService = ref.read(reportExportProvider);
              final reportData = inventoryReportAsync.valueOrNull;
              if (reportData != null) {
                await exportService.exportReport(
                  reportType: 'inventory',
                  format: format,
                  reportData: reportData,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Report exported as ${format.name.toUpperCase()}'),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ExportFormat.pdf,
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('Export as PDF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: ExportFormat.excel,
                child: ListTile(
                  leading: Icon(Icons.table_chart),
                  title: Text('Export as Excel'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: ExportFormat.csv,
                child: ListTile(
                  leading: Icon(Icons.file_copy),
                  title: Text('Export as CSV'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: inventoryReportAsync.when(
        data: (data) => _buildReportContent(context, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, InventoryReportData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCards(context, data),
          const SizedBox(height: 24),
          
          // Stock Alerts
          if (data.outOfStock.isNotEmpty || data.lowStock.isNotEmpty)
            _buildStockAlerts(context, data),
          
          // ABC Analysis
          _buildABCAnalysis(context, data),
          const SizedBox(height: 24),
          
          // Stock Movement Table
          _buildStockMovementTable(context, data),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, InventoryReportData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final cards = [
          _SummaryCard(
            title: 'Total Stock Value',
            value: '₹${data.totalValue.toStringAsFixed(2)}',
            icon: Icons.account_balance_wallet,
            color: Colors.green,
          ),
          _SummaryCard(
            title: 'Total Items',
            value: data.totalItems.toString(),
            icon: Icons.inventory_2,
            color: Colors.blue,
          ),
          _SummaryCard(
            title: 'Out of Stock',
            value: data.outOfStock.length.toString(),
            icon: Icons.error,
            color: Colors.red,
          ),
          _SummaryCard(
            title: 'Low Stock',
            value: data.lowStock.length.toString(),
            icon: Icons.warning,
            color: Colors.orange,
          ),
        ];

        if (isTablet) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        }

        return Column(
          children: cards.map((card) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: card,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStockAlerts(BuildContext context, InventoryReportData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stock Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        
        if (data.outOfStock.isNotEmpty) ...[
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Out of Stock (${data.outOfStock.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...data.outOfStock.take(5).map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• ${item.productName}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  )),
                  if (data.outOfStock.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '... and ${data.outOfStock.length - 5} more',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        if (data.lowStock.isNotEmpty) ...[
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Low Stock (${data.lowStock.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...data.lowStock.take(5).map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• ${item.productName} (${item.currentStock} left)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  )),
                  if (data.lowStock.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '... and ${data.lowStock.length - 5} more',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildABCAnalysis(BuildContext context, InventoryReportData data) {
    final abc = data.abcAnalysis;
    final categories = [
      {'label': 'A Items', 'data': abc.aItems, 'color': Colors.green},
      {'label': 'B Items', 'data': abc.bItems, 'color': Colors.blue},
      {'label': 'C Items', 'data': abc.cItems, 'color': Colors.orange},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ABC Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: categories.map((cat) {
                          final data = cat['data'] as ABCCategory;
                          return PieChartSectionData(
                            value: data.value,
                            title: '${data.percentage.toStringAsFixed(0)}%',
                            color: cat['color'] as Color,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories.map((cat) {
                      final data = cat['data'] as ABCCategory;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: cat['color'] as Color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat['label'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${data.productIds.length} items',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${data.value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A items: High value (70% of inventory value)\nB items: Medium value (20% of inventory value)\nC items: Low value (10% of inventory value)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockMovementTable(BuildContext context, InventoryReportData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stock Movement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Show full stock movement report
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Opening'), numeric: true),
                  DataColumn(label: Text('Sold'), numeric: true),
                  DataColumn(label: Text('Closing'), numeric: true),
                  DataColumn(label: Text('Value'), numeric: true),
                ],
                rows: data.stockMovements.take(10).map((movement) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            movement.productName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(movement.openingStock.toString())),
                      DataCell(Text(movement.sold.toString())),
                      DataCell(
                        Text(
                          movement.closingStock.toString(),
                          style: TextStyle(
                            color: movement.closingStock == 0
                                ? Colors.red
                                : movement.closingStock < 10
                                    ? Colors.orange
                                    : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(Text('₹${movement.stockValue.toStringAsFixed(0)}')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF424242),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
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
          ],
        ),
      ),
    );
  }
}