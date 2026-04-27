import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:local_notifier/local_notifier.dart';
import 'dart:typed_data';

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
  final String userName;
  final Function(int)? onNavigateToIndex;
  const DashboardPage(
      {super.key, required this.userName, this.onNavigateToIndex});

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
    } catch (e) {
      debugPrint("Error cargando datos iniciales: $e");
    }
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  /// Limpia recursos de forma segura para evitar fugas de memoria o errores de hilos.
  Future<void> _cleanupResources() async {
    _currentMode = AppMode.idle; // Detiene los bucles async

    final controller = _cameraController;
    _cameraController = null;

    if (controller != null) {
      // Esperar a que cualquier proceso de frame termine antes de dispose
      int retries = 0;
      while (_isProcessingFrame && retries < 5) {
        await Future.delayed(const Duration(milliseconds: 200));
        retries++;
      }
      await controller.dispose();
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
      if (cameras.isEmpty) {
        debugPrint("Cámara no detectada.");
        return false;
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
      setState(() {});
      return true;
    } catch (e) {
      debugPrint("Fallo al inicializar cámara: $e");
      return false;
    } finally {
      if (mounted) setState(() => _isOpeningCamera = false);
    }
  }

  Future<void> _closeCameraIfUnused() async {
    if (!mounted) return;

    // Solo cerrar si el sistema está IDLE y no hay operaciones de hardware pendientes
    if (_currentMode == AppMode.idle &&
        !_isProcessingFrame &&
        !_isOpeningCamera) {
      final controller = _cameraController;
      _cameraController = null;
      if (controller != null) {
        await controller.dispose();
        if (mounted) setState(() {});
        debugPrint("Hardware de cámara liberado.");
      }
    }
  }

  // --- LÓGICA DE MONITOREO (Async Loop) ---

  void _handleStartMonitoring() async {
    if (_isDialogOpen) return;

    if (_currentMode == AppMode.monitoring) {
      _stopMonitoring();
      return;
    }

    setState(() => _isDialogOpen = true);

    try {
      final selectedPosture = await showDialog<PostureReferenceModel>(
        context: context,
        barrierDismissible: false,
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
    debugPrint("Bucle de monitoreo activado.");
  }

  void _stopMonitoring() {
    if (mounted) {
      setState(() {
        _currentMode = AppMode.idle;
        _activePosture = null;
        _currentPostureStatus = PostureStatus.unknown;
      });
    }
    _closeCameraIfUnused();
  }

  /// Bucle asíncrono seguro que reemplaza Timer.periodic para evitar condiciones de carrera.
  Future<void> _monitoringLoop() async {
    while (_currentMode == AppMode.monitoring && mounted) {
      await _performPostureAnalysis();

      if (_currentMode != AppMode.monitoring || !mounted) break;

      // Determinar tiempo de espera basado en el estado (Ráfaga vs Normal)
      final delaySeconds = _isBurstMode ? 2 : 10;
      await Future.delayed(Duration(seconds: delaySeconds));
    }
  }

  Future<void> _performPostureAnalysis() async {
    if (_currentMode != AppMode.monitoring ||
        _cameraController == null ||
        !mounted) return;
    if (!_cameraController!.value.isInitialized || _isProcessingFrame) return;

    _isProcessingFrame = true;

    try {
      final XFile image = await _cameraController!.takePicture();
      if (!mounted || _currentMode != AppMode.monitoring) return;

      final bytes = await image.readAsBytes();

      final isCorrect = await sl<PostureService>().monitorPosture(
        _activePosture!.vectorList,
        bytes,
      );

      if (isCorrect == null || !mounted || _currentMode != AppMode.monitoring)
        return;

      setState(() {
        _currentPostureStatus =
            isCorrect ? PostureStatus.correct : PostureStatus.incorrect;
      });

      if (!isCorrect) {
        _consecutiveIncorrectCount++;
        if (!_isBurstMode) {
          setState(() => _isBurstMode = true);
        }

        if (_consecutiveIncorrectCount == 2 ||
            (_consecutiveIncorrectCount > 2 &&
                _consecutiveIncorrectCount % 5 == 0)) {
          _sendPostureAlert();
        }
      } else {
        _consecutiveIncorrectCount = 0;
        if (_isBurstMode) {
          setState(() => _isBurstMode = false);
        }
      }
    } catch (e) {
      debugPrint("Error en ciclo de análisis: $e");
    } finally {
      _isProcessingFrame = false;
      if (_currentMode == AppMode.idle) _closeCameraIfUnused();
    }
  }

  // --- LÓGICA DE CALIBRACIÓN (Async Loop) ---

  void _showCalibrationInstructions() {
    if (!mounted) return;
    // El pop debe ser seguro
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CalibrationInstructionsDialog(
        onContinue: _startCalibrationSequence,
      ),
    );
  }

  Future<void> _startCalibrationSequence() async {
    final ok = await _openCameraIfNeeded();
    if (!ok || !mounted) return;

    _capturedFrames.clear();
    setState(() {
      _currentMode = AppMode.calibrating;
      _countdown = 5;
    });

    _calibrationLoop();
  }

  /// Bucle secuencial para captura de calibración (1 frame por segundo).
  Future<void> _calibrationLoop() async {
    while (_currentMode == AppMode.calibrating && _countdown > 0 && mounted) {
      _isProcessingFrame = true;
      try {
        if (_cameraController != null &&
            _cameraController!.value.isInitialized) {
          final XFile image = await _cameraController!.takePicture();
          _capturedFrames.add(await image.readAsBytes());
        }
      } catch (e) {
        debugPrint("Error captura calibración: $e");
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
      _finishCalibration();
    }
  }

  Future<void> _finishCalibration() async {
    if (mounted) setState(() => _currentMode = AppMode.idle);

    if (!mounted) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final vector =
          await sl<PostureService>().computeCalibration(_capturedFrames);

      if (mounted) Navigator.of(context).pop(); // Quitar loading

      if (vector != null && mounted) {
        _showSavePostureDialog(vector);
      } else {
        _closeCameraIfUnused();
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
      _closeCameraIfUnused();
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
            _closeCameraIfUnused();
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
        _closeCameraIfUnused();
      }
    } catch (e) {
      _closeCameraIfUnused();
    }
  }

  void _sendPostureAlert() {
    try {
      LocalNotification(
        title: "ERGO: Alerta de Postura",
        body: "Se ha detectado una desviación. Por favor, endereza la espalda.",
      ).show();
    } catch (e) {
      debugPrint("Error notificación: $e");
    }
  }

  Future<void> _handleStartPomodoro() async {
    try {
      await sl<WorkSessionService>().startWork();
    } catch (e) {
      debugPrint("Error Pomodoro: $e");
    }
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

                    return ActionButtonsCard(
                      pomodoroLabel:
                          isIdle ? "Inicio Pomodoro" : "Ir a Pomodoro",
                      pomodoroColor: AppColors.sidebarBackground,
                      onPomodoro: () {
                        if (isIdle) {
                          _handleStartPomodoro();
                        } else {
                          widget.onNavigateToIndex?.call(2);
                        }
                      },
                      onMonitoring: _handleStartMonitoring,
                      onCombined: _showComingSoon,
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

  void _showComingSoon() {
    showDialog(
        context: context,
        builder: (context) => const AlertDialog(title: Text("Próximamente")));
  }
}
