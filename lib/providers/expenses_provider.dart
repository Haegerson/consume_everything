import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:expenso/models/expense.dart';
import 'package:expenso/services/expense_api.dart';
import 'package:expenso/providers/categories_provider.dart';

class ExpensesProvider extends ChangeNotifier {
  final ExpenseApi _api;
  final List<Expense> _expenses = [];

  UnmodifiableListView<Expense> get expenses => UnmodifiableListView(_expenses);

  bool _loading = false;
  String? _error;
  bool get isLoading => _loading;
  String? get error => _error;

  ExpensesProvider(this._api);

  Future<void> loadExpenses() async {
    _setLoading(true);
    try {
      final fetched = await _api.fetchAll();
      _expenses
        ..clear()
        ..addAll(fetched);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Expense>> getExpenses() async {
    if (_expenses.isEmpty) await loadExpenses();
    return _expenses;
  }

  Future<void> createExpense(Expense exp) async {
    _setLoading(true);
    try {
      final created = await _api.create(exp);
      _expenses.add(created);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExpense(int id) async {
    _setLoading(true);
    try {
      await _api.delete(id);
      _expenses.removeWhere((e) => e.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Get monthly totals for a given year, filter by category type and list of category IDs
  Future<Map<String, double>> getMonthlyExpenses(
      int year, String type, List<int> categoryIds,
      {required CategoriesProvider categoriesProvider}) async {
    if (_expenses.isEmpty) await loadExpenses();

    // build a map month→0
    final Map<String, double> monthly = {
      for (int m = 1; m <= 12; m++) '$m': 0.0
    };

    final filtered = _expenses.where((e) {
      final cat = categoriesProvider.getById(e.categoryId);
      return e.date.year == year &&
          cat.type == type &&
          categoryIds.contains(e.categoryId);
    });

    for (final e in filtered) {
      final key = '${e.date.month}';
      monthly[key] = monthly[key]! + e.amount;
    }
    return monthly;
  }

  Future<double> getCurrentExpenses(String type,
      {required CategoriesProvider categoriesProvider}) async {
    if (_expenses.isEmpty) await loadExpenses();

    final now = DateTime.now();
    final filtered = _expenses.where((e) {
      final cat = categoriesProvider.getById(e.categoryId);
      return e.date.year == now.year &&
          e.date.month == now.month &&
          cat.type == type;
    });

    return filtered.fold<double>(
      0.0,
      (double sum, e) => sum + e.amount,
    );
  }

  Future<Map<String, Map<String, dynamic>>> calculateCategoryPercentagesBetween(
      int startYear, int startMonth, int endYear, int endMonth,
      {required CategoriesProvider categoriesProvider}) async {
    if (_expenses.isEmpty) await loadExpenses();

    final start = DateTime(startYear, startMonth);
    final end = DateTime(endYear, endMonth, 23, 59, 59);

    final inRange = _expenses.where((e) =>
        (e.date.isAtSameMomentAs(start) || e.date.isAfter(start)) &&
        (e.date.isAtSameMomentAs(end) || e.date.isBefore(end)));

    final total = inRange.fold(0.0, (s, e) => s + e.amount);
    final perCat = <int, double>{};

    for (final e in inRange) {
      perCat[e.categoryId] = (perCat[e.categoryId] ?? 0) + e.amount;
    }

    final result = <String, Map<String, dynamic>>{};
    perCat.forEach((catId, amt) {
      final cat = categoriesProvider.getById(catId);
      result[cat.name] = {
        'percentage': total == 0 ? 0 : (amt / total) * 100,
        'absoluteValue': amt,
      };
    });
    return result;
  }

  Future<Map<String, double>> getCategoriesOverThreshold(
      {required CategoriesProvider categoriesProvider}) async {
    if (_expenses.isEmpty) await loadExpenses();

    final now = DateTime.now();
    final monthExpenses = _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month);

    final Map<String, double> map = {};
    for (final e in monthExpenses) {
      final cat = categoriesProvider.getById(e.categoryId);
      final thr = cat.alertThreshold;
      if (thr != null && e.amount > thr) {
        map[cat.name] = (map[cat.name] ?? 0) + e.amount;
      }
    }
    return map;
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
