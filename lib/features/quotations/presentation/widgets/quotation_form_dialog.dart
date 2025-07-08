import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/quotation_model.dart';
import '../providers/quotations_provider.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../inventory/data/models/product_model.dart';

class QuotationFormDialog extends ConsumerStatefulWidget {
  final QuotationModel? quotation;
  
  const QuotationFormDialog({super.key, this.quotation});

  @override
  ConsumerState<QuotationFormDialog> createState() => _QuotationFormDialogState();
}

class _QuotationFormDialogState extends ConsumerState<QuotationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _notesController = TextEditingController();
  final _termsController = TextEditingController();
  
  DateTime _validityDate = DateTime.now().add(const Duration(days: 30));
  String? _selectedCustomerId;
  String? _customerName;
  String? _customerPhone;
  String? _customerEmail;
  List<QuotationItem> _items = [];
  double _discount = 0;
  
  @override
  void initState() {
    super.initState();
    if (widget.quotation != null) {
      _loadQuotationData();
    }
  }
  
  void _loadQuotationData() {
    final quotation = widget.quotation!;
    _validityDate = quotation.validityDate;
    _selectedCustomerId = quotation.customerId;
    _customerName = quotation.customerName;
    _customerPhone = quotation.customerPhone;
    _customerEmail = quotation.customerEmail;
    _customerController.text = quotation.customerName ?? '';
    _notesController.text = quotation.notes ?? '';
    _termsController.text = quotation.terms ?? '';
    _items = List.from(quotation.items);
    _discount = quotation.discount;
  }
  
  @override
  void dispose() {
    _customerController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }
  
  double get _subtotal => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get _tax => _subtotal * 0.18; // 18% GST
  double get _total => _subtotal - _discount + _tax;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.quotation == null ? 'New Quotation' : 'Edit Quotation',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Selection
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _customerController,
                              decoration: const InputDecoration(
                                labelText: 'Customer',
                                hintText: 'Search or enter customer name',
                                prefixIcon: Icon(Icons.person),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _customerName = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter customer name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 200,
                            child: InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _validityDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _validityDate = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Valid Until',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(DateFormat('dd/MM/yyyy').format(_validityDate)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Items Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ElevatedButton.icon(
                            onPressed: _showProductSearch,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Item'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Items List
                      Container(
                        constraints: BoxConstraints(
                          minHeight: 100,
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _items.isEmpty
                            ? const Center(
                                child: Text('No items added'),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return ListTile(
                                    title: Text(item.productName),
                                    subtitle: Text(
                                      '₹${item.price.toStringAsFixed(2)} × ${item.quantity} = ₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                              if (item.quantity > 1) {
                                                final newQuantity = item.quantity - 1;
                                                _items[index] = QuotationItem(
                                                  productId: item.productId,
                                                  productName: item.productName,
                                                  price: item.price,
                                                  quantity: newQuantity,
                                                  total: item.price * newQuantity,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                        Text('${item.quantity}'),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              final newQuantity = item.quantity + 1;
                                              _items[index] = QuotationItem(
                                                productId: item.productId,
                                                productName: item.productName,
                                                price: item.price,
                                                quantity: newQuantity,
                                                total: item.price * newQuantity,
                                              );
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed: () {
                                            setState(() {
                                              _items.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Discount
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _discount.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Discount Amount',
                                prefixIcon: Icon(Icons.discount),
                                prefixText: '₹ ',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _discount = double.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Notes and Terms
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _termsController,
                        decoration: const InputDecoration(
                          labelText: 'Terms & Conditions',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Summary
              const Divider(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('₹${_subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    if (_discount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discount:'),
                          Text('-₹${_discount.toStringAsFixed(2)}'),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tax (18%):'),
                        Text('₹${_tax.toStringAsFixed(2)}'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '₹${_total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _items.isEmpty ? null : _saveQuotation,
                    child: Text(widget.quotation == null ? 'Create' : 'Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showProductSearch() async {
    final products = await ref.read(inventoryServiceProvider).getProducts();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Select Product',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  // Implement search
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('₹${product.sellingPrice.toStringAsFixed(2)} • Stock: ${product.currentStock}'),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          final existingIndex = _items.indexWhere((item) => item.productId == product.id);
                          if (existingIndex != -1) {
                            final newQuantity = _items[existingIndex].quantity + 1;
                            _items[existingIndex] = QuotationItem(
                              productId: product.id,
                              productName: product.name,
                              price: product.sellingPrice,
                              quantity: newQuantity,
                              total: product.sellingPrice * newQuantity,
                            );
                          } else {
                            _items.add(QuotationItem(
                              productId: product.id,
                              productName: product.name,
                              price: product.sellingPrice,
                              quantity: 1,
                              total: product.sellingPrice,
                            ));
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _saveQuotation() async {
    if (_formKey.currentState!.validate()) {
      final quotationService = ref.read(quotationServiceProvider);
      
      if (widget.quotation == null) {
        // Create new quotation
        final quotation = QuotationModel.create(
          validityDate: _validityDate,
          customerId: _selectedCustomerId,
          customerName: _customerName,
          customerPhone: _customerPhone,
          customerEmail: _customerEmail,
          items: _items,
          subtotal: _subtotal,
          discount: _discount,
          tax: _tax,
          total: _total,
          notes: _notesController.text,
          terms: _termsController.text,
        );
        
        await quotationService.saveQuotation(quotation);
      } else {
        // Update existing quotation
        final updatedQuotation = widget.quotation!.copyWith(
          validityDate: _validityDate,
          customerName: _customerName,
          customerPhone: _customerPhone,
          customerEmail: _customerEmail,
          items: _items,
          subtotal: _subtotal,
          discount: _discount,
          tax: _tax,
          total: _total,
          notes: _notesController.text,
          terms: _termsController.text,
        );
        
        await quotationService.updateQuotation(updatedQuotation);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.quotation == null ? 'Quotation created' : 'Quotation updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}