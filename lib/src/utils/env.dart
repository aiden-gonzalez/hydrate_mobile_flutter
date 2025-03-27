import 'package:flutter_dotenv/flutter_dotenv.dart';

// Class for Environment variables.
final class Environment {
  static String? backendApiUrl() {
    return dotenv.env['BACKEND_API_URL'];
  }
}
