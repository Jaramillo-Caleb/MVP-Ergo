import 'package:equatable/equatable.dart';

enum SessionMode { pomodoroOnly, monitoring, hybrid }

class WorkSession extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionMode mode;
  final double? scoreAverage;

  const WorkSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.mode,
    this.scoreAverage,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'mode': mode.index,
        'score_average': scoreAverage,
      };

  factory WorkSession.fromMap(Map<String, dynamic> map) => WorkSession(
        id: map['id'],
        startTime: DateTime.parse(map['start_time']),
        endTime:
            map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
        mode: SessionMode.values[map['mode']],
        scoreAverage: map['score_average'],
      );

  @override
  List<Object?> get props => [id, startTime, mode, scoreAverage];
}
