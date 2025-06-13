import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  final int? id;

  @JsonKey(name: 'category_id')
  final int categoryId;

  final double amount;
  final String? comment;
  final DateTime date;

  Expense({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.comment,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
