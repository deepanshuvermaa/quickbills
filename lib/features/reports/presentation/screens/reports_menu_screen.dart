import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportsMenuScreen extends StatelessWidget {
  const ReportsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportSection(
            context,
            title: 'Sales Reports',
            icon: Icons.trending_up,
            color: Colors.blue,
            items: [
              ReportMenuItem(
                title: 'Daily Sales Report',
                subtitle: 'View daily, weekly & monthly sales',
                route: '/reports/sales',
                icon: Icons.calendar_today,
              ),
              ReportMenuItem(
                title: 'Hourly Sales Analysis',
                subtitle: 'Hour-by-hour sales breakdown',
                route: '/reports/hourly-sales',
                icon: Icons.access_time,
              ),
              ReportMenuItem(
                title: 'Product Sales Report',
                subtitle: 'Product-wise sales analysis',
                route: '/reports/product-sales',
                icon: Icons.inventory_2,
              ),
              ReportMenuItem(
                title: 'Payment Methods Report',
                subtitle: 'Payment method breakdown',
                route: '/reports/payment-methods',
                icon: Icons.payment,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildReportSection(
            context,
            title: 'Inventory Reports',
            icon: Icons.inventory,
            color: Colors.orange,
            items: [
              ReportMenuItem(
                title: 'Stock Status Report',
                subtitle: 'Current inventory levels',
                route: '/reports/inventory',
                icon: Icons.storage,
              ),
              ReportMenuItem(
                title: 'Stock Movement Report',
                subtitle: 'Track stock in/out',
                route: '/reports/stock-movement',
                icon: Icons.swap_vert,
              ),
              ReportMenuItem(
                title: 'Low Stock Alert',
                subtitle: 'Items below reorder level',
                route: '/reports/low-stock',
                icon: Icons.warning,
              ),
              ReportMenuItem(
                title: 'Expiry Report',
                subtitle: 'Items nearing expiry',
                route: '/reports/expiry',
                icon: Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildReportSection(
            context,
            title: 'Financial Reports',
            icon: Icons.attach_money,
            color: Colors.green,
            items: [
              ReportMenuItem(
                title: 'Profit & Loss Statement',
                subtitle: 'Revenue, expenses & profit',
                route: '/reports/profit-loss',
                icon: Icons.assessment,
              ),
              ReportMenuItem(
                title: 'Expense Report',
                subtitle: 'Track all expenses',
                route: '/reports/expenses',
                icon: Icons.money_off,
              ),
              ReportMenuItem(
                title: 'Tax Summary (GST)',
                subtitle: 'GST collection & filing',
                route: '/reports/tax-summary',
                icon: Icons.receipt_long,
              ),
              ReportMenuItem(
                title: 'Cash Flow Report',
                subtitle: 'Cash management analysis',
                route: '/reports/cash-flow',
                icon: Icons.account_balance,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildReportSection(
            context,
            title: 'Customer Reports',
            icon: Icons.people,
            color: Colors.purple,
            items: [
              ReportMenuItem(
                title: 'Customer List Report',
                subtitle: 'All customer details',
                route: '/reports/customer-list',
                icon: Icons.list,
              ),
              ReportMenuItem(
                title: 'Top Customers',
                subtitle: 'Best performing customers',
                route: '/reports/top-customers',
                icon: Icons.star,
              ),
              ReportMenuItem(
                title: 'Credit Report',
                subtitle: 'Outstanding credit tracking',
                route: '/reports/credit-report',
                icon: Icons.credit_card,
              ),
              ReportMenuItem(
                title: 'Customer History',
                subtitle: 'Purchase patterns & trends',
                route: '/reports/customer-history',
                icon: Icons.history,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<ReportMenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(item.icon, color: color),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              item.subtitle,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(item.route),
          ),
        )),
      ],
    );
  }
}

class ReportMenuItem {
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;

  const ReportMenuItem({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
  });
}