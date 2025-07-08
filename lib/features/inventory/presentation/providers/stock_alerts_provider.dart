import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import 'inventory_provider.dart';

final lowStockProductsProvider = StreamProvider<List<ProductModel>>((ref) async* {
  final inventoryService = ref.read(inventoryServiceProvider);
  
  // Check every minute for low stock
  while (true) {
    final products = await inventoryService.getProducts();
    final lowStockProducts = products.where((product) {
      return product.currentStock <= (product.lowStockAlert ?? product.minStock);
    }).toList();
    
    yield lowStockProducts;
    
    // Wait 1 minute before checking again
    await Future.delayed(const Duration(minutes: 1));
  }
});

final outOfStockProductsProvider = StreamProvider<List<ProductModel>>((ref) async* {
  final inventoryService = ref.read(inventoryServiceProvider);
  
  // Check every minute for out of stock
  while (true) {
    final products = await inventoryService.getProducts();
    final outOfStockProducts = products.where((product) {
      return product.currentStock == 0;
    }).toList();
    
    yield outOfStockProducts;
    
    // Wait 1 minute before checking again
    await Future.delayed(const Duration(minutes: 1));
  }
});

class StockAlert {
  final String id;
  final String productId;
  final String productName;
  final int currentStock;
  final int lowStockThreshold;
  final AlertType type;
  final DateTime createdAt;
  final bool isRead;

  StockAlert({
    required this.id,
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.lowStockThreshold,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

enum AlertType {
  lowStock,
  outOfStock,
  reorderPoint,
}

final stockAlertsProvider = StateNotifierProvider<StockAlertsNotifier, List<StockAlert>>((ref) {
  return StockAlertsNotifier(ref);
});

class StockAlertsNotifier extends StateNotifier<List<StockAlert>> {
  final Ref ref;
  
  StockAlertsNotifier(this.ref) : super([]) {
    _monitorStock();
  }
  
  void _monitorStock() {
    ref.listen(lowStockProductsProvider, (previous, next) {
      next.whenData((products) {
        for (final product in products) {
          final existingAlert = state.firstWhere(
            (alert) => alert.productId == product.id && alert.type == AlertType.lowStock,
            orElse: () => StockAlert(
              id: '',
              productId: '',
              productName: '',
              currentStock: 0,
              lowStockThreshold: 0,
              type: AlertType.lowStock,
              createdAt: DateTime.now(),
            ),
          );
          
          if (existingAlert.id.isEmpty) {
            // Create new alert
            final newAlert = StockAlert(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              productId: product.id,
              productName: product.name,
              currentStock: product.currentStock,
              lowStockThreshold: product.lowStockAlert ?? product.minStock,
              type: product.currentStock == 0 ? AlertType.outOfStock : AlertType.lowStock,
              createdAt: DateTime.now(),
            );
            
            state = [newAlert, ...state];
          }
        }
      });
    });
  }
  
  void markAsRead(String alertId) {
    state = state.map((alert) {
      if (alert.id == alertId) {
        return StockAlert(
          id: alert.id,
          productId: alert.productId,
          productName: alert.productName,
          currentStock: alert.currentStock,
          lowStockThreshold: alert.lowStockThreshold,
          type: alert.type,
          createdAt: alert.createdAt,
          isRead: true,
        );
      }
      return alert;
    }).toList();
  }
  
  void clearAlert(String alertId) {
    state = state.where((alert) => alert.id != alertId).toList();
  }
  
  void clearAllAlerts() {
    state = [];
  }
  
  int get unreadCount => state.where((alert) => !alert.isRead).length;
}