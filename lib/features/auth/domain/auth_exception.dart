class AuthException implements Exception {
  AuthException([this.message = 'Authentication failed']);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
