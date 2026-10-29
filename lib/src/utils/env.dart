import 'package:flutter_dotenv/flutter_dotenv.dart';

// Class for Environment variables.
final class Environment {
  // A --dart-define=BACKEND_API_URL=... build flag takes precedence over the bundled .env file
  static const String _backendApiUrlDefine = String.fromEnvironment('BACKEND_API_URL');

  static String? backendApiUrl() {
    return _backendApiUrlDefine.isNotEmpty ? _backendApiUrlDefine : dotenv.env['BACKEND_API_URL'];
  }
}
