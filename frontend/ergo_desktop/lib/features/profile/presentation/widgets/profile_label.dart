import 'package:flutter/material.dart';

class ProfileLabel extends StatelessWidget {
  final String text;

  const ProfileLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF334155),
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
