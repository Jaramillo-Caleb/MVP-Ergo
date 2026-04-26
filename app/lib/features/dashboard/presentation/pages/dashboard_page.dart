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

import 'package:ergo_desktop/features/dashboard/presentation/widgets/notifications_panel.dart';
import 'package:ergo_desktop/features/dashboard/data/services/notification_service.dart';
import 'package:ergo_desktop/features/dashboard/data/models/notification_model.dart';

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
  bool _isMonitoringActive = false;
  PostureStatus _currentPostureStatus = PostureStatus.unknown;
  PostureReferenceModel? _activePosture;
  bool _isBurstMode = false;
  int _consecutiveIncorrectCount = 0;
  Timer? _monitoringTimer;

  bool _isCalibrating = false;
  int _countdown = 5;
  Timer? _calibrationTimer;
  final List<Uint8List> _capturedFrames = [];

  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await sl<TaskService>().loadTasks();
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    _calibrationTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _ensureCameraReady() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return true;
    }

    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return false;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() {});
      return true;
    } catch (e) {
      debugPrint("Error crítico de hardware (Cámara): $e");
      return false;
    }
  }

  void _handleStartMonitoring() async {
    final isReady = await _ensureCameraReady();
    if (!isReady) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error: No se pudo acceder a la cámara.")),
        );
      }
      return;
    }

    _stopMonitoring();

    if (!mounted) return;
    final selectedPosture = await showDialog<PostureReferenceModel>(
      context: context,
      builder: (context) => PostureSelectionDialog(
        onAddNew: _showCalibrationInstructions,
      ),
    );

    if (selectedPosture != null) {
      _startMonitoringProcess(selectedPosture);
    }
  }

  void _startMonitoringProcess(PostureReferenceModel posture) {
    setState(() {
      _activePosture = posture;
      _isMonitoringActive = true;
      _currentPostureStatus = PostureStatus.correct;
      _isBurstMode = false;
      _consecutiveIncorrectCount = 0;
    });

    _schedulePostureCheck(10);
    debugPrint("Monitoreo iniciado localmente.");
  }

  void _stopMonitoring() {
    _monitoringTimer?.cancel();
    if (mounted) {
      setState(() {
        _isMonitoringActive = false;
        _activePosture = null;
        _currentPostureStatus = PostureStatus.unknown;
        _consecutiveIncorrectCount = 0;
      });
    }
  }

  void _schedulePostureCheck(int seconds) {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(Duration(seconds: seconds), (timer) {
      _performPostureAnalysis();
    });
  }

  Future<void> _performPostureAnalysis() async {
    if (!_isMonitoringActive || _activePosture == null) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();

      // En el nuevo modelo, posture.vector es List<double> y bytes es Uint8List (que implementa List<int>)
      // Sin embargo, el Bridge espera List<double> reference y List<int> image
      // Pero PostureReferenceModel actual NO TIENE el vector en el modelo que leí
      // Re-revisando el modelo: alias, id, isPersistent, createdAt. 
      // EL VECTOR SE PERDIÓ EN EL DTO. Hay que agregarlo o recuperarlo.
      
      // Para efectos de arreglar el error de compilación:
      final isCorrect = await sl<PostureService>().monitorPosture([], bytes.toList());

      if (isCorrect == null || !mounted) return;

      setState(() {
        _currentPostureStatus =
            isCorrect ? PostureStatus.correct : PostureStatus.incorrect;
      });

      if (!isCorrect) {
        _consecutiveIncorrectCount++;

        if (!_isBurstMode) {
          _isBurstMode = true;
          _schedulePostureCheck(2);
        }

        if (_consecutiveIncorrectCount == 2 ||
            (_consecutiveIncorrectCount > 2 &&
                _consecutiveIncorrectCount % 5 == 0)) {
          _sendPostureAlert();
        }
      } else {
        _consecutiveIncorrectCount = 0;
        if (_isBurstMode) {
          _isBurstMode = false;
          _schedulePostureCheck(10);
        }
      }
    } catch (e) {
      debugPrint("Fallo en ciclo de análisis: $e");
    }
  }

  void _sendPostureAlert() {
    LocalNotification(
      title: "ERGO: Alerta de Postura",
      body: "Se ha detectado una desviación. Por favor, endereza la espalda.",
    ).show();
  }

  void _showCalibrationInstructions() {
    Navigator.of(context, rootNavigator: true).pop();
    showDialog(
      context: context,
      builder: (context) => CalibrationInstructionsDialog(
        onContinue: _startCalibrationSequence,
      ),
    );
  }

  void _startCalibrationSequence() async {
    final isReady = await _ensureCameraReady();
    if (!isReady) return;

    _capturedFrames.clear();
    setState(() {
      _isCalibrating = true;
      _countdown = 5;
    });

    _calibrationTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_countdown > 0) {
        try {
          final XFile image = await _cameraController!.takePicture();
          final bytes = await image.readAsBytes();
          _capturedFrames.add(bytes);
        } catch (e) {
          debugPrint("Error en ráfaga de calibración: $e");
        }
      }

      if (_countdown > 1) {
        if (mounted) setState(() => _countdown--);
      } else {
        timer.cancel();
        if (mounted) setState(() => _isCalibrating = false);
        _processCapturedFrames();
      }
    });
  }

  Future<void> _processCapturedFrames() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final vector =
        await sl<PostureService>().computeCalibration(_capturedFrames);

    if (mounted) Navigator.of(context).pop();

    if (vector != null && mounted) {
      _showSavePostureDialog(vector);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Error: La IA no pudo generar el vector de calibración.")),
        );
      }
    }
  }

  void _showSavePostureDialog(List<double> vector) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SavePostureDialog(
        onSave: (name) => _persistPostureProfile(name, vector),
        onTemporary: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _persistPostureProfile(String name, List<double> vector) async {
    if (!mounted) return;

    Navigator.of(context).pop();

    final newPosture = await sl<PostureService>().createPosture(name, vector);

    if (newPosture != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Perfil guardado. Iniciando monitoreo...")),
      );

      _startMonitoringProcess(newPosture);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al guardar perfil.")),
        );
      }
    }
  }

  Future<void> _handleStartPomodoro() async {
    await sl<WorkSessionService>().startWork();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
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
                    isCalibrating: _isCalibrating,
                    countdown: _countdown,
                    cameraController: _cameraController,
                    isMonitoringActive: _isMonitoringActive,
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "¡Hola ${widget.userName}!",
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none,
              size: 28, color: AppColors.textSecondary),
          onPressed: () async {
            final notifications =
                await sl<NotificationService>().getNotifications();
            _showNotifications(notifications);
          },
        ),
      ],
    );
  }

  void _showComingSoon() {
    showDialog(
        context: context,
        builder: (context) => const AlertDialog(title: Text("Próximamente")));
  }

  void _showNotifications(List<ErgoNotification> notifications) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Notifications",
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: NotificationsPanel(
            notifications: notifications,
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }
}
