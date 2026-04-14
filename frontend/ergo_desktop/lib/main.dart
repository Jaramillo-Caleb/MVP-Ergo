import 'package:flutter/material.dart';
import 'package:ergo_desktop/features/auth/presentation/pages/login_page.dart';
import 'package:ergo_desktop/features/home/presentation/pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart' as di;
import 'package:ergo_desktop/core/utils/navigator_key.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ergo_desktop/features/pomodoro/data/services/work_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localNotifier.setup(appName: 'ERGO');
  await di.init();

  final storage = di.sl<FlutterSecureStorage>();
  final token = await storage.read(key: 'jwt_token');
  final userId = await storage.read(key: 'user_id');

  if (token != null && userId != null) {
    di.sl<WorkSessionService>().prefetchSettings(userId);
  }

  final initialHome = (token != null) ? const HomePage() : const LoginPage();

  runApp(ErgoApp(initialHome: initialHome));
}

class ErgoApp extends StatelessWidget {
  final Widget initialHome;
  const ErgoApp({super.key, required this.initialHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'ERGO Desktop',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Segoe UI',
      ),
      home: initialHome,
    );
  }
}
