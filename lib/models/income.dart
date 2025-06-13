import 'package:json_annotation/json_annotation.dart';

part 'income.g.dart';

@JsonSerializable()
class Income {
  final int? id;

  @JsonKey(name: 'category_id')
  final int categoryId;

  final double amount;
  final String? comment;
  final DateTime date;

  Income({
    this.id,
    required this.categoryId,
    required this.amount,
    this.comment,
    required this.date,
  });

  factory Income.fromJson(Map<String, dynamic> json) => _$IncomeFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeToJson(this);
}
