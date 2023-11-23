import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'categories.dart';
part "expenses.g.dart";

@HiveType(typeId: 0)
class Expenses extends HiveObject {
  Expenses(
      {required this.category,
      required this.amount,
      this.comment,
      required this.date});

  @HiveField(0)
  Categories category;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String? comment;

  @HiveField(3)
  DateTime date;
}
