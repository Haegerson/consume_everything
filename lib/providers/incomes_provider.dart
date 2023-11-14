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

  // Get test Incomes
  Future<void> getIncomes() async {
    Box<Incomes> box = await Hive.openBox<Incomes>(incomesHiveBox);
    _incomes = box.values.toList();
    notifyListeners();
  }

  // remove a test expense
  Future<void> deleteIncome(Incomes inc) async {
    Box<Incomes> box = await Hive.openBox<Incomes>(incomesHiveBox);
    await box.delete(inc.key);
    _incomes = box.values.toList();
    notifyListeners();
  }
}
