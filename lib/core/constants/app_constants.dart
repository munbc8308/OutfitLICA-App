import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get aiApiKey => dotenv.env['AI_API_KEY'] ?? '';
  static String get aiApiBaseUrl =>
      dotenv.env['AI_API_BASE_URL'] ?? 'https://api.example.com';

  /// remove.bg API 키 (배경 제거)
  static String get removeBgApiKey => dotenv.env['REMOVE_BG_API_KEY'] ?? '';

  /// OpenWeatherMap API 키 (날씨)
  static String get weatherApiKey => dotenv.env['WEATHER_API_KEY'] ?? '';

  static const String appName = 'OutfitLICA';
  static const int imageQuality = 85;
  static const double maxImageSizeMB = 5.0;
}
