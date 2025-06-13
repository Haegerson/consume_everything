import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int? id;
  final String name;
  final String type;
  @JsonKey(name: 'alert_threshold')
  final double? alertThreshold;

  Category({
    this.id,
    required this.name,
    required this.type,
    this.alertThreshold,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
