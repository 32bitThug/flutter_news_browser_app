// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WebsiteAdapter extends TypeAdapter<Website> {
  @override
  final int typeId = 12;

  @override
  Website read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Website(
      domain: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Website obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.domain);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebsiteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
