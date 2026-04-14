import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/work_session_model.dart';
import '../../../dashboard/data/services/notification_service.dart';
import 'dart:convert';

class WorkSessionService extends ChangeNotifier {
  final Dio _dio;
  final NotificationService _notificationService;
  final String _basePath = '/api/work-session';

  // Cache para los settings y estadísticas locales
  PomodoroSettings? _settingsCache;
  Future<PomodoroSettings?>? _pendingFetch;

  // Estadísticas locales temporales (mientras no se cierre la app)
  int totalWorkSeconds = 0;
  int totalBreakSeconds = 0;

  // Estado del Pomodoro persistente
  Timer? _timer;
  PomodoroState _state = PomodoroState.idle;
  int _secondsRemaining = 0;
  int _currentRepetition = 1;
  String? _currentSessionId;

  // Getters para el estado
  PomodoroState get state => _state;
  int get secondsRemaining => _secondsRemaining;
  int get currentRepetition => _currentRepetition;
  String? get currentSessionId => _currentSessionId;
  PomodoroSettings? get settings => _settingsCache;

  WorkSessionService(this._dio, this._notificationService);

  /// Permite cargar los settings de forma anticipada (ej. al inicio de la app)
  Future<void> prefetchSettings(String userId) async {
    if (_settingsCache != null || _pendingFetch != null) return;
    _pendingFetch = getSettings(userId);
    _settingsCache = await _pendingFetch;
    _pendingFetch = null;
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
      final isLastRepetition = _currentRepetition >= (_settingsCache?.repetitions ?? 1);
      
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

      if ((_settingsCache?.autoStart ?? false) && _currentRepetition < (_settingsCache?.repetitions ?? 1)) {
        _currentRepetition++;
        startWork(_settingsCache!.userId);
      } else {
        stopSession();
      }
    }
  }

  Future<void> startWork(String userId) async {
    if (_settingsCache == null) await getSettings(userId);
    if (_settingsCache == null) return;

    final request = StartSessionRequest(
      userId: userId,
      mode: 0, // Pomodoro Only
      durationMinutes: _settingsCache!.workDuration,
    );

    try {
      final response = await _dio.post(
        '$_basePath/session/start',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        final session = WorkSessionDto.fromJson(response.data);
        _currentSessionId = session.sessionId;
        _state = PomodoroState.working;
        _secondsRemaining = _settingsCache!.workDuration * 60;
        _startTimer();
        notifyListeners();
      }
    } on DioException catch (e) {
      debugPrint("Error al iniciar sesión: ${e.response?.data ?? e.message}");
    }
  }

  void startBreak() {
    if (_settingsCache == null) return;
    _state = PomodoroState.breaking;
    _secondsRemaining = _settingsCache!.breakDuration * 60;
    _startTimer();
    notifyListeners();
  }

  Future<void> pauseSession() async {
    if (_currentSessionId == null) return;
    try {
      final response = await _dio.post('$_basePath/session/$_currentSessionId/pause');
      if (response.statusCode == 200) {
        _timer?.cancel();
        _state = _state == PomodoroState.working
            ? PomodoroState.workPaused
            : PomodoroState.breakPaused;
        notifyListeners();
      }
    } on DioException catch (e) {
      debugPrint("Error al pausar sesión: ${e.response?.data ?? e.message}");
    }
  }

  Future<void> resumeSession() async {
    if (_currentSessionId == null) return;
    try {
      final response = await _dio.post('$_basePath/session/$_currentSessionId/resume');
      if (response.statusCode == 200) {
        _state = _state == PomodoroState.workPaused
            ? PomodoroState.working
            : PomodoroState.breaking;
        _startTimer();
        notifyListeners();
      }
    } on DioException catch (e) {
      debugPrint("Error al reanudar sesión: ${e.response?.data ?? e.message}");
    }
  }

  Future<void> stopSession() async {
    if (_currentSessionId != null) {
      try {
        await _dio.post('$_basePath/session/$_currentSessionId/stop');
      } on DioException catch (e) {
        debugPrint("Error al detener sesión: ${e.response?.data ?? e.message}");
      }
    }
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
    if (_settingsCache == null) return;
    _settingsCache = _settingsCache!.copyWith(
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

  // Persistencia de configuración
  Future<PomodoroSettings?> getSettings(String userId) async {
    // Si ya tenemos cache, lo devolvemos inmediatamente
    if (_settingsCache != null) return _settingsCache;

    // Si hay una petición en curso, esperamos a esa misma
    if (_pendingFetch != null) return await _pendingFetch;

    try {
      _pendingFetch = _fetchFromNetwork(userId);
      _settingsCache = await _pendingFetch;
      _pendingFetch = null;
      if (_settingsCache != null && _state == PomodoroState.idle) {
        _secondsRemaining = _settingsCache!.workDuration * 60;
      }
      return _settingsCache;
    } catch (e) {
      _pendingFetch = null;
      debugPrint("Error al obtener settings: $e");
    }
    return null;
  }

  Future<PomodoroSettings?> _fetchFromNetwork(String userId) async {
    final response = await _dio.get('$_basePath/settings/$userId');
    if (response.statusCode == 200) {
      var data = response.data;
      if (data == null || (data is String && data.trim().isEmpty)) {
        return null;
      }
      if (data is String) {
        data = jsonDecode(data);
      }
      return PomodoroSettings.fromJson(data);
    }
    return null;
  }

  Future<void> updateSettings(PomodoroSettings settings) async {
    _settingsCache = settings; // Actualizamos cache local inmediatamente
    if (_state == PomodoroState.idle) {
      _secondsRemaining = settings.workDuration * 60;
    }
    notifyListeners();
    try {
      await _dio.post('$_basePath/settings', data: settings.toJson());
    } on DioException catch (e) {
      debugPrint("Error al actualizar settings: ${e.message}");
    }
  }

  void clearCache() {
    _settingsCache = null;
    _pendingFetch = null;
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
