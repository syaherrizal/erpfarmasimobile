// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_movement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryMovementModelAdapter
    extends TypeAdapter<InventoryMovementModel> {
  @override
  final int typeId = 5;

  @override
  InventoryMovementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryMovementModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      batchId: fields[2] as String?,
      quantityChange: fields[3] as int,
      movementType: fields[4] as String,
      balanceAfter: fields[5] as int,
      referenceId: fields[6] as String?,
      organizationId: fields[7] as String,
      branchId: fields[8] as String,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryMovementModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.batchId)
      ..writeByte(3)
      ..write(obj.quantityChange)
      ..writeByte(4)
      ..write(obj.movementType)
      ..writeByte(5)
      ..write(obj.balanceAfter)
      ..writeByte(6)
      ..write(obj.referenceId)
      ..writeByte(7)
      ..write(obj.organizationId)
      ..writeByte(8)
      ..write(obj.branchId)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryMovementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
