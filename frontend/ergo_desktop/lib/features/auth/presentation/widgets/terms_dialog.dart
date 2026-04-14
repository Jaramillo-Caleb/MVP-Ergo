import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/constants/legal_constants.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';

class TermsDialog extends StatelessWidget {
  const TermsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        LegalConstants.termsAndConditionsTitle,
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
      ),
      content: const SingleChildScrollView(
        child: Text(
          LegalConstants.termsAndConditionsText,
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Entendido',
            style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}