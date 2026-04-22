import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:ergo_desktop/features/pomodoro/presentation/widgets/time_config_field.dart';
import 'package:ergo_desktop/core/di/injection_container.dart';
import 'package:ergo_desktop/features/pomodoro/data/services/work_session_service.dart';
import 'package:ergo_desktop/features/pomodoro/data/models/work_session_model.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  final _workSessionService = sl<WorkSessionService>();

  late final TextEditingController _repetitionsController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repetitionsController = TextEditingController();
    _workSessionService.addListener(_onServiceUpdate);
    _initSettings();
  }

  Future<void> _initSettings() async {
    await _workSessionService.getSettings();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _repetitionsController.text =
            _workSessionService.settings?.repetitions.toString() ?? "1";
      });
    }
  }

  void _onServiceUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _workSessionService.removeListener(_onServiceUpdate);
    _repetitionsController.dispose();
    super.dispose();
  }

  Future<void> _startWork() async {
    await _workSessionService.startWork();
  }

  void _startBreak() {
    _workSessionService.startBreak();
  }

  Future<void> _pauseSession() async {
    await _workSessionService.pauseSession();
  }

  Future<void> _resumeSession() async {
    await _workSessionService.resumeSession();
  }

  Future<void> _stopSession() async {
    await _workSessionService.stopSession();
  }

  void _resetDefaults() {
    _workSessionService.resetDefaults();
    _repetitionsController.text =
        _workSessionService.settings?.repetitions.toString() ?? "1";
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildTimerCircle(),
                      const SizedBox(height: 40),
                      _buildActionButtons(),
                    ],
                  ),
                ),
                const SizedBox(width: 60),
                Expanded(
                  flex: 2,
                  child: _buildConfigurationSection(),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Pomodoro",
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain),
        ),
        TextButton.icon(
          onPressed: _workSessionService.state == PomodoroState.idle
              ? _resetDefaults
              : null,
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text("Reiniciar valores"),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
            "Trabajo", _formatTime(_workSessionService.totalWorkSeconds)),
        _buildStatItem(
            "Descanso", _formatTime(_workSessionService.totalBreakSeconds)),
        _buildStatItem(
            "General",
            _formatTime(_workSessionService.totalWorkSeconds +
                _workSessionService.totalBreakSeconds)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value,
            style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTimerCircle() {
    Color borderColor = AppColors.border;
    final state = _workSessionService.state;
    if (state == PomodoroState.working || state == PomodoroState.workPaused) {
      borderColor = AppColors.primaryBlue;
    }
    if (state == PomodoroState.breaking || state == PomodoroState.breakPaused) {
      borderColor = Colors.green;
    }

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 6),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(_workSessionService.secondsRemaining),
            style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain),
          ),
          Text(
            (state == PomodoroState.breaking ||
                    state == PomodoroState.breakPaused)
                ? "DESCANSO"
                : "TRABAJO",
            style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          if (_workSessionService.settings?.autoStart ?? false)
            Text(
                "Ciclo ${_workSessionService.currentRepetition}/${_workSessionService.settings?.repetitions ?? 1}",
                style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final state = _workSessionService.state;

    if (state == PomodoroState.idle) {
      return _buildButton("Iniciar", _startWork);
    }

    if (state == PomodoroState.workFinished) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton("Iniciar descanso", _startBreak, width: 140),
          const SizedBox(width: 20),
          _buildButton("Detener", _stopSession, width: 140),
        ],
      );
    }

    final isPaused =
        state == PomodoroState.workPaused || state == PomodoroState.breakPaused;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(isPaused ? "Reanudar" : "Pausar",
            isPaused ? _resumeSession : _pauseSession,
            width: 140),
        const SizedBox(width: 20),
        _buildButton("Detener", _stopSession, width: 140),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed,
      {double width = 200}) {
    return SizedBox(
      width: width,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textMain,
          surfaceTintColor: Colors.white,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildConfigurationSection() {
    final state = _workSessionService.state;
    final bool canEdit = state == PomodoroState.idle;
    final settings = _workSessionService.settings;

    if (settings == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Configuración",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain)),
        const SizedBox(height: 25),
        Row(
          children: [
            Checkbox(
              value: settings.autoStart,
              activeColor: AppColors.primaryBlue,
              onChanged: canEdit
                  ? (val) {
                      _workSessionService
                          .updateSettings(settings.copyWith(autoStart: val!));
                    }
                  : null,
            ),
            const Text("Auto-iniciar ciclos",
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 20),
        if (settings.autoStart)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextField(
              decoration: const InputDecoration(
                  labelText: "Repeticiones (Ciclos)",
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              enabled: canEdit,
              controller: _repetitionsController,
              onChanged: (val) {
                final repetitions = int.tryParse(val) ?? 1;
                _workSessionService.updateSettings(
                    settings.copyWith(repetitions: repetitions));
              },
              onSubmitted: (val) {
                final repetitions = int.tryParse(val) ?? 1;
                _workSessionService.updateSettings(
                    settings.copyWith(repetitions: repetitions));
                _repetitionsController.text = repetitions.toString();
              },
            ),
          ),
        TimeConfigField(
          key: ValueKey("work_${settings.workDuration}"),
          label: "Sesión trabajo",
          initialValue: "${settings.workDuration}:00",
          onTimeChanged: canEdit
              ? (val) {
                  final mins = int.tryParse(val.split(':').first) ?? 25;
                  _workSessionService
                      .updateSettings(settings.copyWith(workDuration: mins));
                }
              : null,
        ),
        const SizedBox(height: 20),
        TimeConfigField(
          key: ValueKey("break_${settings.breakDuration}"),
          label: "Sesión descanso",
          initialValue: "${settings.breakDuration}:00",
          onTimeChanged: canEdit
              ? (val) {
                  final mins = int.tryParse(val.split(':').first) ?? 5;
                  _workSessionService
                      .updateSettings(settings.copyWith(breakDuration: mins));
                }
              : null,
        ),
      ],
    );
  }
}
