import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/expense_model.dart';

final expensesProvider = StateNotifierProvider<ExpensesNotifier, AsyncValue<List<ExpenseModel>>>((ref) {
  return ExpensesNotifier();
});

class ExpensesNotifier extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  ExpensesNotifier() : super(const AsyncValue.loading()) {
    _loadExpenses();
  }
  
  Future<void> _loadExpenses() async {
    try {
      Box<ExpenseModel> box;
      const boxName = 'expenses';
      
      if (Hive.isBoxOpen(boxName)) {
        box = Hive.box<ExpenseModel>(boxName);
      } else {
        box = await Hive.openBox<ExpenseModel>(boxName);
      }
      
      // Add mock data if empty
      if (box.isEmpty) {
        await _addMockExpenses(box);
      }
      
      final expenses = box.values.toList();
      state = AsyncValue.data(expenses);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> _addMockExpenses(Box<ExpenseModel> box) async {
    final now = DateTime.now();
    final mockExpenses = [
      ExpenseModel.create(
        title: 'Office Rent - July',
        category: ExpenseCategory.rent,
        amount: 25000,
        date: DateTime(now.year, now.month, 1),
        paymentMethod: 'Bank Transfer',
        vendor: 'XYZ Properties',
        isRecurring: true,
        recurringFrequency: 'Monthly',
      ),
      ExpenseModel.create(
        title: 'Employee Salaries',
        category: ExpenseCategory.salaries,
        amount: 85000,
        date: DateTime(now.year, now.month, 5),
        paymentMethod: 'Bank Transfer',
        description: 'Monthly salaries for 3 employees',
        isRecurring: true,
        recurringFrequency: 'Monthly',
      ),
      ExpenseModel.create(
        title: 'Electricity Bill',
        category: ExpenseCategory.utilities,
        amount: 3500,
        date: now.subtract(const Duration(days: 3)),
        paymentMethod: 'UPI',
        vendor: 'State Electricity Board',
      ),
      ExpenseModel.create(
        title: 'Office Supplies',
        category: ExpenseCategory.purchase,
        amount: 5200,
        date: now.subtract(const Duration(days: 5)),
        paymentMethod: 'Cash',
        description: 'Printer paper, pens, and stationery',
      ),
      ExpenseModel.create(
        title: 'Facebook Ads',
        category: ExpenseCategory.marketing,
        amount: 10000,
        date: now.subtract(const Duration(days: 7)),
        paymentMethod: 'Card',
        vendor: 'Meta Business',
      ),
      ExpenseModel.create(
        title: 'AC Maintenance',
        category: ExpenseCategory.maintenance,
        amount: 1500,
        date: now.subtract(const Duration(days: 10)),
        paymentMethod: 'Cash',
        vendor: 'Cool Services',
      ),
      ExpenseModel.create(
        title: 'Delivery Van Fuel',
        category: ExpenseCategory.transport,
        amount: 2800,
        date: now.subtract(const Duration(days: 2)),
        paymentMethod: 'Card',
        vendor: 'HP Petrol Pump',
      ),
    ];
    
    for (final expense in mockExpenses) {
      await box.put(expense.id, expense);
    }
  }
  
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final box = Hive.box<ExpenseModel>('expenses');
      await box.put(expense.id, expense);
      await _loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      final box = Hive.box<ExpenseModel>('expenses');
      await box.put(expense.id, expense);
      await _loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> deleteExpense(String id) async {
    try {
      final box = Hive.box<ExpenseModel>('expenses');
      await box.delete(id);
      await _loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  List<ExpenseModel> getExpensesByCategory(String category) {
    return state.maybeWhen(
      data: (expenses) => expenses.where((e) => e.category == category).toList(),
      orElse: () => [],
    );
  }
  
  double getTotalExpensesByDateRange(DateTime start, DateTime end) {
    return state.maybeWhen(
      data: (expenses) => expenses
          .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
          .fold(0.0, (sum, e) => sum + e.amount),
      orElse: () => 0,
    );
  }
}