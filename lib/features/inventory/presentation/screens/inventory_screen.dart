import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../../data/models/product_model.dart';
import '../providers/inventory_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/add_product_dialog.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/constants/app_constants.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isGridView = true;
  String _sortBy = 'name';
  
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);
    
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              print('Manual refresh triggered');
              ref.invalidate(productsProvider);
            },
            tooltip: 'Refresh products',
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Name')),
              const PopupMenuItem(value: 'price', child: Text('Price')),
              const PopupMenuItem(value: 'stock', child: Text('Stock')),
              const PopupMenuItem(value: 'category', child: Text('Category')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              print('Debug: Checking Hive box directly...');
              try {
                if (Hive.isBoxOpen(AppConstants.productsBox)) {
                  final box = Hive.box<ProductModel>(AppConstants.productsBox);
                  print('Box is open. Contains ${box.length} items');
                  for (var i = 0; i < box.length && i < 5; i++) {
                    final product = box.getAt(i);
                    if (product != null) {
                      print('Product $i: ${product.name} - ${product.category}');
                    }
                  }
                } else {
                  print('Products box is not open!');
                }
              } catch (e) {
                print('Debug error: $e');
              }
            },
            tooltip: 'Debug products',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(categories),
          _buildSummaryCards(productsAsync),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                print('InventoryScreen received ${products.length} products');
                final filteredProducts = _filterProducts(products);
                print('After filtering: ${filteredProducts.length} products');
                
                if (filteredProducts.isEmpty && products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text(
                          'No products in inventory',
                          style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Products should be loaded automatically',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(productsProvider),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reload Products'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAddProductDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product Manually'),
                        ),
                      ],
                    ),
                  );
                } else if (filteredProducts.isEmpty && products.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text(
                          'No products match your search',
                          style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${products.length} products available',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = 'All';
                            });
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }
                
                return _isGridView
                    ? _buildGridView(filteredProducts)
                    : _buildListView(filteredProducts);
              },
              loading: () {
                print('Products are loading...');
                return const Center(child: CircularProgressIndicator());
              },
              error: (error, stack) {
                print('Error loading products: $error');
                print('Stack trace: $stack');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(productsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
  
  Widget _buildSearchAndFilter(List<String> categories) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search products by name or barcode',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedCategory == 'All',
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = 'All';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...categories.map((category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCards(AsyncValue<List<ProductModel>> productsAsync) {
    return productsAsync.when(
      data: (products) {
        final totalProducts = products.length;
        final lowStockProducts = products.where((p) => p.isLowStock).length;
        final outOfStockProducts = products.where((p) => p.isOutOfStock).length;
        final totalValue = products.fold<double>(
          0,
          (sum, product) => sum + (product.sellingPrice * product.currentStock),
        );
        
        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildSummaryCard(
                'Total Products',
                totalProducts.toString(),
                Icons.inventory_2,
                Colors.blue,
              ),
              _buildSummaryCard(
                'Low Stock',
                lowStockProducts.toString(),
                Icons.warning,
                Colors.orange,
              ),
              _buildSummaryCard(
                'Out of Stock',
                outOfStockProducts.toString(),
                Icons.error,
                Colors.red,
              ),
              _buildSummaryCard(
                'Total Value',
                '₹${totalValue.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox(height: 100),
    );
  }
  
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const Spacer(),
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
  
  Widget _buildGridView(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => context.go('/inventory/product/${product.id}'),
        );
      },
    );
  }
  
  Widget _buildListView(List<ProductModel> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              product.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${product.category} • ${product.unit}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  'Stock: ${product.currentStock}',
                  style: TextStyle(
                    color: product.isOutOfStock
                        ? Colors.red
                        : product.isLowStock
                            ? Colors.orange
                            : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            trailing: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${product.sellingPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Cost: ₹${product.purchasePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => context.go('/inventory/product/${product.id}'),
          ),
        );
      },
    );
  }
  
  List<ProductModel> _filterProducts(List<ProductModel> products) {
    print('_filterProducts called with ${products.length} products');
    print('Search query: "$_searchQuery"');
    print('Selected category: "$_selectedCategory"');
    
    final filtered = products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.barcode.contains(_searchQuery);
      
      final matchesCategory = _selectedCategory == 'All' ||
          product.category == _selectedCategory;
      
      if (!matchesSearch) {
        print('Product "${product.name}" filtered out by search');
      }
      if (!matchesCategory) {
        print('Product "${product.name}" filtered out by category (product category: ${product.category})');
      }
      
      return matchesSearch && matchesCategory;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'price':
            return a.sellingPrice.compareTo(b.sellingPrice);
          case 'stock':
            return a.currentStock.compareTo(b.currentStock);
          case 'category':
            return a.category.compareTo(b.category);
          default:
            return a.name.compareTo(b.name);
        }
      });
    
    print('Filtered result: ${filtered.length} products');
    return filtered;
  }
  
  void _showAddProductDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddProductDialog(),
    );
  }
}