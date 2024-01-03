import 'package:expenso/hives/expenses.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'dart:collection';

class ExpensesProvider extends ChangeNotifier {
  List<Expenses> _expenses = [];
  UnmodifiableListView<Expenses> get expenses =>
      UnmodifiableListView(_expenses);
  final String expensesHiveBox = 'expenses-box';

  // Add a new Expense
  Future<void> createExpense(Expenses exp) async {
    Box<Expenses> box = await Hive.openBox<Expenses>(expensesHiveBox);
    await box.add(exp);
    _expenses.add(exp);
    _expenses = box.values.toList();
    notifyListeners();
  }

  // Get list of all Expenses
  Future<List<Expenses>> getExpenses() async {
    Box<Expenses> box = await Hive.openBox<Expenses>(expensesHiveBox);
    _expenses = box.values.toList();
    return _expenses;
  }

  // remove a test expense
  Future<void> deleteExpense(Expenses exp) async {
    Box<Expenses> box = await Hive.openBox<Expenses>(expensesHiveBox);
    await box.delete(exp.key);
    _expenses = box.values.toList();
    notifyListeners();
  }
}
