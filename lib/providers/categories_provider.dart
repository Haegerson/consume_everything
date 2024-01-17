import 'package:expenso/const/constants.dart';
import 'package:expenso/hives/categories.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'dart:collection';

class CategoriesProvider extends ChangeNotifier {
  List<Categories> _categories = [];
  UnmodifiableListView<Categories> get categories =>
      UnmodifiableListView(_categories);
  final String categoriesHiveBox = 'categories-box';

  // Create test categories
  Future<void> createCategory(Categories cat) async {
    Box<Categories> box = await Hive.openBox<Categories>(categoriesHiveBox);

    if (!box.values.contains(cat)) {
      print("adding category...");
      await box.add(cat);
      _categories.add(cat);
      _categories = box.values.toList();
      notifyListeners();
    } else {}
  }

  // FOR DEBUG ONLY
  Future<void> deleteAllCategories() async {
    Box<Categories> box = await Hive.openBox<Categories>(categoriesHiveBox);

    print("deleting categories...");
    await box.clear();
    notifyListeners();
  }

  // Get test categories
  Future<List<Categories>> getCategories() async {
    Box<Categories> box = await Hive.openBox<Categories>(categoriesHiveBox);
    _categories = box.values.toList();
    return _categories;
  }

  // remove a test category
  Future<void> deleteCategory(Categories cat) async {
    Box<Categories> box = await Hive.openBox<Categories>(categoriesHiveBox);
    await box.delete(cat.key);
    _categories = box.values.toList();
    notifyListeners();
  }

  // Print the name and type of each category
  Future<void> printCategories() async {
    Box<Categories> box = await Hive.openBox<Categories>(categoriesHiveBox);

    for (Categories category in box.values) {
      print("Category Name: ${category.name}, Type: ${category.type}");
    }
  }

  // Get a category by name
  Categories getCategoryByName(String categoryName) {
    return _categories.firstWhere((category) => category.name == categoryName);
  }

  // Get a map of category names and their thresholds
  Future<Map<String, double?>> getCategoryThresholds(String type) async {
    Box<Categories> box = await Hive.openBox<Categories>(categoriesHiveBox);
    _categories = box.values.toList();
    Iterable<Categories> filteredCategories =
        _categories.where((element) => (element.type == type));

    Map<String, double?> categoryThresholds = {};

    for (Categories category in filteredCategories) {
      categoryThresholds[category.name] = category.alertThreshold;
    }

    return categoryThresholds;
  }

  Future<Map<String, Color>> generateCategoryColors() async {
    Box<Categories> box = await Hive.openBox<Categories>(categoriesHiveBox);
    _categories = box.values.toList();

    Map<String, Color> categoryColors = {};
    int i = 0;

    for (Categories category in _categories) {
      categoryColors[category.name] = colorArray[i % colorArray.length];
      i++;
    }
    return categoryColors;
  }
}
