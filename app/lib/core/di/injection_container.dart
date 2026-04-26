import 'package:get_it/get_it.dart';
import 'package:ergo_desktop/core/database/app_database.dart';
import 'package:ergo_desktop/core/native/native_bridge.dart';
import 'dart:developer' as developer;

import '../../features/profile/data/services/profile_service.dart';
import '../../features/dashboard/data/services/posture_service.dart';
import '../../features/dashboard/data/services/notification_service.dart';
import '../../features/pomodoro/data/services/work_session_service.dart';
import '../../features/tasks/data/services/task_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final appDb = AppDatabase();
  sl.registerLazySingleton(() => appDb);

  final nativeBridge = NativeBridge();

  try {
    nativeBridge.initialize("pose_landmark_lite.onnx");
    developer.log("DI: NativeBridge inicializado y vinculado.");
  } catch (e) {
    developer.log("DI ERROR: No se pudo inicializar el motor nativo: $e");
  }

  sl.registerLazySingleton(() => NativeBridge());

  sl.registerLazySingleton(() => ProfileService(db: sl()));

  sl.registerLazySingleton(
      () => PostureService(db: sl(), bridge: sl<NativeBridge>()));

  sl.registerLazySingleton(() => WorkSessionService(
      db: sl(), notificationService: sl<NotificationService>()));

  sl.registerLazySingleton(() => TaskService(db: sl()));

  sl.registerLazySingleton<NotificationService>(() => TheNotificationService());
}
