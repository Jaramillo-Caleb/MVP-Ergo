import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:ergo_desktop/core/utils/date_picker_utils.dart';

class AppDatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String helpText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String? Function(String?)? validator;
  final VoidCallback? onDateSelected;

  const AppDatePickerField({
    super.key,
    required this.controller,
    this.hint = "DD/MM/YYYY",
    this.helpText = "SELECCIONAR FECHA",
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.validator,
    this.onDateSelected,
  });

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await DatePickerUtils.selectDate(
      context: context,
      initialDate: initialDate ?? DatePickerUtils.parseDate(controller.text) ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      helpText: helpText,
    );

    if (picked != null) {
      controller.text = DatePickerUtils.formatDate(picked);
      onDateSelected?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        DateInputFormatter(),
      ],
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
          onPressed: () => _selectDate(context),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      validator: validator ?? (v) {
        if (v == null || v.isEmpty) return "Requerido";
        if (DatePickerUtils.parseDate(v) == null) {
          return "Fecha inválida";
        }
        return null;
      },
    );
  }
}
