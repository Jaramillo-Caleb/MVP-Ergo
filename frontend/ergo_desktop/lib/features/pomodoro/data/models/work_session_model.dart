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
  final int workDuration;
  final int breakDuration;
  final bool autoStart;
  final int repetitions;

  PomodoroSettings({
    this.workDuration = 25,
    this.breakDuration = 5,
    this.autoStart = false,
    this.repetitions = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'workDuration': workDuration,
      'breakDuration': breakDuration,
      'autoStart': autoStart,
      'repetitions': repetitions,
    };
  }

  factory PomodoroSettings.fromJson(Map<String, dynamic> json) {
    return PomodoroSettings(
      workDuration: json['workDuration'] ?? 25,
      breakDuration: json['breakDuration'] ?? 5,
      autoStart: json['autoStart'] ?? false,
      repetitions: json['repetitions'] ?? 1,
    );
  }

  PomodoroSettings copyWith({
    int? workDuration,
    int? breakDuration,
    bool? autoStart,
    int? repetitions,
  }) {
    return PomodoroSettings(
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      autoStart: autoStart ?? this.autoStart,
      repetitions: repetitions ?? this.repetitions,
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
