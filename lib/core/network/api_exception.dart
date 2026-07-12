import 'package:http/http.dart' as http;

/// Lỗi chuẩn hóa cho mọi request đi qua ApiClient.
///
/// - [statusCode] == null nghĩa là lỗi mạng/timeout (request chưa tới server).
/// - Dùng [isUnauthorized] để phát hiện token hết hạn (sẽ xử lý tập trung
///   ở Giai đoạn 3 của lộ trình migrate).
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.body});

  /// Tạo từ [http.Response] khi status code không phải 2xx.
  factory ApiException.fromResponse(
    String method,
    String path,
    http.Response response,
  ) {
    return ApiException(
      '$method $path failed: ${response.statusCode} ${response.reasonPhrase}',
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  final String message;
  final int? statusCode;
  final String? body;

  bool get isUnauthorized => statusCode == 401;
  bool get isNetworkError => statusCode == null;

  @override
  String toString() => 'ApiException: $message';
}
