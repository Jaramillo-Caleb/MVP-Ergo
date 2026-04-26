import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (oldValue.text.length >= 10 &&
        newValue.text.length > oldValue.text.length) {
      final base = oldValue.selection.baseOffset;
      final extent = newValue.selection.extentOffset;
      if (extent > base && base >= 0) {
        final inserted = newValue.text.substring(base, extent);
        final newDigits = inserted.replaceAll(RegExp(r'[^0-9]'), '');
        if (newDigits.isNotEmpty) {
          text = newDigits;
        }
      }
    }

    if (text.length > 8) text = text.substring(0, 8);

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 1 || i == 3) && i != text.length - 1) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();

    return TextEditingValue(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class DatePickerUtils {
  static Future<DateTime?> selectDate({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? helpText,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText?.toUpperCase(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E88E5), // primaryBlue
              onPrimary: Colors.white,
              onSurface: Color(0xFF333333),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1E88E5),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  static DateTime? parseDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }
      return date;
    } catch (_) {
      return null;
    }
  }

  static String? parseToIso(String input) {
    final date = parseDate(input);
    return date?.toIso8601String();
  }
}
