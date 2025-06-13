import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:expenso/models/category.dart';
import 'package:expenso/services/category_api.dart';
import 'package:expenso/const/constants.dart';

class CategoriesProvider extends ChangeNotifier {
  final CategoryApi _api;
  final List<Category> _categories = [];

  UnmodifiableListView<Category> get categories =>
      UnmodifiableListView(_categories);

  bool _loading = false;
  String? _error;
  bool get isLoading => _loading;
  String? get error => _error;

  CategoriesProvider(this._api);

  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      final fetched = await _api.fetchAll();
      _categories
        ..clear()
        ..addAll(fetched);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Category>> getCategories() async {
    if (_categories.isEmpty) {
      await loadCategories();
    }
    return _categories;
  }

  Future<void> createCategory(Category cat) async {
    _setLoading(true);
    try {
      final created = await _api.create(cat);
      _categories.add(created);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCategory(int id) async {
    _setLoading(true);
    try {
      await _api.delete(id);
      _categories.removeWhere((c) => c.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Category getCategoryByName(String name) =>
      _categories.firstWhere((c) => c.name == name);

  Future<Map<String, double?>> getCategoryThresholds(String type) async {
    // ensure categories are loaded
    if (_categories.isEmpty) await loadCategories();
    return {
      for (final c in _categories.where((c) => c.type == type))
        c.name: c.alertThreshold
    };
  }

  Category getById(int id) => _categories.firstWhere((c) => c.id == id);

  Future<Map<String, Color>> generateCategoryColors() async {
    if (_categories.isEmpty) await loadCategories();
    final Map<String, Color> map = {};
    int i = 0;
    for (final c in _categories) {
      map[c.name] = colorArray[i % colorArray.length];
      i++;
    }
    return map;
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
