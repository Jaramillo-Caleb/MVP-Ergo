import 'dart:math' as math;
import 'package:flutter/material.dart';

class FloatingIconsBackground extends StatefulWidget {
  const FloatingIconsBackground({super.key});

  @override
  State<FloatingIconsBackground> createState() =>
      _FloatingIconsBackgroundState();
}

class _FloatingIconsBackgroundState extends State<FloatingIconsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingIconModel> _icons = [];
  final math.Random _random = math.Random();

  final List<IconData> _iconLibrary = [
    Icons.chair_alt,
    Icons.monitor,
    Icons.accessibility_new,
    Icons.timer,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (int i = 0; i < 12; i++) {
      // 50% left (0.0-0.2), 50% right (0.8-1.0)
      double leftSide = i < 6
          ? _random.nextDouble() * 0.2
          : 0.8 + (_random.nextDouble() * 0.2);

      _icons.add(_FloatingIconModel(
        icon: _iconLibrary[_random.nextInt(_iconLibrary.length)],
        top: _random.nextDouble(),
        left: leftSide,
        size: 24 + _random.nextDouble() * 32,
        speed: 0.2 + _random.nextDouble() * 0.3,
        offset: _random.nextDouble(),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: _icons.map((model) {
              // Linear upward movement with wrap-around
              double progress = (_controller.value + model.offset) % 1.0;
              double yPos = size.height - (progress * (size.height + 100));

              return Positioned(
                top: yPos,
                left: size.width * model.left,
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(
                    model.icon,
                    size: model.size,
                    color: Colors.grey[800],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _FloatingIconModel {
  final IconData icon;
  final double top;
  final double left;
  final double size;
  final double speed;
  final double offset;

  _FloatingIconModel({
    required this.icon,
    required this.top,
    required this.left,
    required this.size,
    required this.speed,
    required this.offset,
  });
}
