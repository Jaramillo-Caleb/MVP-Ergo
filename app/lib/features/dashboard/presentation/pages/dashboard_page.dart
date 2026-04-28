import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:local_notifier/local_notifier.dart';

import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:ergo_desktop/features/dashboard/data/models/posture_models.dart';
import 'package:ergo_desktop/features/dashboard/data/services/posture_service.dart';

import 'package:ergo_desktop/features/dashboard/presentation/widgets/action_buttons_card.dart';
import 'package:ergo_desktop/features/dashboard/presentation/widgets/dashboard_placeholders.dart';
import 'package:ergo_desktop/features/dashboard/presentation/widgets/monitoring_card.dart';
import 'package:ergo_desktop/features/dashboard/presentation/widgets/posture_dialogs.dart';

import 'package:ergo_desktop/features/pomodoro/data/services/work_session_service.dart';
import 'package:ergo_desktop/features/pomodoro/data/models/work_session_model.dart';

import 'package:ergo_desktop/features/dashboard/presentation/widgets/task_summary_card.dart';
import 'package:ergo_desktop/features/tasks/data/services/task_service.dart';

final sl = GetIt.instance;

class DashboardPage extends StatefulWidget {
  final Function(int)? onNavigateToIndex;
  const DashboardPage({super.key, this.onNavigateToIndex});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // --- ESTADOS DE CONTROL ---
  AppMode _currentMode = AppMode.idle;
  bool _isOpeningCamera = false;
  bool _isProcessingFrame = false;
  bool _isDialogOpen = false;

  PostureStatus _currentPostureStatus = PostureStatus.unknown;
  PostureReferenceModel? _activePosture;
  bool _isBurstMode = false;
  int _consecutiveIncorrectCount = 0;

  int _countdown = 5;
  final List<Uint8List> _capturedFrames = [];
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await sl<TaskService>().loadTasks();
    } catch (_) {}
  }

  @override
  void dispose() {
    _currentMode = AppMode.idle;
    _safeDisposeCamera();
    super.dispose();
  }

  /// Libera la cámara de forma inmediata y segura.
  Future<void> _safeDisposeCamera() async {
    if (_cameraController == null) return;

    final controller = _cameraController;
    _cameraController = null;

    try {
      if (controller != null && controller.value.isInitialized) {
        await controller.dispose();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() {});
    }
  }

  // --- GESTIÓN CENTRALIZADA DE CÁMARA ---

  Future<bool> _openCameraIfNeeded() async {
    if (_isOpeningCamera) return false;
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return true;
    }

    if (!mounted) return false;
    setState(() => _isOpeningCamera = true);

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return false;

      if (_cameraController != null) {
        try {
          await _cameraController!.dispose();
        } catch (_) {}
        _cameraController = null;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return false;
      }

      _cameraController = controller;
      if (mounted) setState(() {});
      return true;
    } catch (e) {
      _cameraController = null;
      return false;
    } finally {
      if (mounted) setState(() => _isOpeningCamera = false);
    }
  }

  // --- LÓGICA DE MONITOREO (Async Loop) ---

  void _handleStartMonitoring() async {
    if (_isDialogOpen) return;

    if (_currentMode == AppMode.monitoring ||
        _currentMode == AppMode.pausedMonitoring) {
      _stopMonitoring();
      return;
    }

    setState(() => _isDialogOpen = true);

    try {
      final selectedPosture = await showDialog<PostureReferenceModel>(
        context: context,
        barrierColor: Colors.black87,
        builder: (context) => PostureSelectionDialog(
          onAddNew: _showCalibrationInstructions,
        ),
      );

      if (mounted) setState(() => _isDialogOpen = false);

      if (selectedPosture != null && mounted) {
        _startMonitoringProcess(selectedPosture);
      }
    } finally {
      if (mounted) setState(() => _isDialogOpen = false);
    }
  }

  Future<void> _startMonitoringProcess(PostureReferenceModel posture) async {
    if (!mounted) return;

    // Solo abrir cámara si no está abierta
    final ok = await _openCameraIfNeeded();
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error: No se pudo acceder a la cámara.")),
        );
      }
      return;
    }

    setState(() {
      _activePosture = posture;
      _currentMode = AppMode.monitoring;
      _currentPostureStatus = PostureStatus.correct;
      _isBurstMode = false;
      _consecutiveIncorrectCount = 0;
    });

    _monitoringLoop();
  }

  void _stopMonitoring() {
    if (mounted) {
      setState(() {
        _currentMode = AppMode.idle;
        _activePosture = null;
        _currentPostureStatus = PostureStatus.unknown;
      });
    }
    _safeDisposeCamera();
  }

  void _pauseMonitoring() {
    if (_currentMode != AppMode.monitoring) return;
    setState(() {
      _currentMode = AppMode.pausedMonitoring;
    });
    _safeDisposeCamera();
  }

  void _resumeMonitoring() async {
    if (_currentMode != AppMode.pausedMonitoring) return;

    final ok = await _openCameraIfNeeded();
    if (!ok) return;

    setState(() {
      _currentMode = AppMode.monitoring;
      // Reset a un estado seguro
      _currentPostureStatus = PostureStatus.correct;
      _isBurstMode = false;
      _consecutiveIncorrectCount = 0;
    });

    _monitoringLoop();
  }

  /// Bucle asíncrono seguro.
  Future<void> _monitoringLoop() async {
    while (_currentMode == AppMode.monitoring && mounted) {
      await _performPostureAnalysis();

      if (_currentMode != AppMode.monitoring || !mounted) break;

      int delaySeconds;
      if (_currentPostureStatus == PostureStatus.incorrect) {
        delaySeconds = 2; // Ráfaga
      } else {
        delaySeconds = 10; // Normal
      }

      await Future.delayed(Duration(seconds: delaySeconds));
    }
  }

  Future<void> _performPostureAnalysis() async {
    if (_currentMode != AppMode.monitoring || !mounted) return;

    final ok = await _openCameraIfNeeded();
    if (!ok || _isProcessingFrame) return;

    _isProcessingFrame = true;
    final shouldKeepCameraOpen = _isBurstMode;

    try {
      XFile? image;
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        image = await _cameraController!.takePicture().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('takePicture timeout — cámara bloqueada');
          },
        );
      }

      if (!shouldKeepCameraOpen) await _safeDisposeCamera();

      if (image == null || !mounted || _currentMode != AppMode.monitoring) {
        return;
      }

      final bytes = await _processAndCleanupImage(image);
      if (bytes == null) return;

      final isCorrect = await sl<PostureService>().monitorPosture(
        _activePosture!.vectorList,
        bytes,
      );

      if (!mounted || _currentMode != AppMode.monitoring) return;

      if (isCorrect == null) {
        setState(() => _currentPostureStatus = PostureStatus.unknown);
        return;
      }

      _updatePostureState(isCorrect);

      if (!_isBurstMode) await _safeDisposeCamera();
    } catch (e) {
      if (!_isBurstMode) await _safeDisposeCamera();
    } finally {
      _isProcessingFrame = false;
      if (_currentMode == AppMode.idle) await _safeDisposeCamera();
    }
  }

  /// Lee bytes y garantiza la eliminación del archivo físico bajo cualquier circunstancia.
  Future<Uint8List?> _processAndCleanupImage(XFile image) async {
    final file = File(image.path);
    Uint8List? bytes;
    try {
      bytes = await image.readAsBytes();
    } catch (_) {
    } finally {
      // Pequeña espera para asegurar que la cámara liberó el archivo en Windows
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Reintentar una vez tras error de bloqueo
        Future.delayed(const Duration(seconds: 1), () async {
          try {
            if (await file.exists()) await file.delete();
          } catch (_) {}
        });
      }
    }
    return bytes;
  }

  void _updatePostureState(bool isCorrect) {
    if (!mounted) return;
    setState(() {
      _currentPostureStatus =
          isCorrect ? PostureStatus.correct : PostureStatus.incorrect;
    });

    if (!isCorrect) {
      _consecutiveIncorrectCount++;
      if (_consecutiveIncorrectCount > 1000) _consecutiveIncorrectCount = 6;

      if (!_isBurstMode) setState(() => _isBurstMode = true);

      if (_consecutiveIncorrectCount == 2 ||
          (_consecutiveIncorrectCount > 2 &&
              _consecutiveIncorrectCount % 5 == 0)) {
        _sendPostureAlert();
      }
    } else {
      _consecutiveIncorrectCount = 0;
      if (_isBurstMode) setState(() => _isBurstMode = false);
    }
  }

  // --- LÓGICA DE CALIBRACIÓN (Async Loop) ---

  void _showCalibrationInstructions(
      {PostureReferenceModel? existingPosture}) async {
    if (!mounted) return;

    // Cerrar el diálogo de selección previo
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    final showInstructions =
        await sl<PostureService>().getShowCalibrationInstructions();

    if (!showInstructions) {
      _startCalibrationSequence(existingPosture: existingPosture);
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black87,
        builder: (context) => CalibrationInstructionsDialog(
          onContinue: () =>
              _startCalibrationSequence(existingPosture: existingPosture),
        ),
      );
    }
  }

  Future<void> _startCalibrationSequence(
      {PostureReferenceModel? existingPosture}) async {
    final ok = await _openCameraIfNeeded();
    if (!ok || !mounted) return;

    _capturedFrames.clear();
    setState(() {
      _currentMode = AppMode.calibrating;
      _countdown = 5;
    });

    _calibrationLoop(existingPosture: existingPosture);
  }

  /// Bucle secuencial para captura de calibración (1 frame por segundo).
  Future<void> _calibrationLoop(
      {PostureReferenceModel? existingPosture}) async {
    while (_currentMode == AppMode.calibrating && _countdown > 0 && mounted) {
      _isProcessingFrame = true;
      try {
        if (_cameraController != null &&
            _cameraController!.value.isInitialized) {
          final XFile image = await _cameraController!.takePicture();
          final bytes = await _processAndCleanupImage(image);
          if (bytes != null) _capturedFrames.add(bytes);
        }
      } catch (_) {
      } finally {
        _isProcessingFrame = false;
      }

      await Future.delayed(const Duration(seconds: 1));

      if (mounted && _currentMode == AppMode.calibrating) {
        setState(() {
          if (_countdown > 1) {
            _countdown--;
          } else {
            _countdown = 0;
          }
        });
      }
    }

    if (_currentMode == AppMode.calibrating && mounted) {
      _finishCalibration(existingPosture: existingPosture);
    }
  }

  Future<void> _finishCalibration(
      {PostureReferenceModel? existingPosture}) async {
    if (mounted) setState(() => _currentMode = AppMode.idle);

    if (!mounted) return;

    // Mostrar loading
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final vector =
          await sl<PostureService>().computeCalibration(_capturedFrames);

      if (mounted) Navigator.of(context).pop(); // Quitar loading

      if (vector != null && mounted) {
        if (existingPosture != null) {
          _updateExistingPosture(existingPosture, vector);
        } else {
          _showSavePostureDialog(vector);
        }
      } else {
        _safeDisposeCamera();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("Error: La IA no pudo generar el perfil de postura.")),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _safeDisposeCamera();
    }
  }

  Future<void> _updateExistingPosture(
      PostureReferenceModel posture, List<double> vector) async {
    if (!mounted) return;

    try {
      // Necesitamos un método en PostureService para actualizar el vector
      final success =
          await sl<PostureService>().updatePostureVector(posture.id, vector);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Postura recalibrada con éxito.")),
        );
        // Reiniciar monitoreo con la nueva data si era la activa
        if (_activePosture?.id == posture.id) {
          final updatedPostures = await sl<PostureService>().getPostures();
          final updated = updatedPostures.firstWhere((p) => p.id == posture.id);
          _startMonitoringProcess(updated);
        }
      }
    } catch (_) {
    } finally {
      _safeDisposeCamera();
    }
  }

  void _showSavePostureDialog(List<double> vector) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SavePostureDialog(
        onSave: (name) => _persistPostureProfile(name, vector),
        onTemporary: () {
          if (mounted) {
            Navigator.of(context).pop();
            // Crear un modelo temporal (no persistente en DB)
            final tempPosture = PostureReferenceModel(
              id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
              alias: 'Temporal',
              isPersistent: false,
              createdAt: DateTime.now(),
              vector: vector.join(','),
            );
            _startMonitoringProcess(tempPosture);
          }
        },
      ),
    );
  }

  Future<void> _persistPostureProfile(String name, List<double> vector) async {
    if (!mounted) return;
    Navigator.of(context).pop();

    try {
      final newPosture = await sl<PostureService>().createPosture(name, vector);
      if (newPosture != null && mounted) {
        _startMonitoringProcess(newPosture);
      } else {
        _safeDisposeCamera();
      }
    } catch (e) {
      _safeDisposeCamera();
    }
  }

  void _sendPostureAlert() {
    try {
      LocalNotification(
        title: "ERGO: Alerta de Postura",
        body: "Se ha detectado una desviación. Por favor, endereza la espalda.",
      ).show();
    } catch (_) {}
  }

  Future<void> _handleStartPomodoro() async {
    try {
      await sl<WorkSessionService>().startWork();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SimpleCard(
                  width: 250,
                  child: PomodoroTimerDashboard(),
                ),
                const SizedBox(width: 20),
                ListenableBuilder(
                  listenable: sl<WorkSessionService>(),
                  builder: (context, _) {
                    final pomodoroState = sl<WorkSessionService>().state;
                    final isIdle = pomodoroState == PomodoroState.idle;

                    final isMonitoring = _currentMode == AppMode.monitoring;
                    final isPaused = _currentMode == AppMode.pausedMonitoring;
                    final isMonitoringOrPaused = isMonitoring || isPaused;

                    return ActionButtonsCard(
                      pomodoroLabel:
                          isIdle ? "Inicio Pomodoro" : "Ir a Pomodoro",
                      pomodoroColor: AppColors.sidebarBackground,
                      monitoringLabel: isMonitoringOrPaused
                          ? "Parar monitoreo"
                          : "Inicio monitoreo",
                      monitoringColor: isMonitoringOrPaused
                          ? Colors.red[400]!
                          : Colors.white,
                      isMonitoringOrPaused: isMonitoringOrPaused,
                      isPaused: isPaused,
                      onPauseResume:
                          isPaused ? _resumeMonitoring : _pauseMonitoring,
                      onPomodoro: () {
                        if (isIdle) {
                          _handleStartPomodoro();
                        } else {
                          widget.onNavigateToIndex?.call(2);
                        }
                      },
                      onMonitoring: _handleStartMonitoring,
                    );
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: MonitoringCard(
                    mode: _currentMode,
                    countdown: _countdown,
                    cameraController: _cameraController,
                    postureStatus: _currentPostureStatus,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          TaskSummaryCard(
            onTap: () => widget.onNavigateToIndex?.call(1),
          ),
          const SizedBox(height: 30),
          const SizedBox(
              height: 300,
              child: SimpleCard(
                  child:
                      PlaceholderWidget("Gráficas de Progreso\nPróximamente"))),
        ],
      ),
    );
  }
}
