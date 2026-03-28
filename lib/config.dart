import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static String get apiBaseUrlAndroidEmulator =>
      dotenv.env['API_URL_ANDROID'] ?? 'http://10.0.2.2:8000';
  static String get apiBaseUrlIosSimulator =>
      dotenv.env['API_URL_IOS'] ?? 'http://localhost:8000';
  static String get apiBaseUrlPhysicalDevice =>
      dotenv.env['API_URL_PHYSICAL'] ?? 'http://192.168.1.X:8000';
  static String get urlMediasDefault => dotenv.env['URL_MEDIAS'] ?? '';
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '10') ?? 10;

  static String get effectiveApiUrlDefault {
    if (Platform.isAndroid) return apiBaseUrlAndroidEmulator;
    if (Platform.isIOS) return apiBaseUrlIosSimulator;
    return apiBaseUrlAndroidEmulator;
  }

  // Cache en mémoire chargé au démarrage via AppConfig.init()
  static String _effectiveApiUrl = '';
  static String _urlMedias = '';

  static String get effectiveApiUrl =>
      _effectiveApiUrl.isNotEmpty ? _effectiveApiUrl : effectiveApiUrlDefault;

  static String get urlMedias =>
      _urlMedias.isNotEmpty ? _urlMedias : urlMediasDefault;

  /// À appeler au démarrage de l'app (dans main()) avant runApp()
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _effectiveApiUrl =
        prefs.getString('config_api_url') ?? effectiveApiUrlDefault;
    _urlMedias = prefs.getString('config_url_medias') ?? urlMediasDefault;
  }
}
