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
      if (postureStatus == PostureStatus.userNotFound) {
        child = _buildUserNotFoundView();
      } else {
        child = _buildActiveMonitoringView();
      }
    } else {
      child = _buildInactiveView();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  Widget _buildActiveMonitoringView() {
    final bool isCorrect = postureStatus == PostureStatus.correct;
    final IconData icon =
        isCorrect ? Icons.check_circle_rounded : Icons.error_outline_rounded;
    final Color color =
        isCorrect ? const Color(0xFF4ADE80) : const Color(0xFFFB923C);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: color),
        const SizedBox(height: 20),
        Text(
          isCorrect ? "Postura correcta" : "Corrección necesaria",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isCorrect
              ? "Mantienes una buena posición"
              : "Ajusta tu espalda y cuello",
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildInactiveView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.videocam_off_outlined,
            size: 48, color: Colors.white.withValues(alpha: 0.2)),
        const SizedBox(height: 20),
        const Text(
          "Monitoreo inactivo",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Selecciona una postura guardada para\ncomenzar el seguimiento.",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildUserNotFoundView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off_outlined,
            size: 48, color: Colors.white.withValues(alpha: 0.2)),
        const SizedBox(height: 20),
        const Text(
          "Usuario no detectado",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Entrando en modo de ahorro de energía (30s)",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLiveCameraView() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Analizando\npostura",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Mantén la espalda recta",
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12)),
              ],
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: cameraController!.value.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CameraPreview(cameraController!),
          ),
        ),
        Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF2962FF),
                shape: BoxShape.circle,
              ),
              child: Text("${countdown}s",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}
