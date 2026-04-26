import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TaskButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final IconData? icon;

  const TaskButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 180,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textMain,
          surfaceTintColor: Colors.white,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
