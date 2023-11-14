import 'package:flutter/material.dart';
import 'dart:collection';

class CategoryData extends ChangeNotifier {
  //TODO: In der Methode entsprechende Hive Box öffnen (wo erstellen?? main?) und Item hinzufügen (String).
  final List<String> _incomeCategories = [];
  final List<String> _expenseCategories = [];

  UnmodifiableListView<String> get incomeCategories =>
      UnmodifiableListView(_incomeCategories);
  UnmodifiableListView<String> get expenseCategories =>
      UnmodifiableListView(_expenseCategories);

  void addIncomeCategory(String categ) {
    _incomeCategories.add(categ);
    notifyListeners();
  }

  void addExpenseCategory(String categ) {
    _expenseCategories.add(categ);
    notifyListeners();
  }

  void removeIncomeCategory(String categ) {
    _incomeCategories.remove(categ);
    notifyListeners();
  }

  void removeExpenseCategory(String categ) {
    _expenseCategories.remove(categ);
    notifyListeners();
  }

  List<DropdownMenuItem<String>> getExpenseDropdownList() {
    List<DropdownMenuItem<String>> dropdownItems =
        _expenseCategories.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    return dropdownItems;
  }

  List<DropdownMenuItem<String>> getIncomeDropdownList() {
    List<DropdownMenuItem<String>> dropdownItems =
        _incomeCategories.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    return dropdownItems;
  }
}
