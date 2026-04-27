import 'package:flutter/material.dart';
import 'package:ergo_desktop/features/profile/presentation/widgets/profile_label.dart';
import 'package:ergo_desktop/features/profile/presentation/widgets/profile_text_field.dart';

class SettingsFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool readOnly;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const SettingsFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.readOnly = false,
    this.keyboardType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileLabel(label),
        ProfileTextField(
          hint: hint,
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
        ),
      ],
    );
  }
}
