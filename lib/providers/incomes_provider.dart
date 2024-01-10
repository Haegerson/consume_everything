import 'package:expenso/hives/incomes.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'dart:collection';

class IncomesProvider extends ChangeNotifier {
  List<Incomes> _incomes = [];
  UnmodifiableListView<Incomes> get incomes => UnmodifiableListView(_incomes);
  final String incomesHiveBox = 'incomes-box';

  // Create test expense
  Future<void> createIncome(Incomes inc) async {
    Box<Incomes> box = await Hive.openBox<Incomes>(incomesHiveBox);
    await box.add(inc);
    _incomes.add(inc);
    _incomes = box.values.toList();
    notifyListeners();
  }

  // Get list of all Incomes
  Future<List<Incomes>> getIncomes() async {
    Box<Incomes> box = await Hive.openBox<Incomes>(incomesHiveBox);
    _incomes = box.values.toList();
    return _incomes;
  }

  // remove a n income
  Future<void> deleteIncome(Incomes inc) async {
    Box<Incomes> box = await Hive.openBox<Incomes>(incomesHiveBox);
    await box.delete(inc.key);
    _incomes = box.values.toList();
    notifyListeners();
  }

  // Get monthly expenses
  Future<Map<String, double>> getMonthlyIncomes(int year) async {
    List<Incomes> incomes = await getIncomes();
    Map<String, double> monthlyIncomes = {};

    // Initialize monthlyExpenses with all months set to zero
    for (int month = 1; month <= 12; month++) {
      monthlyIncomes[month.toString()] = 0.0;
    }

    // Filter expenses for the specified year
    List<Incomes> filteredIncomes =
        incomes.where((income) => income.date.year == year).toList();

    // Update the amount list
    for (Incomes income in filteredIncomes) {
      String month = '${income.date.month}';
      if (monthlyIncomes.containsKey(month)) {
        monthlyIncomes[month] = monthlyIncomes[month]! + income.amount;
      } else {
        monthlyIncomes[month] = income.amount;
      }
    }
    return monthlyIncomes;
  }
}
