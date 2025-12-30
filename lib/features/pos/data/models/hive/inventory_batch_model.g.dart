// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_batch_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryBatchModelAdapter extends TypeAdapter<InventoryBatchModel> {
  @override
  final int typeId = 4;

  @override
  InventoryBatchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryBatchModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      batchNumber: fields[2] as String,
      expiredDate: fields[3] as DateTime,
      quantityReal: fields[4] as int,
      priceBuy: fields[5] as double,
      organizationId: fields[6] as String,
      branchId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryBatchModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.batchNumber)
      ..writeByte(3)
      ..write(obj.expiredDate)
      ..writeByte(4)
      ..write(obj.quantityReal)
      ..writeByte(5)
      ..write(obj.priceBuy)
      ..writeByte(6)
      ..write(obj.organizationId)
      ..writeByte(7)
      ..write(obj.branchId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryBatchModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
