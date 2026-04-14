import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';

class ActionButtonsCard extends StatelessWidget {
  final VoidCallback onPomodoro;
  final VoidCallback onMonitoring;
  final VoidCallback onCombined;
  final String pomodoroLabel;
  final Color pomodoroColor;

  const ActionButtonsCard({
    super.key, 
    required this.onPomodoro, 
    required this.onMonitoring, 
    required this.onCombined,
    this.pomodoroLabel = "Inicio Pomodoro",
    this.pomodoroColor = AppColors.sidebarBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(label: pomodoroLabel, icon: Icons.timer, color: pomodoroColor, textColor: Colors.white, onTap: onPomodoro),
          _ActionButton(label: "Inicio monitoreo", icon: Icons.videocam_outlined, color: Colors.white, textColor: AppColors.textMain, isOutlined: true, onTap: onMonitoring),
          _ActionButton(label: "Pomodoro + Monitoreo", icon: Icons.check_circle, color: AppColors.primaryBlue, textColor: Colors.white, onTap: onCombined),
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

  const _ActionButton({required this.label, required this.icon, required this.color, required this.textColor, required this.onTap, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(15),
            border: isOutlined ? Border.all(color: Colors.grey[300]!) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}