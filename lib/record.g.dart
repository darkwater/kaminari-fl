// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Record _$RecordFromJson(Map<String, dynamic> json) {
  return Record(
    json['timestamp'] as int,
    (json['delivered_1'] as num).toDouble(),
    (json['delivered_2'] as num).toDouble(),
    json['current_tariff'] as int,
  );
}

Map<String, dynamic> _$RecordToJson(Record instance) => <String, dynamic>{
      'timestamp': instance.timestamp,
      'delivered_1': instance.delivered1,
      'delivered_2': instance.delivered2,
      'current_tariff': instance.currentTariff,
    };
