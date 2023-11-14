import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
part 'incomes.g.dart';

@HiveType(typeId: 1)
class Incomes extends HiveObject {
  Incomes(
      {required this.category,
      required this.amount,
      this.comment,
      required this.date});

  @HiveField(0)
  String category;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String? comment;

  @HiveField(3)
  DateTime date;
}
