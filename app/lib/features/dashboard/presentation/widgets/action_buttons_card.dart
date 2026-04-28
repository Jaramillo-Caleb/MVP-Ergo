import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';

class ActionButtonsCard extends StatelessWidget {
  final VoidCallback onPomodoro;
  final VoidCallback onMonitoring;
  final VoidCallback? onPauseResume;
  final String pomodoroLabel;
  final Color pomodoroColor;
  final String monitoringLabel;
  final Color monitoringColor;
  final bool isMonitoringOrPaused;
  final bool isPaused;

  const ActionButtonsCard({
    super.key,
    required this.onPomodoro,
    required this.onMonitoring,
    this.onPauseResume,
    this.pomodoroLabel = "Inicio Pomodoro",
    this.pomodoroColor = AppColors.sidebarBackground,
    this.monitoringLabel = "Inicio monitoreo",
    this.monitoringColor = Colors.white,
    this.isMonitoringOrPaused = false,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          _ActionButton(
              label: pomodoroLabel,
              icon: Icons.timer_outlined,
              color: pomodoroColor,
              textColor: Colors.white,
              onTap: onPomodoro),
          const SizedBox(height: 12),
          if (isMonitoringOrPaused) ...[
            _ActionButton(
                label: isPaused ? "Reanudar" : "Pausar",
                icon:
                    isPaused ? Icons.play_arrow_outlined : Icons.pause_outlined,
                color: Colors.white,
                textColor: AppColors.textMain,
                isOutlined: true,
                onTap: onPauseResume ?? () {}),
            const SizedBox(height: 12),
          ],
          _ActionButton(
              label: monitoringLabel,
              icon: Icons.videocam_outlined,
              color: monitoringColor,
              textColor: monitoringColor == Colors.white
                  ? AppColors.textMain
                  : Colors.white,
              isOutlined: monitoringColor == Colors.white,
              onTap: onMonitoring),
          const Spacer(),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool isOutlined;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.textColor,
      required this.onTap,
      this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(10),
            border:
                isOutlined ? Border.all(color: const Color(0xFFE5E7EB)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 18),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
