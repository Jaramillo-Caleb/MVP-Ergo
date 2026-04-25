import '../models/notification_model.dart';
import 'package:local_notifier/local_notifier.dart';

abstract class NotificationService {
  Future<List<ErgoNotification>> getNotifications();
  void showNotification({required String title, required String body});
}

class TheNotificationService implements NotificationService {
  TheNotificationService();

  @override
  Future<List<ErgoNotification>> getNotifications() async {
    // Por ahora, lista vacía o de base de datos local si se implementa
    return [];
  }

  @override
  void showNotification({required String title, required String body}) {
    LocalNotification notification = LocalNotification(
      title: title,
      body: body,
      silent: false,
    );
    notification.show();
  }
}
