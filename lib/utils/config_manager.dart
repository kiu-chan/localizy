import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigManager {
  static String get googleMapsApiKeyAndroid {
    return dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'] ?? '';
  }

  static String get googleMapsApiKeyIOS {
    return dotenv.env['GOOGLE_MAPS_API_KEY_IOS'] ?? '';
  }

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }
}