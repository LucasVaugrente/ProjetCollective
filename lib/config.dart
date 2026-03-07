import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrlAndroidEmulator =>
      dotenv.env['API_URL_ANDROID'] ?? 'http://10.0.2.2:8000';

  static String get apiBaseUrlIosSimulator =>
      dotenv.env['API_URL_IOS'] ?? 'http://localhost:8000';

  static String get apiBaseUrlPhysicalDevice =>
      dotenv.env['API_URL_PHYSICAL'] ?? 'http://192.168.1.X:8000';

  static String get urlMedias =>
      dotenv.env['URL_MEDIAS'] ?? '';

  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '"10') ?? 10;

  static String get effectiveApiUrl {
    if (Platform.isAndroid) return apiBaseUrlAndroidEmulator;
    if (Platform.isIOS) return apiBaseUrlIosSimulator;
    return apiBaseUrlAndroidEmulator;
  }
}