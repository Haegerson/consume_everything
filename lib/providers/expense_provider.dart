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

// New method to get monthly expenses
  Future<Map<String, double>> getMonthlyExpenses(int year) async {
    List<Expenses> expenses = await getExpenses();
    Map<String, double> monthlyExpenses = {};

    // Initialize monthlyExpenses with all months set to zero
    for (int month = 1; month <= 12; month++) {
      monthlyExpenses[month.toString()] = 0.0;
    }

    // Filter expenses for the specified year
    List<Expenses> filteredExpenses =
        expenses.where((expense) => expense.date.year == year).toList();

    // Update the amount list
    for (Expenses expense in filteredExpenses) {
      String month = '${expense.date.month}';
      if (monthlyExpenses.containsKey(month)) {
        monthlyExpenses[month] = monthlyExpenses[month]! + expense.amount;
      } else {
        monthlyExpenses[month] = expense.amount;
      }
    }
    return monthlyExpenses;
  }

  // remove a test expense
  Future<void> deleteExpense(Expenses exp) async {
    Box<Expenses> box = await Hive.openBox<Expenses>(expensesHiveBox);
    await box.delete(exp.key);
    _expenses = box.values.toList();
    notifyListeners();
  }
}
