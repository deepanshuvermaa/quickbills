import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expenses_provider.dart';
import '../widgets/add_expense_dialog.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['All', 'Office', 'Travel', 'Marketing', 'Utilities', 'Other'];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpensesList(),
          _buildAnalytics(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpensesList() {
    return Column(
      children: [
        // Total Summary Card
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Expenses',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          return ref.watch(expensesProvider).when(
                            data: (expenses) {
                              final total = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
                              return Text(
                                '₹${total.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const Text('₹0.00'),
                          );
                        },
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.trending_up, size: 16, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          'Track expenses',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Expenses List
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              return ref.watch(expensesProvider).when(
                data: (expenses) {
                  // Filter by category if needed
                  final filteredExpenses = _selectedCategory == 'All' 
                      ? expenses 
                      : expenses.where((e) => e.category == _selectedCategory).toList();
                  
                  if (filteredExpenses.isEmpty) {
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
                            'No expenses yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start tracking your expenses',
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getCategoryColorFromName(expense.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIconFromName(expense.category),
                              color: _getCategoryColorFromName(expense.category),
                            ),
                          ),
                          title: Text(
                            expense.description ?? 'Expense',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.category,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                expense.date.toString().split(' ')[0],
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: Text(
                            '₹${expense.amount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                          ),
                          onTap: () => _showExpenseDetails(context, expense),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: ${error.toString()}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Consumer(
            builder: (context, ref, _) {
              return ref.watch(expensesProvider).when(
                data: (expenses) {
                  final total = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
                  final average = expenses.isEmpty ? 0.0 : total / expenses.length;
                  final highest = expenses.isEmpty ? 0.0 : expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
                  
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total',
                              '₹${total.toStringAsFixed(2)}',
                              Icons.receipt_long,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Count',
                              '${expenses.length}',
                              Icons.numbers,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Average',
                              '₹${average.toStringAsFixed(2)}',
                              Icons.show_chart,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Highest',
                              '₹${highest.toStringAsFixed(2)}',
                              Icons.arrow_upward,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading analytics'),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Category Breakdown
          Text(
            'Expenses by Category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          Consumer(
            builder: (context, ref, _) {
              return ref.watch(expensesByCategoryProvider).when(
                data: (categoryTotals) {
                  if (categoryTotals.isEmpty) {
                    return const Text('No expense data available');
                  }
                  
                  final totalAmount = categoryTotals.values.fold<double>(0, (sum, amount) => sum + amount);
                  
                  return Column(
                    children: categoryTotals.entries.map((entry) {
                      final percentage = totalAmount > 0 ? (entry.value / totalAmount * 100) : 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _getCategoryIconFromName(entry.key),
                                      color: _getCategoryColorFromName(entry.key),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(entry.key),
                                  ],
                                ),
                                Text(
                                  '₹${entry.value.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColorFromName(entry.key)),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading category data'),
              );
            },
          ),
        ],
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIconFromName(String category) {
    switch (category.toLowerCase()) {
      case 'office':
        return Icons.business_center;
      case 'travel':
        return Icons.flight;
      case 'marketing':
        return Icons.campaign;
      case 'utilities':
        return Icons.bolt;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.attach_money;
    }
  }

  Color _getCategoryColorFromName(String category) {
    switch (category.toLowerCase()) {
      case 'office':
        return Colors.blue;
      case 'travel':
        return Colors.orange;
      case 'marketing':
        return Colors.purple;
      case 'utilities':
        return Colors.green;
      case 'other':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Date Range'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement date range picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Amount Range'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement amount range
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Sort By'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sort options
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addNewExpense() {
    showDialog(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );
  }

  void _showExpenseDetails(BuildContext context, expense) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Amount'),
              trailing: Text('₹${expense.amount.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Category'),
              trailing: Text(expense.category),
            ),
            ListTile(
              title: const Text('Description'),
              trailing: Text(expense.description ?? 'No description'),
            ),
            ListTile(
              title: const Text('Date'),
              trailing: Text(expense.date.toString().split(' ')[0]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditExpenseDialog(context, expense);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteExpense(context, expense);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEditExpenseDialog(BuildContext context, expense) {
    showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(expense: expense),
    );
  }
  
  void _deleteExpense(BuildContext context, expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense of ₹${expense.amount.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final service = ref.read(expenseServiceProvider);
              await service.deleteExpense(expense.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Expense deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}