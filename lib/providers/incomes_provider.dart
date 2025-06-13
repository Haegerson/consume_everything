import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'package:expenso/models/income.dart';
import 'package:expenso/services/income_api.dart';
import 'package:expenso/providers/categories_provider.dart';

class IncomesProvider extends ChangeNotifier {
  final IncomeApi _api;
  final List<Income> _incomes = [];

  UnmodifiableListView<Income> get incomes => UnmodifiableListView(_incomes);

  bool _loading = false;
  String? _error;
  bool get isLoading => _loading;
  String? get error => _error;

  IncomesProvider(this._api);

  Future<void> loadIncomes() async {
    _setLoading(true);
    try {
      final fetched = await _api.fetchAll();
      _incomes
        ..clear()
        ..addAll(fetched);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Income>> getIncomes() async {
    if (_incomes.isEmpty) await loadIncomes();
    return _incomes;
  }

  Future<void> createIncome(Income inc) async {
    _setLoading(true);
    try {
      // Let Xano assign the real ID by passing null
      final toCreate = Income(
        id: null,
        categoryId: inc.categoryId,
        amount: inc.amount,
        comment: inc.comment,
        date: inc.date,
      );
      final created = await _api.create(toCreate);
      _incomes.add(created);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteIncome(int id) async {
    _setLoading(true);
    try {
      await _api.delete(id);
      _incomes.removeWhere((i) => i.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Monthly totals for a given year
  Future<Map<String, double>> getMonthlyIncomes(int year) async {
    if (_incomes.isEmpty) await loadIncomes();

    final monthly = {for (int m = 1; m <= 12; m++) '$m': 0.0};

    for (final inc in _incomes.where((i) => i.date.year == year)) {
      final key = '${inc.date.month}';
      monthly[key] = monthly[key]! + inc.amount;
    }
    return monthly;
  }

  /// Total for the current month
  Future<double> getCurrentIncomes() async {
    if (_incomes.isEmpty) await loadIncomes();

    final now = DateTime.now();
    return _incomes
        .where((i) => i.date.year == now.year && i.date.month == now.month)
        .fold<double>(
          0.0,
          (double sum, income) => sum + income.amount,
        );
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
