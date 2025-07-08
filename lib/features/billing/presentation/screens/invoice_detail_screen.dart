import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/bill_model.dart';
import '../../../printer/data/services/bluetooth_printer_service.dart';
import '../widgets/discount_dialog.dart';
import '../widgets/tax_settings_dialog.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  BillModel? _bill;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadBill();
  }
  
  Future<void> _loadBill() async {
    try {
      final billsBox = await Hive.openBox<BillModel>(AppConstants.billsBox);
      final bill = billsBox.get(widget.invoiceId);
      
      setState(() {
        _bill = bill;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bill: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_bill == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invoice Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Invoice not found',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${_bill!.invoiceNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareBill,
            tooltip: 'Share',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'print':
                  _printBill();
                  break;
                case 'duplicate':
                  _duplicateBill();
                  break;
                case 'delete':
                  _deleteBill();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'print',
                child: ListTile(
                  leading: Icon(Icons.print),
                  title: Text('Print'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Duplicate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              color: _getStatusColor(_bill!.status).withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _getStatusText(_bill!.status),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _getStatusColor(_bill!.status),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Amount',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '₹${_bill!.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bill Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Customer Details',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (_bill!.customerId != null)
                                TextButton(
                                  onPressed: () {
                                    context.push('/customers/detail/${_bill!.customerId}');
                                  },
                                  child: const Text('View Profile'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _bill!.customerName ?? 'Walk-in Customer',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Date & Payment Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(_bill!.createdAt),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment Method',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                _bill!.paymentMethod,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          if (_bill!.paymentSplits != null && _bill!.paymentSplits!.isNotEmpty) ...[
                            const Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Split',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                ..._bill!.paymentSplits!.map((split) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(split.method),
                                          Text('₹${split.amount.toStringAsFixed(2)}'),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Items
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Items (${_bill!.items.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ..._bill!.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            '${item.quantity} × ₹${item.price.toStringAsFixed(2)}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₹${(item.quantity * item.price).toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(),
                          
                          // Subtotal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal'),
                              Text('₹${_bill!.subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          
                          // Discount
                          if (_bill!.discountAmount > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Discount ${_bill!.discountType == DiscountType.percentage ? '(${_bill!.discountValue}%)' : ''}',
                                ),
                                Text(
                                  '-₹${_bill!.discountAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                          
                          // Tax
                          if (_bill!.tax > 0) ...[
                            const SizedBox(height: 8),
                            if (_bill!.taxType == TaxType.cgstSgst) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('CGST (${_bill!.cgstRate}%)'),
                                  Text('₹${(_bill!.tax / 2).toStringAsFixed(2)}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('SGST (${_bill!.sgstRate}%)'),
                                  Text('₹${(_bill!.tax / 2).toStringAsFixed(2)}'),
                                ],
                              ),
                            ] else if (_bill!.taxType == TaxType.igst) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('IGST (${_bill!.igstRate}%)'),
                                  Text('₹${_bill!.tax.toStringAsFixed(2)}'),
                                ],
                              ),
                            ],
                          ],
                          
                          const Divider(thickness: 2),
                          
                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '₹${_bill!.total.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Notes
                  if (_bill!.notes != null && _bill!.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(_bill!.notes!),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(BillStatus status) {
    switch (status) {
      case BillStatus.completed:
        return Colors.green;
      case BillStatus.draft:
        return Colors.orange;
      case BillStatus.cancelled:
        return Colors.red;
      case BillStatus.refunded:
        return Colors.purple;
    }
  }
  
  String _getStatusText(BillStatus status) {
    switch (status) {
      case BillStatus.completed:
        return 'Completed';
      case BillStatus.draft:
        return 'Draft';
      case BillStatus.cancelled:
        return 'Cancelled';
      case BillStatus.refunded:
        return 'Refunded';
    }
  }
  
  Future<void> _shareBill() async {
    final billText = '''
Invoice: ${_bill!.invoiceNumber}
Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(_bill!.createdAt)}
Customer: ${_bill!.customerName ?? 'Walk-in Customer'}

Items:
${_bill!.items.map((item) => '${item.productName} - ${item.quantity} × ₹${item.price.toStringAsFixed(2)} = ₹${(item.quantity * item.price).toStringAsFixed(2)}').join('\n')}

Subtotal: ₹${_bill!.subtotal.toStringAsFixed(2)}
${_bill!.discountAmount > 0 ? 'Discount: -₹${_bill!.discountAmount.toStringAsFixed(2)}' : ''}
${_bill!.tax > 0 ? 'Tax: ₹${_bill!.tax.toStringAsFixed(2)}' : ''}
Total: ₹${_bill!.total.toStringAsFixed(2)}

Payment: ${_bill!.paymentMethod}
''';
    
    await Share.share(billText, subject: 'Invoice ${_bill!.invoiceNumber}');
  }
  
  Future<void> _printBill() async {
    try {
      final printerService = BluetoothPrinterService();
      await printerService.printBill(_bill!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printing bill...')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _duplicateBill() async {
    // Navigate to billing screen with pre-filled data
    context.go('/billing');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill duplicated - Edit as needed')),
    );
  }
  
  Future<void> _deleteBill() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: const Text('Are you sure you want to delete this bill? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final billsBox = await Hive.openBox<BillModel>(AppConstants.billsBox);
        await billsBox.delete(widget.invoiceId);
        
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bill deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting bill: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}