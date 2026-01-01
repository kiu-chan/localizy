import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigManager {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }
}