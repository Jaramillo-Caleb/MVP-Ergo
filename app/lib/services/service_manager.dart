import 'dart:io';

class ServiceManager {
  static Process? _gatewayProcess;

  static Future<void> startServices() async {
    null;
  }

  static void stopServices() {
    _gatewayProcess?.kill();
  }
}
