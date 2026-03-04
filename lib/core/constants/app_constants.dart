import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get aiApiKey => dotenv.env['AI_API_KEY'] ?? '';
  static String get aiApiBaseUrl =>
      dotenv.env['AI_API_BASE_URL'] ?? 'https://api.example.com';

  static const String appName = 'OutfitLICA';
  static const int imageQuality = 85;
  static const double maxImageSizeMB = 5.0;
}
