import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../billing/presentation/providers/billing_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../data/models/daily_closing_model.dart';
import '../../data/services/daily_closing_service.dart';

class DailyClosingScreen extends ConsumerStatefulWidget {
  const DailyClosingScreen({super.key});

  @override
  ConsumerState<DailyClosingScreen> createState() => _DailyClosingScreenState();
}

class _DailyClosingScreenState extends ConsumerState<DailyClosingScreen> {
  final _openingCashController = TextEditingController();
  final _actualCashController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  double _totalSales = 0;
  double _cashSales = 0;
  double _cardSales = 0;
  double _upiSales = 0;
  double _totalExpenses = 0;
  double _expectedCash = 0;
  double _difference = 0;
  
  @override
  void initState() {
    super.initState();
    _calculateDailySummary();
    _loadDraftOrLastClosing();
  }
  
  Future<void> _loadDraftOrLastClosing() async {
    final dailyClosingService = ref.read(dailyClosingServiceProvider);
    
    // Check if there's a draft or completed closing for today
    final existingClosing = await dailyClosingService.getClosingForDate(_selectedDate);
    if (existingClosing != null) {
      setState(() {
        _openingCashController.text = existingClosing.openingCash.toString();
        _actualCashController.text = existingClosing.actualCash.toString();
        _notesController.text = existingClosing.notes ?? '';
      });
      _calculateDifference();
    } else {
      // Load opening cash from previous day's closing
      final lastClosingCash = await dailyClosingService.getLastClosingCash();
      setState(() {
        _openingCashController.text = lastClosingCash.toString();
      });
    }
  }
  
  Future<void> _calculateDailySummary() async {
    final billingService = ref.read(billingServiceProvider);
    final expenseService = ref.read(expenseServiceProvider);
    
    // Get today's bills
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final todayBills = await billingService.getBillsByDateRange(startOfDay, endOfDay);
    final completedBills = todayBills.where((bill) => bill.status.name == 'completed').toList();
    
    // Calculate sales by payment method
    _totalSales = 0;
    _cashSales = 0;
    _cardSales = 0;
    _upiSales = 0;
    
    for (final bill in completedBills) {
      _totalSales += bill.total;
      
      if (bill.paymentSplits != null && bill.paymentSplits!.isNotEmpty) {
        for (final split in bill.paymentSplits!) {
          switch (split.method.toLowerCase()) {
            case 'cash':
              _cashSales += split.amount;
              break;
            case 'card':
              _cardSales += split.amount;
              break;
            case 'upi':
              _upiSales += split.amount;
              break;
          }
        }
      } else {
        switch (bill.paymentMethod.toLowerCase()) {
          case 'cash':
            _cashSales += bill.total;
            break;
          case 'card':
            _cardSales += bill.total;
            break;
          case 'upi':
            _upiSales += bill.total;
            break;
        }
      }
    }
    
    // Get today's expenses
    final todayExpenses = await expenseService.getExpensesByDateRange(startOfDay, endOfDay);
    _totalExpenses = todayExpenses.fold(0, (sum, expense) => sum + expense.amount);
    
    setState(() {});
  }
  
  void _calculateDifference() {
    final openingCash = double.tryParse(_openingCashController.text) ?? 0;
    final actualCash = double.tryParse(_actualCashController.text) ?? 0;
    
    _expectedCash = openingCash + _cashSales - _totalExpenses;
    _difference = actualCash - _expectedCash;
    
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Closing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Closing Date'),
                subtitle: Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Sales Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.point_of_sale, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Sales Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildSummaryRow('Total Sales', _totalSales, Colors.green),
                    _buildSummaryRow('Cash Sales', _cashSales, Colors.blue),
                    _buildSummaryRow('Card Sales', _cardSales, Colors.orange),
                    _buildSummaryRow('UPI Sales', _upiSales, Colors.purple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Expense Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.money_off, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Expenses',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildSummaryRow('Total Expenses', _totalExpenses, Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Cash Reconciliation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          'Cash Reconciliation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const Divider(),
                    TextField(
                      controller: _openingCashController,
                      decoration: const InputDecoration(
                        labelText: 'Opening Cash',
                        prefixText: '₹ ',
                        prefixIcon: Icon(Icons.account_balance_wallet),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateDifference(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _actualCashController,
                      decoration: const InputDecoration(
                        labelText: 'Actual Cash in Hand',
                        prefixText: '₹ ',
                        prefixIcon: Icon(Icons.money),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateDifference(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Expected Cash', _expectedCash, Colors.blue),
                          const Divider(),
                          _buildSummaryRow(
                            'Difference',
                            _difference,
                            _difference == 0
                                ? Colors.green
                                : _difference > 0
                                    ? Colors.orange
                                    : Colors.red,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Closing Notes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Add any notes or observations...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveDraft,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Draft'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _difference == 0 ? _closeDay : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Close Day'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
            if (_difference != 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Cash must be reconciled before closing the day',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, double amount, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _calculateDailySummary();
    }
  }
  
  void _saveDraft() async {
    final openingCash = double.tryParse(_openingCashController.text) ?? 0;
    final actualCash = double.tryParse(_actualCashController.text) ?? 0;
    
    final closing = DailyClosingModel(
      id: _selectedDate.toIso8601String(),
      date: _selectedDate,
      openingCash: openingCash,
      actualCash: actualCash,
      totalSales: _totalSales,
      cashSales: _cashSales,
      cardSales: _cardSales,
      upiSales: _upiSales,
      totalExpenses: _totalExpenses,
      expectedCash: _expectedCash,
      difference: _difference,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      isDraft: true,
      createdAt: DateTime.now(),
    );
    
    try {
      final dailyClosingService = ref.read(dailyClosingServiceProvider);
      await dailyClosingService.saveDraft(closing);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save draft: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _closeDay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Day Closing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
            const SizedBox(height: 8),
            Text('Total Sales: ₹${_totalSales.toStringAsFixed(2)}'),
            Text('Total Expenses: ₹${_totalExpenses.toStringAsFixed(2)}'),
            Text('Cash in Hand: ₹${_actualCashController.text}'),
            const SizedBox(height: 16),
            const Text(
              'Once closed, this day cannot be edited.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDayClosing();
            },
            child: const Text('Confirm & Close'),
          ),
        ],
      ),
    );
  }
  
  void _performDayClosing() async {
    final openingCash = double.tryParse(_openingCashController.text) ?? 0;
    final actualCash = double.tryParse(_actualCashController.text) ?? 0;
    
    final closing = DailyClosingModel(
      id: _selectedDate.toIso8601String(),
      date: _selectedDate,
      openingCash: openingCash,
      actualCash: actualCash,
      totalSales: _totalSales,
      cashSales: _cashSales,
      cardSales: _cardSales,
      upiSales: _upiSales,
      totalExpenses: _totalExpenses,
      expectedCash: _expectedCash,
      difference: _difference,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      isDraft: false,
      createdAt: DateTime.now(),
      closedAt: DateTime.now(),
    );
    
    try {
      final dailyClosingService = ref.read(dailyClosingServiceProvider);
      await dailyClosingService.closeDay(closing);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Day closed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to close day: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _openingCashController.dispose();
    _actualCashController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}