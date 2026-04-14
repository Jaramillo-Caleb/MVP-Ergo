import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'terms_dialog.dart';

class TermsCheckbox extends StatelessWidget {
  final bool accepted;
  final bool showError;
  final ValueChanged<bool?> onChanged;

  const TermsCheckbox({
    super.key,
    required this.accepted,
    required this.showError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: accepted,
                activeColor: AppColors.sidebarBackground,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: "Acepto los ",
                  style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Roboto'), 
                  children: [
                    TextSpan(
                      text: "términos y condiciones",
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showDialog(
                            context: context,
                            builder: (_) => const TermsDialog(),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 34.0), 
            child: Text(
              "Debes aceptar los términos",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}