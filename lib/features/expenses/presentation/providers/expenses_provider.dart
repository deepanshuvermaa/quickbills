import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/expense_model.dart';
import '../../data/services/expense_service.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

final expensesProvider = FutureProvider<List<ExpenseModel>>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getExpenses();
});

final expensesByCategoryProvider = FutureProvider<Map<String, double>>((ref) async {
  final expenses = await ref.watch(expensesProvider.future);
  final categoryTotals = <String, double>{};
  
  for (final expense in expenses) {
    categoryTotals[expense.category] = 
        (categoryTotals[expense.category] ?? 0) + expense.amount;
  }
  
  return categoryTotals;
});

final monthlyExpensesProvider = FutureProvider<Map<String, double>>((ref) async {
  final expenses = await ref.watch(expensesProvider.future);
  final monthlyTotals = <String, double>{};
  
  for (final expense in expenses) {
    final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
    monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
  }
  
  return monthlyTotals;
});