import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/billing_screen.dart';
import 'favorite_products_widget.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';

class ProductSearchWidget extends ConsumerStatefulWidget {
  final Function(Product) onProductSelected;
  
  const ProductSearchWidget({
    super.key,
    required this.onProductSelected,
  });

  @override
  ConsumerState<ProductSearchWidget> createState() => _ProductSearchWidgetState();
}

class _ProductSearchWidgetState extends ConsumerState<ProductSearchWidget> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _searchQuery = '';
  bool _showSuggestions = false;
  
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
              _showSuggestions = value.isNotEmpty;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search products by name or barcode',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _showSuggestions = false;
                      });
                    },
                  )
                : null,
          ),
        ),
        if (_showSuggestions)
          productsAsync.when(
            data: (productModels) {
              // Filter products based on search query - match from start of words
              final filteredProducts = productModels.where((productModel) {
                final nameLower = productModel.name.toLowerCase();
                final barcodeLower = productModel.barcode.toLowerCase();
                final categoryLower = productModel.category.toLowerCase();
                
                // Check if any word in the name starts with the search query
                final nameWords = nameLower.split(' ');
                final matchesName = nameWords.any((word) => word.startsWith(_searchQuery));
                
                // Also check for contains match
                return matchesName || 
                       nameLower.contains(_searchQuery) ||
                       barcodeLower.contains(_searchQuery) ||
                       categoryLower.contains(_searchQuery);
              }).take(10).toList(); // Limit to 10 results
              
              if (filteredProducts.isEmpty) {
                return Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text('No products found'),
                );
              }
              
              return Container(
                margin: const EdgeInsets.only(top: 4),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final productModel = filteredProducts[index];
                    final product = Product(
                      id: productModel.id,
                      name: productModel.name,
                      price: productModel.sellingPrice,
                      stock: productModel.currentStock,
                      imageUrl: productModel.imageUrl,
                      sku: productModel.sku,
                      barcode: productModel.barcode,
                      taxRate: productModel.taxRate,
                    );
                    
                    return InkWell(
                      onTap: () {
                        widget.onProductSelected(product);
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _showSuggestions = false;
                        });
                        _focusNode.unfocus();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: index != filteredProducts.length - 1
                              ? Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productModel.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${productModel.sellingPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Stock: ${productModel.currentStock}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: productModel.currentStock > 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                ref.watch(favoriteProductsProvider).contains(product.id)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                              onPressed: () {
                                ref.read(favoriteProductsProvider.notifier).toggleFavorite(product.id);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Error loading products'),
            ),
          ),
      ],
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}