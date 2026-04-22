import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../features/profile/data/services/profile_service.dart';
import '../../features/dashboard/data/services/posture_service.dart';
import '../../features/dashboard/data/services/notification_service.dart';
import '../../features/pomodoro/data/services/work_session_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:5000/api",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    return dio;
  });

  sl.registerLazySingleton(() => ProfileService(sl()));
  sl.registerLazySingleton(() => PostureService(sl()));
  sl.registerLazySingleton(() => WorkSessionService(sl(), sl()));
  sl.registerLazySingleton<NotificationService>(
      () => TheNotificationService(sl()));
}
