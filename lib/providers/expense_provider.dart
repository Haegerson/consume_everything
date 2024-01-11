import 'package:expenso/const/constants.dart';
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

// Get monthly expenses
  Future<Map<String, double>> getMonthlyExpenses(int year, String type) async {
    List<Expenses> expenses = await getExpenses();
    Map<String, double> monthlyExpenses = {};

    // Initialize monthlyExpenses with all months set to zero
    for (int month = 1; month <= 12; month++) {
      monthlyExpenses[month.toString()] = 0.0;
    }

    // Filter expenses for the specified year
    List<Expenses> filteredExpenses = expenses
        .where((expense) =>
            (expense.date.year == year) && (expense.category.type == type))
        .toList();

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

  // remove an expense
  Future<void> deleteExpense(Expenses exp) async {
    Box<Expenses> box = await Hive.openBox<Expenses>(expensesHiveBox);
    await box.delete(exp.key);
    _expenses = box.values.toList();
    notifyListeners();
  }

  // Calculate category percentages relative to all expenses between two year/months
  Future<Map<String, Map<String, dynamic>>> calculateCategoryPercentagesBetween(
      int startYear, int startMonth, int endYear, int endMonth) async {
    List<Expenses> expenses = await getExpenses();

    // filter the list
    List<Expenses> filteredExpenses = expenses
        .where((expense) =>
            expense.date.isAtSameMomentAs(DateTime(startYear, startMonth)) ||
            expense.date.isAtSameMomentAs(DateTime(endYear, endMonth)) ||
            expense.date.isAfter(DateTime(startYear, startMonth)) &&
                expense.date.isBefore(DateTime(endYear, endMonth)))
        .toList();

    double totalExpenses =
        filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    Map<String, double> totalAmountPerCategory = {};

    // Calculate total amount per category between the specified period
    filteredExpenses.forEach((expense) {
      String categoryKey =
          expense.category.name; // Assuming 'name' is the category identifier
      totalAmountPerCategory.update(
          categoryKey, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    });

    // Calculate percentages and absolute values
    Map<String, Map<String, dynamic>> categoryData = {};

    totalAmountPerCategory.forEach((category, amount) {
      double percentage = (amount / totalExpenses) * 100;
      categoryData[category] = {
        'percentage': percentage,
        'absoluteValue': amount,
      };
    });

    return categoryData;
  }
}
