// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Income _$IncomeFromJson(Map<String, dynamic> json) => Income(
      id: (json['id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      comment: json['comment'] as String?,
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$IncomeToJson(Income instance) => <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'amount': instance.amount,
      'comment': instance.comment,
      'date': instance.date.toIso8601String(),
    };
