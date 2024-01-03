import 'dart:ffi';

import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
part "categories.g.dart";

@HiveType(typeId: 2)
class Categories extends HiveObject {
  Categories({
    required this.name,
    required this.type,
    required this.alertThreshold,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  double? alertThreshold;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Categories && other.name == name && other.type == type;
  }
}
