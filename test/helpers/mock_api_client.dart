import 'package:http/http.dart' as http;
import 'package:localizy/core/network/api_client.dart';
import 'package:mocktail/mocktail.dart';

/// Mock của [ApiClient] dùng chung cho unit test repository.
/// `implements` nên không cần constructor thật (không chạm .env / secure storage).
class MockApiClient extends Mock implements ApiClient {}

/// Tạo [http.Response] JSON nhanh cho các stub postJson/putJson.
/// Ép charset UTF-8 để body chứa ký tự tiếng Việt không lỗi Latin1.
http.Response jsonResponse(String body, int statusCode) => http.Response(
      body,
      statusCode,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
