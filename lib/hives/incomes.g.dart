// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incomes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncomesAdapter extends TypeAdapter<Incomes> {
  @override
  final int typeId = 1;

  @override
  Incomes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Incomes(
      category: fields[0] as String,
      amount: fields[1] as double,
      comment: fields[2] as String?,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Incomes obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.comment)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
