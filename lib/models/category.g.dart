// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      type: json['type'] as String,
      alertThreshold: (json['alert_threshold'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'alert_threshold': instance.alertThreshold,
    };
