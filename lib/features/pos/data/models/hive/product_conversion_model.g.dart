// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_conversion_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductConversionModelAdapter
    extends TypeAdapter<ProductConversionModel> {
  @override
  final int typeId = 6;

  @override
  ProductConversionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductConversionModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      unitName: fields[2] as String,
      conversionFactor: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ProductConversionModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.unitName)
      ..writeByte(3)
      ..write(obj.conversionFactor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductConversionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
