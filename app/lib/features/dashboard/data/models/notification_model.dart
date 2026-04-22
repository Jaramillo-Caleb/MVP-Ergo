enum NotificationType { info, update, recommendation, alert }

class ErgoNotification {
  final String id;
  final String title;
  final String description;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  ErgoNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  factory ErgoNotification.fromJson(Map<String, dynamic> json) {
    return ErgoNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: _parseNotificationType(json['type']),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  static NotificationType _parseNotificationType(dynamic type) {
    if (type == null) return NotificationType.info;

    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'update':
        return NotificationType.update;
      case 'recommendation':
        return NotificationType.recommendation;
      case 'alert':
        return NotificationType.alert;
      case 'info':
      default:
        return NotificationType.info;
    }
  }
}
