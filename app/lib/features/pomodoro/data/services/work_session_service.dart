import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' hide Column;
import '../models/work_session_model.dart';
import '../../../dashboard/data/services/notification_service.dart';
import '../../../../core/database/app_database.dart';
import 'package:uuid/uuid.dart';

class WorkSessionService extends ChangeNotifier {
  final AppDatabase _db;
  final NotificationService _notificationService;
  final _uuid = const Uuid();

  PomodoroSettings? _settingsCache;

  int totalWorkSeconds = 0;
  int totalBreakSeconds = 0;

  Timer? _timer;
  PomodoroState _state = PomodoroState.idle;
  int _secondsRemaining = 0;
  int _currentRepetition = 1;
  String? _currentSessionId;

  PomodoroState get state => _state;
  int get secondsRemaining => _secondsRemaining;
  int get currentRepetition => _currentRepetition;
  String? get currentSessionId => _currentSessionId;
  PomodoroSettings? get settings => _settingsCache;

  WorkSessionService({
    required AppDatabase db,
    required NotificationService notificationService,
  })  : _db = db,
        _notificationService = notificationService;

  Future<void> prefetchSettings() async {
    if (_settingsCache != null) return;
    _settingsCache = await getSettings();
    if (_settingsCache != null && _state == PomodoroState.idle) {
      _secondsRemaining = _settingsCache!.workDuration * 60;
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        if (_state == PomodoroState.working) {
          totalWorkSeconds++;
        }
        if (_state == PomodoroState.breaking) {
          totalBreakSeconds++;
        }
        notifyListeners();
      } else {
        _onCycleComplete();
      }
    });
  }

  void _onCycleComplete() {
    _timer?.cancel();
    if (_state == PomodoroState.working) {
      final isLastRepetition =
          _currentRepetition >= (_settingsCache?.repetitions ?? 1);

      _notificationService.showNotification(
        title: "¡Trabajo terminado!",
        body: ((_settingsCache?.autoStart ?? false) && isLastRepetition)
            ? "Has completado todos los ciclos de trabajo."
            : "Es hora de un descanso de ${_settingsCache?.breakDuration ?? 5} min.",
      );

      if (_settingsCache?.autoStart ?? false) {
        if (!isLastRepetition) {
          startBreak();
        } else {
          stopSession();
        }
      } else {
        _state = PomodoroState.workFinished;
        notifyListeners();
      }
    } else if (_state == PomodoroState.breaking) {
      _notificationService.showNotification(
        title: "¡Descanso terminado!",
        body: "A trabajar.",
      );

      if ((_settingsCache?.autoStart ?? false) &&
          _currentRepetition < (_settingsCache?.repetitions ?? 1)) {
        _currentRepetition++;
        startWork();
      } else {
        stopSession();
      }
    }
  }

  Future<void> startWork() async {
    if (_settingsCache == null) await getSettings();
    if (_settingsCache == null) return;

    _currentSessionId = _uuid.v4();

    final entry = WorkSessionsCompanion(
      id: Value(_currentSessionId!),
      startTime: Value(DateTime.now()),
      mode: const Value(1), // Assuming 1 is Pomodoro index
      scoreAverage: const Value(0.0),
    );

    await _db.into(_db.workSessions).insert(entry);

    _state = PomodoroState.working;
    _secondsRemaining = _settingsCache!.workDuration * 60;
    _startTimer();
    notifyListeners();
  }

  void startBreak() {
    if (_settingsCache == null) return;
    _state = _state == PomodoroState.workPaused || _state == PomodoroState.working || _state == PomodoroState.workFinished
        ? PomodoroState.breaking
        : _state;
    _secondsRemaining = _settingsCache!.breakDuration * 60;
    _startTimer();
    notifyListeners();
  }

  Future<void> pauseSession() async {
    if (_currentSessionId == null) return;
    _timer?.cancel();
    _state = _state == PomodoroState.working
        ? PomodoroState.workPaused
        : PomodoroState.breakPaused;
    notifyListeners();
  }

  Future<void> resumeSession() async {
    if (_currentSessionId == null) return;
    _state = _state == PomodoroState.workPaused
        ? PomodoroState.working
        : PomodoroState.breaking;
    _startTimer();
    notifyListeners();
  }

  Future<void> stopSession() async {
    _timer?.cancel();
    _state = PomodoroState.idle;
    _currentSessionId = null;
    _currentRepetition = 1;
    if (_settingsCache != null) {
      _secondsRemaining = _settingsCache!.workDuration * 60;
    }
    notifyListeners();
  }

  void resetDefaults() {
    _settingsCache = PomodoroSettings(
      userId: 'me',
      workDuration: 25,
      breakDuration: 5,
      autoStart: false,
      repetitions: 1,
    );
    if (_state == PomodoroState.idle) {
      _secondsRemaining = 25 * 60;
    }
    totalWorkSeconds = 0;
    totalBreakSeconds = 0;
    updateSettings(_settingsCache!);
    notifyListeners();
  }

  Future<PomodoroSettings?> getSettings() async {
    if (_settingsCache != null) return _settingsCache;

    try {
      final row = await (_db.select(_db.settings)..where((t) => t.userId.equals('me'))).getSingleOrNull();

      if (row != null) {
        _settingsCache = PomodoroSettings(
          userId: row.userId,
          workDuration: row.workDuration,
          breakDuration: row.breakDuration,
          autoStart: row.autoStart,
          repetitions: row.repetitions,
        );
      } else {
        _settingsCache = const PomodoroSettings(
          userId: 'me',
          workDuration: 25,
          breakDuration: 5,
          autoStart: false,
          repetitions: 1,
        );
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
      _settingsCache = const PomodoroSettings(
        userId: 'me',
        workDuration: 25,
        breakDuration: 5,
        autoStart: false,
        repetitions: 1,
      );
    }
    return _settingsCache;
  }

  Future<void> updateSettings(PomodoroSettings settings) async {
    _settingsCache = settings;
    try {
      final entry = SettingsCompanion(
        userId: Value(settings.userId),
        workDuration: Value(settings.workDuration),
        breakDuration: Value(settings.breakDuration),
        autoStart: Value(settings.autoStart),
        repetitions: Value(settings.repetitions),
      );
      await _db.into(_db.settings).insertOnConflictUpdate(entry);
    } catch (e) {
      debugPrint("Error saving settings: $e");
    }

    if (_state == PomodoroState.idle) {
      _secondsRemaining = settings.workDuration * 60;
    }
    notifyListeners();
  }

  void clearCache() {
    _settingsCache = null;
    _timer?.cancel();
    _state = PomodoroState.idle;
    _currentSessionId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
