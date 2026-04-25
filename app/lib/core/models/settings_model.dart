import 'package:equatable/equatable.dart';

class PomodoroSettings extends Equatable {
  final String userId;
  final int workDuration;
  final int breakDuration;
  final bool autoStart;
  final int repetitions;

  const PomodoroSettings({
    required this.userId,
    this.workDuration = 25,
    this.breakDuration = 5,
    this.autoStart = false,
    this.repetitions = 1,
  });

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'work_duration': workDuration,
        'break_duration': breakDuration,
        'auto_start': autoStart ? 1 : 0,
        'repetitions': repetitions,
      };

  factory PomodoroSettings.fromMap(Map<String, dynamic> map) =>
      PomodoroSettings(
        userId: map['user_id'],
        workDuration: map['work_duration'],
        breakDuration: map['break_duration'],
        autoStart: map['auto_start'] == 1,
        repetitions: map['repetitions'],
      );

  @override
  List<Object?> get props => [userId, workDuration, breakDuration, autoStart];
}
