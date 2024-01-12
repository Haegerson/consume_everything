import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  double? _expenseThreshold;

  // Get the current expense threshold
  double? get expenseThreshold => _expenseThreshold;

  // Change the expense threshold
  void setExpenseThreshold(double newThreshold) {
    _expenseThreshold = newThreshold;
    notifyListeners();
  }
}
