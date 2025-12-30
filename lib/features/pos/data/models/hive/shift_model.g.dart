// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftModelAdapter extends TypeAdapter<ShiftModel> {
  @override
  final int typeId = 10;

  @override
  ShiftModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShiftModel(
      id: fields[0] as String,
      cashierId: fields[1] as String,
      branchId: fields[2] as String,
      openTime: fields[3] as DateTime,
      closeTime: fields[4] as DateTime?,
      startCash: fields[5] as double,
      expectedEndCash: fields[6] as double,
      actualEndCash: fields[7] as double?,
      status: fields[8] as String,
      note: fields[9] as String?,
      cashierName: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShiftModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cashierId)
      ..writeByte(2)
      ..write(obj.branchId)
      ..writeByte(3)
      ..write(obj.openTime)
      ..writeByte(4)
      ..write(obj.closeTime)
      ..writeByte(5)
      ..write(obj.startCash)
      ..writeByte(6)
      ..write(obj.expectedEndCash)
      ..writeByte(7)
      ..write(obj.actualEndCash)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.note)
      ..writeByte(10)
      ..write(obj.cashierName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
