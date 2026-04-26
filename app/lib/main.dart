import 'package:flutter/material.dart';
import 'package:ergo_desktop/features/home/presentation/pages/home_page.dart';
import 'package:ergo_desktop/features/profile/presentation/pages/complete_profile_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart' as di;
import 'package:ergo_desktop/core/utils/navigator_key.dart';
import 'package:local_notifier/local_notifier.dart';

import 'package:ergo_desktop/features/pomodoro/data/services/work_session_service.dart';
import 'package:ergo_desktop/features/profile/data/services/profile_service.dart';

import 'package:provider/provider.dart';
import 'package:ergo_desktop/features/tasks/data/services/task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await localNotifier.setup(appName: 'ERGO');
  await di.init();

  final profileService = di.sl<ProfileService>();
  final profile = await profileService.getProfile();

  Widget initialHome;
  if (profile != null) {
    di.sl<WorkSessionService>().prefetchSettings();
    initialHome = const HomePage();
  } else {
    initialHome = const CompleteProfilePage();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: di.sl<TaskService>()),
      ],
      child: ErgoApp(initialHome: initialHome),
    ),
  );
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
