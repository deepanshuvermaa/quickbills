import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/stock_alerts_provider.dart';

class StockAlertsWidget extends ConsumerWidget {
  const StockAlertsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(stockAlertsProvider);
    final unreadAlerts = alerts.where((alert) => !alert.isRead).toList();
    
    if (unreadAlerts.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
            ),
            title: Text(
              'Stock Alerts (${unreadAlerts.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text('Products need attention'),
            trailing: TextButton(
              onPressed: () => context.go('/inventory'),
              child: const Text('View All'),
            ),
          ),
          const Divider(height: 1),
          ...unreadAlerts.take(3).map((alert) => _buildAlertItem(context, ref, alert)),
          if (unreadAlerts.length > 3)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '+ ${unreadAlerts.length - 3} more alerts',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildAlertItem(BuildContext context, WidgetRef ref, StockAlert alert) {
    IconData icon;
    Color color;
    String message;
    
    switch (alert.type) {
      case AlertType.outOfStock:
        icon = Icons.error;
        color = Colors.red;
        message = 'Out of stock!';
        break;
      case AlertType.lowStock:
        icon = Icons.warning;
        color = Colors.orange;
        message = 'Low stock: ${alert.currentStock} units left';
        break;
      case AlertType.reorderPoint:
        icon = Icons.info;
        color = Colors.blue;
        message = 'Time to reorder';
        break;
    }
    
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        alert.productName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        message,
        style: TextStyle(color: color, fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: () {
          ref.read(stockAlertsProvider.notifier).markAsRead(alert.id);
        },
      ),
      onTap: () {
        ref.read(stockAlertsProvider.notifier).markAsRead(alert.id);
        context.go('/inventory/product/${alert.productId}');
      },
    );
  }
}