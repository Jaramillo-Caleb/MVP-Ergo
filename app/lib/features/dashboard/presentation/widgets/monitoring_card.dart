import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';
import '../../data/models/posture_models.dart';

class MonitoringCard extends StatelessWidget {
  final AppMode mode;
  final int countdown;
  final CameraController? cameraController;
  final PostureStatus postureStatus;

  const MonitoringCard({
    super.key,
    required this.mode,
    required this.countdown,
    this.cameraController,
    this.postureStatus = PostureStatus.unknown,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (mode == AppMode.calibrating &&
        cameraController != null &&
        cameraController!.value.isInitialized) {
      child = _buildLiveCameraView();
    } else if (mode == AppMode.monitoring) {
      child = _buildActiveMonitoringView();
    } else {
      child = _buildInactiveView();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: child,
      ),
    );
  }

  Widget _buildActiveMonitoringView() {
    final bool isCorrect = postureStatus == PostureStatus.correct;
    final IconData icon =
        isCorrect ? Icons.check_circle_outline : Icons.warning_amber_rounded;
    final Color color = isCorrect ? Colors.greenAccent : Colors.orangeAccent;
    final String title = isCorrect ? "Postura Correcta" : "Corrección Necesaria";
    final String subtitle =
        isCorrect ? "¡Sigue así!" : "Ajusta tu espalda y cuello.";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 50, color: color),
        const SizedBox(height: 15),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white)),
        const SizedBox(height: 10),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildInactiveView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.videocam_off_outlined,
              size: 40, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        const Text("Monitoreo inactivo",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white)),
        const SizedBox(height: 10),
        const Text(
          "Selecciona una postura guardada o\nañade una nueva para comenzar.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLiveCameraView() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CameraPreview(cameraController!),
        Container(
          color: Colors.black.withValues(alpha: 0.3),
        ),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ANALIZANDO POSTURA",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 5, color: Colors.black)],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Mantén la espalda recta y no te muevas.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                shadows: [Shadow(blurRadius: 5, color: Colors.black)],
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: AppColors.primaryBlue, shape: BoxShape.circle),
            child: Text(
              "$countdown s",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
