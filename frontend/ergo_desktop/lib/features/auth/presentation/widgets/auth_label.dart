import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthLabel extends StatelessWidget {
  final String text;
  const AuthLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMain, fontSize: 13)),
    );
  }
}