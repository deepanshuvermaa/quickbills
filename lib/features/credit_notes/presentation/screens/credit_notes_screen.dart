import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreditNotesScreen extends ConsumerStatefulWidget {
  const CreditNotesScreen({super.key});

  @override
  ConsumerState<CreditNotesScreen> createState() => _CreditNotesScreenState();
}

class _CreditNotesScreenState extends ConsumerState<CreditNotesScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Pending', 'Applied', 'Expired'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuAction(value);
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
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 8),
                    Text('Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Credit',
                    '₹12,450.00',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Available',
                    '₹8,230.00',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Applied',
                    '₹4,220.00',
                    Icons.assignment_turned_in,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          // Filter Section
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
          
          // Credit Notes List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 15,
              itemBuilder: (context, index) {
                final status = _getStatus(index);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showCreditNoteDetails(context, index),
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
                                      color: _getStatusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.receipt,
                                      color: _getStatusColor(status),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CN-${2024000 + index}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'Invoice #INV-${1000 + index}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Chip(
                                label: Text(
                                  status,
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _getStatusColor(status).withOpacity(0.1),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Customer ${index + 1}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateTime.now().subtract(Duration(days: index * 3)).toString().split(' ')[0],
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Credit Amount',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '₹${(500 + index * 100).toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              if (status == 'Applied')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Applied Amount',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      '₹${(300 + index * 50).toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              if (status == 'Pending')
                                TextButton(
                                  onPressed: () => _applyCreditNote(index),
                                  child: const Text('Apply'),
                                ),
                            ],
                          ),
                          if (index % 4 == 0) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Expires in ${30 - index} days',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.amber[700],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewCreditNote,
        icon: const Icon(Icons.add),
        label: const Text('New Credit Note'),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatus(int index) {
    if (index % 3 == 0) return 'Pending';
    if (index % 3 == 1) return 'Applied';
    return 'Expired';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Applied':
        return Colors.green;
      case 'Expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Credit Notes'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Credit notes are issued when you need to:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Provide a refund to a customer'),
              Text('• Correct an overcharge on an invoice'),
              Text('• Apply a discount after invoicing'),
              Text('• Handle returned goods'),
              SizedBox(height: 12),
              Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Create a credit note linked to an invoice'),
              Text('2. Apply it to offset future invoices'),
              Text('3. Or process a refund directly'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exporting credit notes...'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generating report...'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
    }
  }

  void _createNewCreditNote() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Credit Note',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Invoice Number',
                hintText: 'Enter invoice number',
                prefixIcon: Icon(Icons.receipt_long),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Credit Amount',
                hintText: 'Enter amount',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Enter reason for credit note',
                prefixIcon: Icon(Icons.comment),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Credit note created'),
                        ),
                      );
                    },
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCreditNoteDetails(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
                'Credit Note CN-${2024000 + index}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Related Invoice'),
                subtitle: Text('INV-${1000 + index}'),
              ),
              ListTile(
                title: const Text('Customer'),
                subtitle: Text('Customer ${index + 1}'),
              ),
              ListTile(
                title: const Text('Issue Date'),
                subtitle: Text(
                  DateTime.now().subtract(Duration(days: index * 3)).toString().split(' ')[0],
                ),
              ),
              ListTile(
                title: const Text('Status'),
                subtitle: Text(_getStatus(index)),
              ),
              const Divider(),
              ListTile(
                title: const Text('Credit Amount'),
                trailing: Text(
                  '₹${(500 + index * 100).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (_getStatus(index) == 'Applied')
                ListTile(
                  title: const Text('Applied Amount'),
                  trailing: Text(
                    '₹${(300 + index * 50).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ListTile(
                title: const Text('Remaining Balance'),
                trailing: Text(
                  '₹${(200 + index * 50).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(),
              const ListTile(
                title: Text('Reason'),
                subtitle: Text('Product return - damaged goods'),
              ),
              const SizedBox(height: 16),
              if (_getStatus(index) == 'Pending')
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyCreditNote(index);
                  },
                  child: const Text('Apply to Invoice'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyCreditNote(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Credit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select an invoice to apply this credit note to:'),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, invoiceIndex) {
                  return ListTile(
                    title: Text('Invoice #INV-${2000 + invoiceIndex}'),
                    subtitle: Text('Amount: ₹${(1000 + invoiceIndex * 200).toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Credit note applied to Invoice #INV-${2000 + invoiceIndex}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
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
}