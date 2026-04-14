import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/auth/data/services/account_service.dart';
import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/utils/navigator_key.dart';
import 'package:ergo_desktop/features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/data/services/posture_service.dart';
import '../../features/dashboard/data/services/notification_service.dart';
import '../../features/pomodoro/data/services/work_session_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:8080",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = sl<FlutterSecureStorage>();
        final token = await storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          debugPrint("Sesión expirada (401). Limpiando datos...");

          final storage = sl<FlutterSecureStorage>();
          await storage.deleteAll();

          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
        return handler.next(e);
      },
    ));

    return dio;
  });

  sl.registerLazySingleton(() => AuthService(sl()));
  sl.registerLazySingleton(() => AccountService(sl()));
  sl.registerLazySingleton(() => PostureService(sl()));
  sl.registerLazySingleton(() => WorkSessionService(sl(), sl()));
  sl.registerLazySingleton<NotificationService>(
      () => TheNotificationService(sl()));
}
