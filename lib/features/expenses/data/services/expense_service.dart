import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';

class ExpenseService {
  static const String _boxName = 'expenses';
  
  Future<Box<ExpenseModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<ExpenseModel>(_boxName);
    }
    return Hive.box<ExpenseModel>(_boxName);
  }
  
  Future<List<ExpenseModel>> getExpenses() async {
    final box = await _getBox();
    return box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  
  Future<void> addExpense(ExpenseModel expense) async {
    final box = await _getBox();
    await box.put(expense.id, expense);
  }
  
  Future<void> updateExpense(ExpenseModel expense) async {
    final box = await _getBox();
    await box.put(expense.id, expense);
  }
  
  Future<void> deleteExpense(String expenseId) async {
    final box = await _getBox();
    await box.delete(expenseId);
  }
  
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final expenses = await getExpenses();
    return expenses.where((expense) => 
      expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
      expense.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }
  
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    final expenses = await getExpenses();
    return expenses.where((expense) => expense.category == category).toList();
  }
  
  Future<double> getTotalExpenses() async {
    final expenses = await getExpenses();
    return expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
  }
}