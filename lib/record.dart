import 'package:json_annotation/json_annotation.dart';

part 'record.g.dart';

@JsonSerializable()
class Record {
  Record(this.timestamp, this.delivered1, this.delivered2, this.currentTariff);

  int timestamp;

  @JsonKey(name: "delivered_1")
  double delivered1;

  @JsonKey(name: "delivered_2")
  double delivered2;

  double get delivered => delivered1 + delivered2;

  @JsonKey(name: "current_tariff")
  int currentTariff;

  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);

  Map<String, dynamic> toJson() => _$RecordToJson(this);
}

class RecordInterval {
  final Record start;
  final Record end;

  final double average;

  RecordInterval(this.start, this.end)
      : average = (end.delivered - start.delivered) /
            (end.timestamp - start.timestamp) *
            3600 *
            1000;

  RecordInterval merge(RecordInterval other) {
    final start = (this.start.timestamp < other.start.timestamp)
        ? this.start
        : other.start;

    final end =
        (this.end.timestamp > other.end.timestamp) ? this.end : other.end;

    return RecordInterval(start, end);
  }

  @override
  String toString() {
    return "${start.timestamp}-${end.timestamp}: $average";
  }
}
