import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';

class TimeConfigField extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String>? onTimeChanged;

  const TimeConfigField({
    super.key,
    required this.label,
    required this.initialValue,
    this.onTimeChanged,
  });

  @override
  State<TimeConfigField> createState() => _TimeConfigFieldState();
}

class _TimeConfigFieldState extends State<TimeConfigField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();

    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _selectAll();
    } else {
      _formatAndNotify();
    }
  }

  void _selectAll() {
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  void _formatAndNotify() {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    final numberRegExp = RegExp(r'^\d+$');
    if (numberRegExp.hasMatch(text)) {
      text = "$text:00";
    } else {
      final timeRegExp = RegExp(r'^\d{1,2}:\d{2}$');
      if (!timeRegExp.hasMatch(text)) {}
    }

    setState(() {
      _controller.text = text;
    });

    if (widget.onTimeChanged != null) {
      widget.onTimeChanged!(text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 45,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            onSubmitted: (_) => _formatAndNotify(),
            onTap: () {
              if (_focusNode.hasFocus) {
                _selectAll();
              }
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: AppColors.cardBackground,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primaryBlue, width: 1.5),
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Segoe UI',
              fontSize: 16,
              color: AppColors.textMain,
            ),
          ),
        ),
      ],
    );
  }
}
