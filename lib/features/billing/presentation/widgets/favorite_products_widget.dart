import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../inventory/data/models/product_model.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../screens/billing_screen.dart';

final favoriteProductsProvider = StateNotifierProvider<FavoriteProductsNotifier, List<String>>((ref) {
  return FavoriteProductsNotifier();
});

class FavoriteProductsNotifier extends StateNotifier<List<String>> {
  late Box _settingsBox;
  
  FavoriteProductsNotifier() : super([]) {
    _loadFavorites();
  }
  
  Future<void> _loadFavorites() async {
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    final favorites = _settingsBox.get('favorite_products', defaultValue: <String>[]);
    state = List<String>.from(favorites);
  }
  
  Future<void> toggleFavorite(String productId) async {
    if (state.contains(productId)) {
      state = state.where((id) => id != productId).toList();
    } else {
      state = [...state, productId];
    }
    await _settingsBox.put('favorite_products', state);
  }
  
  bool isFavorite(String productId) {
    return state.contains(productId);
  }
}

class FavoriteProductsWidget extends ConsumerWidget {
  final Function(Product) onProductSelected;
  
  const FavoriteProductsWidget({
    super.key,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoriteProductsProvider);
    final inventoryService = ref.read(inventoryServiceProvider);
    
    if (favoriteIds.isEmpty) {
      return Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_border, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No favorite products',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Star products to add them here',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 120,
      child: FutureBuilder<List<ProductModel>>(
        future: inventoryService.getProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final allProducts = snapshot.data!;
          final favoriteProducts = allProducts.where((p) => favoriteIds.contains(p.id)).toList();
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];
              return Card(
                margin: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => onProductSelected(Product(
                    id: product.id,
                    name: product.name,
                    price: product.sellingPrice,
                    imageUrl: product.imageUrl,
                    stock: product.currentStock,
                    sku: product.sku,
                    barcode: product.barcode,
                  )),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${product.sellingPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}