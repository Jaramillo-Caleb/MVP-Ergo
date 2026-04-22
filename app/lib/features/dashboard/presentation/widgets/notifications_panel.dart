import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';
import '../../data/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationsPanel extends StatelessWidget {
  final List<ErgoNotification> notifications;
  final VoidCallback onClose;

  const NotificationsPanel({
    super.key,
    required this.notifications,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 380,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white, // Fondo limpio
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: notifications.isEmpty ? _buildEmptyState() : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Notificaciones",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
              fontFamily: 'Segoe UI',
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close,
                size: 20, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No hay notificaciones",
        style: TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Segoe UI',
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _NotificationItem(notification: notifications[index]);
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final ErgoNotification notification;
  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                notification.title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                DateFormat('HH:mm').format(notification.timestamp),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notification.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMain,
              height: 1.3,
              fontFamily: 'Segoe UI',
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }
}
