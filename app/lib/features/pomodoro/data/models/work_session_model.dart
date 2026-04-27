enum WorkSessionMode {
  pomodoroOnly,
  monitoring,
  hybrid,
}

enum PomodoroState {
  idle,
  working,
  workPaused,
  breaking,
  breakPaused,
  workFinished,
}

class PomodoroSettings {
  final String userId;
  final int workDuration;
  final int breakDuration;
  final bool autoStart;
  final int repetitions;
  final String taskSortStrategy;

  const PomodoroSettings({
    this.userId = 'me',
    this.workDuration = 25,
    this.breakDuration = 5,
    this.autoStart = false,
    this.repetitions = 1,
    this.taskSortStrategy = 'Prioridad',
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'work_duration': workDuration,
      'break_duration': breakDuration,
      'auto_start': autoStart ? 1 : 0,
      'repetitions': repetitions,
      'task_sort_strategy': taskSortStrategy,
    };
  }

  factory PomodoroSettings.fromMap(Map<String, dynamic> map) {
    return PomodoroSettings(
      userId: map['user_id'] ?? 'me',
      workDuration: map['work_duration'] ?? 25,
      breakDuration: map['break_duration'] ?? 5,
      autoStart: (map['auto_start'] ?? 0) == 1,
      repetitions: map['repetitions'] ?? 1,
      taskSortStrategy: map['task_sort_strategy'] ?? 'Prioridad',
    );
  }

  PomodoroSettings copyWith({
    String? userId,
    int? workDuration,
    int? breakDuration,
    bool? autoStart,
    int? repetitions,
    String? taskSortStrategy,
  }) {
    return PomodoroSettings(
      userId: userId ?? this.userId,
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      autoStart: autoStart ?? this.autoStart,
      repetitions: repetitions ?? this.repetitions,
      taskSortStrategy: taskSortStrategy ?? this.taskSortStrategy,
    );
  }
}

class StartSessionRequest {
  final int mode; 
  final int durationMinutes;
  final String? postureId;
  final List<double>? temporaryVector;

  StartSessionRequest({
    required this.mode,
    required this.durationMinutes,
    this.postureId,
    this.temporaryVector,
  });

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'durationMinutes': durationMinutes,
      'postureId': postureId,
      'temporaryVector': temporaryVector,
    };
  }
}

class WorkSessionDto {
  final String sessionId;
  final String status;
  final int mode;
  final DateTime startTime;

  WorkSessionDto({
    required this.sessionId,
    required this.status,
    required this.mode,
    required this.startTime,
  });

  factory WorkSessionDto.fromJson(Map<String, dynamic> json) {
    return WorkSessionDto(
      sessionId: json['sessionId'],
      status: json['status'],
      mode: json['mode'],
      startTime: DateTime.parse(json['startTime']),
    );
  }
}
