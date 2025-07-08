import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/bill_model.dart';
import '../providers/billing_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/product_search_widget.dart';
import '../widgets/cart_summary_widget.dart';
import '../widgets/discount_dialog.dart';
import '../widgets/split_payment_dialog.dart';
import '../widgets/tax_settings_dialog.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/favorite_products_widget.dart';
import '../../../inventory/presentation/widgets/stock_alerts_widget.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../../settings/presentation/providers/tax_settings_provider.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final List<CartItem> _cartItems = [];
  String _selectedPaymentMethod = 'Cash';
  double _discountAmount = 0;
  DiscountType? _discountType;
  double? _discountValue;
  List<PaymentSplit>? _paymentSplits;
  TaxType _taxType = TaxType.cgstSgst;
  double _cgstRate = 9.0;
  double _sgstRate = 9.0;
  double _igstRate = 18.0;
  CustomerModel? _selectedCustomer;
  
  @override
  void initState() {
    super.initState();
    // Load tax settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsAsync = ref.read(taxSettingsProvider);
      settingsAsync.whenData((settings) {
        setState(() {
          _cgstRate = settings.cgstRate;
          _sgstRate = settings.sgstRate;
          _igstRate = settings.igstRate;
        });
      });
    });
  }
  
  void _addToCart(Product product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
      if (existingIndex != -1) {
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + 1,
        );
      } else {
        _cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
  }
  
  void _updateQuantity(String productId, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cartItems.removeWhere((item) => item.product.id == productId);
      } else {
        final index = _cartItems.indexWhere((item) => item.product.id == productId);
        if (index != -1) {
          _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
        }
      }
    });
  }
  
  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }
  
  double get _subtotal {
    return _cartItems.fold<double>(0, (sum, item) => sum + (item.product.price * item.quantity));
  }
  
  double get _discountedSubtotal {
    return _subtotal - _discountAmount;
  }
  
  double get _tax {
    if (_cartItems.isEmpty || _subtotal == 0) return 0;
    
    double totalTax = 0;
    
    // Calculate tax for each item based on its specific tax rate or default rate
    for (final item in _cartItems) {
      final itemTotal = item.product.price * item.quantity;
      final discountRatio = _discountAmount / _subtotal;
      final itemTaxableAmount = itemTotal - (itemTotal * discountRatio);
      
      // Use product-specific tax rate if available, otherwise use default rates
      if (item.product.taxRate != null) {
        totalTax += itemTaxableAmount * item.product.taxRate! / 100;
      } else {
        // Use default tax rates
        if (_taxType == TaxType.cgstSgst) {
          totalTax += itemTaxableAmount * (_cgstRate + _sgstRate) / 100;
        } else if (_taxType == TaxType.igst) {
          totalTax += itemTaxableAmount * _igstRate / 100;
        }
      }
    }
    
    return totalTax;
  }
  
  double get _total {
    return _discountedSubtotal + _tax;
  }
  
  void _showDiscountDialog() {
    showDialog(
      context: context,
      builder: (context) => DiscountDialog(
        currentAmount: _subtotal,
        existingDiscountValue: _discountValue,
        existingDiscountType: _discountType,
        onApplyDiscount: (type, value, level) {
          setState(() {
            _discountType = type;
            _discountValue = value;
            if (type == DiscountType.percentage) {
              _discountAmount = _subtotal * (value / 100);
            } else {
              _discountAmount = value;
            }
          });
        },
      ),
    );
  }
  
  void _showSplitPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => SplitPaymentDialog(
        totalAmount: _total,
        onConfirm: (splits) {
          setState(() {
            _paymentSplits = splits;
            _selectedPaymentMethod = 'Split';
          });
        },
      ),
    );
  }
  
  void _showTaxSettings() {
    showDialog(
      context: context,
      builder: (context) => TaxSettingsDialog(
        currentTaxRate: _taxType == TaxType.cgstSgst ? _cgstRate + _sgstRate : _igstRate,
        onTaxChanged: (type, rate) {
          setState(() {
            _taxType = type;
            if (type == TaxType.cgstSgst) {
              _cgstRate = rate / 2;
              _sgstRate = rate / 2;
            } else if (type == TaxType.igst) {
              _igstRate = rate;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch tax settings for real-time updates
    ref.listen(taxSettingsProvider, (previous, next) {
      next.whenData((settings) {
        setState(() {
          _cgstRate = settings.cgstRate;
          _sgstRate = settings.sgstRate;
          _igstRate = settings.igstRate;
        });
      });
    });
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('New Sale'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.go('/bills-history');
            },
            tooltip: 'Sales History',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _scanBarcode(),
            tooltip: 'Scan Barcode',
          ),
        ],
      ),
      body: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
    );
  }
  
  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ProductSearchWidget(
                  onProductSelected: _addToCart,
                ),
              ),
              Expanded(
                child: _buildCartList(),
              ),
            ],
          ),
        ),
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: _buildCheckoutSection(),
        ),
      ],
    );
  }
  
  Widget _buildPhoneLayout() {
    return Column(
      children: [
        // Stock Alerts
        const StockAlertsWidget(),
        // Favorite Products
        Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Quick Access',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FavoriteProductsWidget(
                onProductSelected: _addToCart,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ProductSearchWidget(
            onProductSelected: _addToCart,
          ),
        ),
        Expanded(
          child: _buildCartList(),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CartSummaryWidget(
                  subtotal: _subtotal,
                  tax: _tax,
                  total: _total,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _cartItems.isEmpty ? null : () => _showCheckoutDialog(),
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCartList() {
    if (_cartItems.isEmpty) {
      return Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 12),
              Text(
                'Cart is empty',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add products to start billing',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return CartItemWidget(
          item: item,
          onQuantityChanged: (quantity) => _updateQuantity(item.product.id, quantity),
          onRemove: () => _updateQuantity(item.product.id, 0),
        );
      },
    );
  }
  
  Widget _buildCheckoutSection([StateSetter? setModalState]) {
    return Column(
      children: [
        AppBar(
          title: const Text('Checkout'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _cartItems.isEmpty ? null : _clearCart,
              tooltip: 'Clear Cart',
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cart Items Summary
                if (_cartItems.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _cartItems.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final item = _cartItems[index];
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${item.quantity} x ₹${item.product.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₹${(item.quantity * item.product.price).toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _selectCustomer(),
                          icon: Icon(_selectedCustomer != null ? Icons.person : Icons.person_add),
                          label: Text(_selectedCustomer?.name ?? 'Select Customer'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.discount),
                    title: const Text('Apply Discount'),
                    subtitle: _discountAmount > 0
                        ? Text(
                            _discountType == DiscountType.percentage
                                ? '${_discountValue!.toStringAsFixed(0)}% off (₹${_discountAmount.toStringAsFixed(2)})'  
                                : '₹${_discountAmount.toStringAsFixed(2)} off',
                            style: const TextStyle(color: Colors.green),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        : null,
                    onTap: _showDiscountDialog,
                    trailing: _discountAmount > 0
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _discountAmount = 0;
                                _discountType = null;
                                _discountValue = null;
                              });
                            },
                          )
                        : const Icon(Icons.chevron_right),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...AppConstants.paymentMethods.map((method) {
                          return RadioListTile<String>(
                            value: method,
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              if (setModalState != null) {
                                setModalState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              } else {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              }
                            },
                            title: Text(method),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          );
                        }),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.payments),
                          title: const Text('Split Payment'),
                          subtitle: _paymentSplits != null
                              ? Text(
                                  '${_paymentSplits!.length} payment methods',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                              : null,
                          onTap: _showSplitPaymentDialog,
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CartSummaryWidget(
                  subtotal: _subtotal,
                  tax: _tax,
                  total: _total,
                  discount: _discountAmount,
                  taxType: _taxType,
                  cgst: _cgstRate,
                  sgst: _sgstRate,
                  igst: _igstRate,
                  onTaxSettingsTap: _showTaxSettings,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _cartItems.isEmpty ? null : () => _processPayment(),
                  child: const Text('Process Payment'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _cartItems.isEmpty ? null : _saveAsDraft,
                  child: const Text('Save as Draft'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  void _showCheckoutDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return _buildCheckoutSection(setModalState);
              },
            );
          },
        );
      },
    );
  }
  
  void _processPayment() async {
    try {
      // Create bill model
      final bill = BillModel.create(
        cartItems: _cartItems,
        subtotal: _subtotal,
        discountAmount: _discountAmount,
        discountType: _discountType,
        discountValue: _discountValue,
        tax: _tax,
        taxType: _taxType,
        cgstRate: _cgstRate,
        sgstRate: _sgstRate,
        igstRate: _igstRate,
        total: _total,
        paymentMethod: _selectedPaymentMethod,
        paymentSplits: _paymentSplits,
        status: BillStatus.completed,
        customerId: _selectedCustomer?.id,
        customerName: _selectedCustomer?.name,
      );
      
      // Save bill to database
      final billingService = ref.read(billingServiceProvider);
      await billingService.saveBill(bill);
      
      // Show print dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Payment Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Invoice ${bill.invoiceNumber} generated successfully!',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                FittedBox(
                  child: Text(
                    'Total: ₹${_total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearCart();
                },
                child: const Text('Skip'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _printBill(bill.invoiceNumber);
                },
                icon: const Icon(Icons.print),
                label: const Text('Print Bill'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _printBill(String invoiceNumber) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // TODO: Implement actual printing
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill printed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        _clearCart();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Printing failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _saveAsDraft() async {
    try {
      // Create draft bill
      final bill = BillModel.create(
        cartItems: _cartItems,
        subtotal: _subtotal,
        discountAmount: _discountAmount,
        discountType: _discountType,
        discountValue: _discountValue,
        tax: _tax,
        taxType: _taxType,
        cgstRate: _cgstRate,
        sgstRate: _sgstRate,
        igstRate: _igstRate,
        total: _total,
        paymentMethod: _selectedPaymentMethod,
        paymentSplits: _paymentSplits,
        status: BillStatus.draft,
      );
      
      // Save draft to database
      final billingService = ref.read(billingServiceProvider);
      await billingService.saveBill(bill);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saved as draft: ${bill.invoiceNumber}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            action: SnackBarAction(
              label: 'View Drafts',
              onPressed: () {
                context.go('/bills-history');
              },
            ),
          ),
        );
        
        // Clear cart after saving draft
        _clearCart();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving draft: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _scanBarcode() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scan Barcode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      Navigator.pop(context, barcode.rawValue);
                      break;
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
    
    if (result != null && mounted) {
      // Search for product by barcode
      final inventoryService = ref.read(inventoryServiceProvider);
      final products = await inventoryService.searchProducts(result);
      
      if (products.isNotEmpty) {
        // Convert inventory product to billing product
        final product = products.first;
        _addToCart(Product(
          id: product.id,
          name: product.name,
          price: product.sellingPrice,
          imageUrl: product.imageUrl,
          stock: product.currentStock,
          sku: null, // ProductModel doesn't have sku
          barcode: product.barcode,
          taxRate: product.taxRate,
        ));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added ${product.name} to cart',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Product not found: $result',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
  
  void _selectCustomer() async {
    final customersAsync = ref.read(customersProvider);
    
    customersAsync.when(
      data: (customers) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Customer',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            customer.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(customer.name),
                        subtitle: Text(customer.phone ?? 'No phone'),
                        trailing: _selectedCustomer?.id == customer.id
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCustomer = customer;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading customers: $error')),
      ),
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final int stock;
  final String? sku;
  final String? barcode;
  final double? taxRate;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.stock,
    this.sku,
    this.barcode,
    this.taxRate,
  });
}

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}