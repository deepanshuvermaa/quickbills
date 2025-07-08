import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/quotations_provider.dart';
import '../../data/models/quotation_model.dart';
import '../widgets/quotation_form_dialog.dart';

class QuotationsScreen extends ConsumerStatefulWidget {
  const QuotationsScreen({super.key});

  @override
  ConsumerState<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends ConsumerState<QuotationsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final List<String> _filterOptions = ['All', 'Draft', 'Sent', 'Accepted', 'Rejected', 'Expired'];

  @override
  Widget build(BuildContext context) {
    final quotationsAsync = ref.watch(quotationsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Export'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: quotationsAsync.when(
        data: (quotations) {
          // Filter quotations
          final filteredQuotations = _filterQuotations(quotations);
          
          if (filteredQuotations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No quotations found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first quotation',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              // Summary Section
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total',
                        filteredQuotations.length.toString(),
                        Icons.description,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Active',
                        filteredQuotations.where((q) => q.status == 'draft' || q.status == 'sent').length.toString(),
                        Icons.access_time,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Accepted',
                        filteredQuotations.where((q) => q.status == 'accepted').length.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Filter Chips
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filterOptions.length,
                  itemBuilder: (context, index) {
                    final filter = _filterOptions[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              
              // Quotations List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredQuotations.length,
                  itemBuilder: (context, index) {
                    final quotation = filteredQuotations[index];
                    return _buildQuotationCard(quotation);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewQuotation,
        icon: const Icon(Icons.add),
        label: const Text('New Quotation'),
      ),
    );
  }
  
  Widget _buildQuotationCard(QuotationModel quotation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showQuotationDetails(context, quotation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(quotation.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.description,
                          color: _getStatusColor(quotation.status),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quotation.quotationNumber,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            quotation.customerName ?? 'No customer',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Chip(
                    label: Text(
                      _getStatusLabel(quotation.status),
                      style: TextStyle(
                        color: _getStatusColor(quotation.status),
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: _getStatusColor(quotation.status).withOpacity(0.1),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Created: ${DateFormat('dd/MM/yyyy').format(quotation.createdDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: quotation.isExpired ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Valid until: ${DateFormat('dd/MM/yyyy').format(quotation.validityDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: quotation.isExpired ? Colors.red : null,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${quotation.items.length} items',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '₹${quotation.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.email_outlined),
                        onPressed: () => _sendQuotation(quotation),
                      ),
                      IconButton(
                        icon: const Icon(Icons.print_outlined),
                        onPressed: () => _printQuotation(quotation),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleQuotationAction(value, quotation),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 20),
                                SizedBox(width: 8),
                                Text('Duplicate'),
                              ],
                            ),
                          ),
                          if (quotation.status == 'draft' || quotation.status == 'sent')
                            const PopupMenuItem(
                              value: 'convert',
                              child: Row(
                                children: [
                                  Icon(Icons.transform, size: 20),
                                  SizedBox(width: 8),
                                  Text('Convert to Invoice'),
                                ],
                              ),
                            ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<QuotationModel> _filterQuotations(List<QuotationModel> quotations) {
    var filtered = quotations;
    
    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((q) {
        switch (_selectedFilter.toLowerCase()) {
          case 'draft':
            return q.status == 'draft';
          case 'sent':
            return q.status == 'sent';
          case 'accepted':
            return q.status == 'accepted';
          case 'rejected':
            return q.status == 'rejected';
          case 'expired':
            return q.isExpired;
          default:
            return true;
        }
      }).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((q) {
        return q.quotationNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (q.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }
    
    return filtered;
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'sent':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'expired':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusLabel(String status) {
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Quotations'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Quotation number or customer',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
  
  void _createNewQuotation() {
    showDialog(
      context: context,
      builder: (context) => const QuotationFormDialog(),
    );
  }
  
  void _showQuotationDetails(BuildContext context, QuotationModel quotation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                quotation.quotationNumber,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Customer'),
                subtitle: Text(quotation.customerName ?? 'No customer'),
              ),
              ListTile(
                title: const Text('Status'),
                subtitle: Text(_getStatusLabel(quotation.status)),
              ),
              ListTile(
                title: const Text('Created Date'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(quotation.createdDate)),
              ),
              ListTile(
                title: const Text('Valid Until'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(quotation.validityDate)),
              ),
              const Divider(),
              const Text(
                'Items',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...quotation.items.map((item) => ListTile(
                    title: Text(item.productName),
                    subtitle: Text('${item.quantity} × ₹${item.price.toStringAsFixed(2)}'),
                    trailing: Text('₹${(item.quantity * item.price).toStringAsFixed(2)}'),
                  )),
              const Divider(),
              ListTile(
                title: const Text('Subtotal'),
                trailing: Text('₹${quotation.subtotal.toStringAsFixed(2)}'),
              ),
              if (quotation.discount > 0)
                ListTile(
                  title: const Text('Discount'),
                  trailing: Text('-₹${quotation.discount.toStringAsFixed(2)}'),
                ),
              ListTile(
                title: const Text('Tax'),
                trailing: Text('₹${quotation.tax.toStringAsFixed(2)}'),
              ),
              ListTile(
                title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text(
                  '₹${quotation.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              if (quotation.notes != null && quotation.notes!.isNotEmpty) ...[
                const Divider(),
                const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(quotation.notes!),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleQuotationAction(String action, QuotationModel quotation) {
    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => QuotationFormDialog(quotation: quotation),
        );
        break;
      case 'duplicate':
        _duplicateQuotation(quotation);
        break;
      case 'convert':
        _showConvertDialog(quotation);
        break;
      case 'delete':
        _showDeleteDialog(quotation);
        break;
    }
  }
  
  void _duplicateQuotation(QuotationModel quotation) async {
    final quotationService = ref.read(quotationServiceProvider);
    final newQuotation = QuotationModel.create(
      validityDate: DateTime.now().add(const Duration(days: 30)),
      customerId: quotation.customerId,
      customerName: quotation.customerName,
      customerPhone: quotation.customerPhone,
      customerEmail: quotation.customerEmail,
      items: quotation.items,
      subtotal: quotation.subtotal,
      discount: quotation.discount,
      tax: quotation.tax,
      total: quotation.total,
      notes: quotation.notes,
      terms: quotation.terms,
    );
    
    await quotationService.saveQuotation(newQuotation);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quotation duplicated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _showConvertDialog(QuotationModel quotation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convert to Invoice'),
        content: Text('Convert quotation ${quotation.quotationNumber} to an invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(quotationServiceProvider).convertToInvoice(quotation.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quotation converted to invoice'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Convert'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteDialog(QuotationModel quotation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quotation'),
        content: Text('Are you sure you want to delete quotation ${quotation.quotationNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(quotationServiceProvider).deleteQuotation(quotation.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quotation deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _sendQuotation(QuotationModel quotation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Send quotation ${quotation.quotationNumber}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  void _printQuotation(QuotationModel quotation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Print quotation ${quotation.quotationNumber}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}