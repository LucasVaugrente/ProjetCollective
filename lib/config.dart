import 'dart:io';

class AppConfig {
  // Configuration pour Android Emulator
  static const String apiBaseUrlAndroidEmulator = "http://10.0.2.2:8000";

  // Configuration pour iOS Simulator
  static const String apiBaseUrlIosSimulator = "http://localhost:8000";

  // Configuration pour appareil physique (WiFi)
  static const String apiBaseUrlPhysicalDevice = "http://192.168.1.X:8000";

  static const int apiTimeout = 10;

  static String get effectiveApiUrl {
    if (Platform.isAndroid) {
      return apiBaseUrlAndroidEmulator;
    } else if (Platform.isIOS) {
      return apiBaseUrlIosSimulator;
    } else {
      return apiBaseUrlAndroidEmulator;
    }
  }
}