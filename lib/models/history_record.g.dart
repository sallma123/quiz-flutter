// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryRecordAdapter extends TypeAdapter<HistoryRecord> {
  @override
  final int typeId = 2;

  @override
  HistoryRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryRecord(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      title: fields[2] as String,
      dateTime: fields[3] as DateTime,
      score: fields[4] as int,
      totalQuestions: fields[5] as int,
      questions: (fields[6] as List).cast<Question>(),
      selections: (fields[7] as List).cast<int?>(),
    );
  }

  @override
  void write(BinaryWriter writer, HistoryRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.score)
      ..writeByte(5)
      ..write(obj.totalQuestions)
      ..writeByte(6)
      ..write(obj.questions)
      ..writeByte(7)
      ..write(obj.selections);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
