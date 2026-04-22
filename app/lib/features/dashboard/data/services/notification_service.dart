import '../models/notification_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';

abstract class NotificationService {
  Future<List<ErgoNotification>> getNotifications();
  void showNotification({required String title, required String body});
}

class TheNotificationService implements NotificationService {
  final Dio _dio;

  TheNotificationService(this._dio);

  @override
  Future<List<ErgoNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/api/notifications');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((n) => ErgoNotification.fromJson(n))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      return [];
    }
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
