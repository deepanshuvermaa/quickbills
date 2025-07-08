import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/bill_model.dart';
import '../providers/billing_provider.dart';

class BillsHistoryScreen extends ConsumerStatefulWidget {
  const BillsHistoryScreen({super.key});

  @override
  ConsumerState<BillsHistoryScreen> createState() => _BillsHistoryScreenState();
}

class _BillsHistoryScreenState extends ConsumerState<BillsHistoryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Completed', 'Draft', 'Cancelled'];
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(billsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search bills...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
          
          // Bills List
          Expanded(
            child: billsAsync.when(
              data: (bills) {
                // Filter bills
                var filteredBills = bills;
                
                // Apply status filter
                if (_selectedFilter != 'All') {
                  filteredBills = filteredBills.where((bill) {
                    switch (_selectedFilter) {
                      case 'Completed':
                        return bill.status == BillStatus.completed;
                      case 'Draft':
                        return bill.status == BillStatus.draft;
                      case 'Cancelled':
                        return bill.status == BillStatus.cancelled;
                      default:
                        return true;
                    }
                  }).toList();
                }
                
                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  filteredBills = filteredBills.where((bill) {
                    return bill.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (bill.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                        bill.items.any((item) => item.productName.toLowerCase().contains(_searchQuery.toLowerCase()));
                  }).toList();
                }
                
                // Apply date range filter
                if (_selectedDateRange != null) {
                  filteredBills = filteredBills.where((bill) {
                    return bill.createdAt.isAfter(_selectedDateRange!.start) &&
                        bill.createdAt.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
                  }).toList();
                }
                
                if (filteredBills.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bills found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFilter == 'All' ? 'Start creating bills' : 'Try changing the filter',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBills.length,
                  itemBuilder: (context, index) {
                    final bill = filteredBills[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(bill.status),
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          bill.invoiceNumber,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (bill.customerName != null)
                              Text(
                                bill.customerName!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            Text(
                              DateFormat('MMM dd, yyyy - hh:mm a').format(bill.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${bill.total.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Chip(
                              label: Text(
                                _getStatusText(bill.status),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _getStatusColor(bill.status).withOpacity(0.2),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        onTap: () {
                          context.push('/billing/invoice/${bill.id}');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading bills: $error'),
              ),
            ),
          ),
        ],
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date Range'),
              trailing: const Icon(Icons.date_range),
              onTap: () {
                Navigator.pop(context);
                _selectDateRange();
              },
            ),
            ListTile(
              title: const Text('Amount Range'),
              trailing: const Icon(Icons.attach_money),
              onTap: () {
                Navigator.pop(context);
                // Implement amount range filter
              },
            ),
            ListTile(
              title: const Text('Customer'),
              trailing: const Icon(Icons.person),
              onTap: () {
                Navigator.pop(context);
                // Implement customer filter
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
}