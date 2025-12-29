import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigManager {
  static String get googleMapsApiKeyAndroid {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  static String get googleMapsApiKeyIOS {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }
}