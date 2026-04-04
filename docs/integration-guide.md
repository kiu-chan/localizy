# 🔌 Hướng dẫn tích hợp API

Hướng dẫn tích hợp dành cho **Web (React/Next.js)** và **Mobile (Flutter/Dart)**.

---

## Mục lục

- [Cấu hình base URL](#cấu-hình-base-url)
- [Xác thực & lưu token](#xác-thực--lưu-token)
- [Đính kèm token vào request](#đính-kèm-token-vào-request)
- [Xử lý token hết hạn](#xử-lý-token-hết-hạn)
- [Luồng đăng nhập](#luồng-đăng-nhập)
- [Luồng đăng nhập Google](#luồng-đăng-nhập-google)
- [Luồng quên mật khẩu & đặt lại mật khẩu](#luồng-quên-mật-khẩu--đặt-lại-mật-khẩu)
- [Xử lý lỗi chung](#xử-lý-lỗi-chung)
- [Upload file](#upload-file)

---

## Cấu hình base URL

### Web (React/Next.js)

```ts
// lib/api.ts
const BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:5088/api';
```

`.env.local`:
```
NEXT_PUBLIC_API_URL=https://citizenapi.azurewebsites.net/api
```

### Flutter

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5088/api',
  );
}
```

---

## Xác thực & lưu token

### Web

```ts
// Sau khi login/register thành công
localStorage.setItem('auth_token', response.token);
localStorage.setItem('auth_user', JSON.stringify({
  userId: response.userId,
  name: response.name,
  email: response.email,
  role: response.role,
}));
```

> **Lưu ý bảo mật:** Nếu ứng dụng có nguy cơ XSS, hãy dùng cookie `HttpOnly` thay vì `localStorage`.

### Flutter

```dart
// Dùng flutter_secure_storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();

Future<void> saveToken(String token) async {
  await _storage.write(key: 'auth_token', value: token);
}

Future<String?> getToken() async {
  return await _storage.read(key: 'auth_token');
}

Future<void> clearToken() async {
  await _storage.delete(key: 'auth_token');
}
```

---

## Đính kèm token vào request

### Web — Axios interceptor

```ts
// lib/api.ts
import axios from 'axios';

const api = axios.create({ baseURL: BASE_URL });

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export default api;
```

### Flutter — Dio interceptor

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl))
  ..interceptors.add(AuthInterceptor());
```

---

## Xử lý token hết hạn

Token JWT có hiệu lực **24 giờ**. Khi token hết hạn, server trả về `401`.

### Web

```ts
// lib/api.ts
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('auth_token');
      localStorage.removeItem('auth_user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

Hoặc kiểm tra chủ động trước khi gọi API:

```ts
async function verifySession(): Promise<boolean> {
  const token = localStorage.getItem('auth_token');
  if (!token) return false;

  try {
    const res = await axios.get(`${BASE_URL}/auth/verify`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    return !res.data.isExpired;
  } catch {
    return false;
  }
}
```

### Flutter

```dart
// Trong AuthInterceptor
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode == 401) {
    await _storage.deleteAll();
    // Navigate to login screen
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }
  handler.next(err);
}
```

---

## Luồng đăng nhập

### Web

```ts
interface AuthResponse {
  token: string;
  email: string;
  name: string;
  role: string;
  userId: string;
}

async function login(email: string, password: string): Promise<AuthResponse> {
  const { data } = await api.post<AuthResponse>('/auth/login', { email, password });
  localStorage.setItem('auth_token', data.token);
  return data;
}

async function register(name: string, email: string, password: string): Promise<AuthResponse> {
  const { data } = await api.post<AuthResponse>('/auth/register', { name, email, password });
  localStorage.setItem('auth_token', data.token);
  return data;
}

function logout() {
  localStorage.removeItem('auth_token');
  localStorage.removeItem('auth_user');
  window.location.href = '/login';
}
```

### Flutter

```dart
class AuthService {
  Future<AuthResponse> login(String email, String password) async {
    final res = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final auth = AuthResponse.fromJson(res.data);
    await saveToken(auth.token);
    return auth;
  }

  Future<AuthResponse> register(String name, String email, String password) async {
    final res = await dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    final auth = AuthResponse.fromJson(res.data);
    await saveToken(auth.token);
    return auth;
  }

  Future<void> logout() async {
    await clearToken();
  }
}
```

---

## Luồng đăng nhập Google

Yêu cầu tích hợp **Firebase SDK** trên client để lấy `idToken`.

### Web

```ts
import { getAuth, signInWithPopup, GoogleAuthProvider } from 'firebase/auth';

async function loginWithGoogle(): Promise<AuthResponse> {
  const auth = getAuth();
  const provider = new GoogleAuthProvider();

  // 1. Đăng nhập Firebase, lấy idToken
  const result = await signInWithPopup(auth, provider);
  const idToken = await result.user.getIdToken();

  // 2. Gửi idToken lên server
  const { data } = await api.post<AuthResponse>('/auth/google-login', { idToken });
  localStorage.setItem('auth_token', data.token);
  return data;
}
```

### Flutter

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final _googleSignIn = GoogleSignIn();

  Future<AuthResponse> loginWithGoogle() async {
    // 1. Đăng nhập Google
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;

    // 2. Lấy Firebase idToken
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
    final idToken = await userCred.user!.getIdToken();

    // 3. Gửi idToken lên server
    final res = await dio.post('/auth/google-login', data: {'idToken': idToken});
    final auth = AuthResponse.fromJson(res.data);
    await saveToken(auth.token);
    return auth;
  }
}
```

---

## Luồng quên mật khẩu & đặt lại mật khẩu

### Bước 1 — User nhập email (trang "Quên mật khẩu")

**Web:**
```ts
async function forgotPassword(email: string): Promise<void> {
  await api.post('/auth/forgot-password', { email });
  // Luôn thành công (200), không lộ email có tồn tại hay không
}
```

**Flutter:**
```dart
Future<void> forgotPassword(String email) async {
  await dio.post('/auth/forgot-password', data: {'email': email});
}
```

### Bước 2 — Server gửi email chứa link

Link dạng: `https://your-app.com/reset-password?token=abc123...`

### Bước 3 — Web đọc token từ URL và hiển thị form

**Next.js (App Router):**
```tsx
// app/reset-password/page.tsx
'use client';
import { useSearchParams } from 'next/navigation';

export default function ResetPasswordPage() {
  const params = useSearchParams();
  const token = params.get('token') ?? '';

  async function handleSubmit(newPassword: string) {
    await api.post('/auth/reset-password', { token, newPassword });
    // Chuyển về trang login
  }

  if (!token) return <p>Link không hợp lệ.</p>;

  return (
    <form onSubmit={...}>
      <input type="password" placeholder="Mật khẩu mới" />
      <button type="submit">Đặt lại mật khẩu</button>
    </form>
  );
}
```

**Flutter** — Deep link xử lý token:
```dart
// Cấu hình deep link: yourapp://reset-password?token=...
// Trong app, lắng nghe deep link và điều hướng
GoRouter(
  routes: [
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        return ResetPasswordScreen(token: token);
      },
    ),
  ],
);

// ResetPasswordScreen
Future<void> resetPassword(String token, String newPassword) async {
  await dio.post('/auth/reset-password', data: {
    'token': token,
    'newPassword': newPassword,
  });
}
```

---

## Xử lý lỗi chung

Tất cả lỗi đều có dạng: `{ "message": "..." }`

### Web

```ts
async function apiCall<T>(fn: () => Promise<T>): Promise<T> {
  try {
    return await fn();
  } catch (error: any) {
    const message = error.response?.data?.message ?? 'Có lỗi xảy ra, vui lòng thử lại.';
    throw new Error(message);
  }
}

// Dùng:
try {
  await apiCall(() => login(email, password));
} catch (e) {
  alert(e.message); // "Invalid email or password"
}
```

### Flutter

```dart
Future<T> apiCall<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } on DioException catch (e) {
    final message = e.response?.data?['message'] ?? 'Có lỗi xảy ra, vui lòng thử lại.';
    throw ApiException(message);
  }
}

// Dùng:
try {
  await apiCall(() => authService.login(email, password));
} on ApiException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
}
```

---

## Upload file

Một số API nhận `multipart/form-data` (ví dụ: gửi yêu cầu xác minh với ảnh CCCD).

### Web

```ts
async function submitVerification(data: {
  latitude: number;
  longitude: number;
  locationName: string;
  idDocument: File;
  addressProof: File;
}) {
  const form = new FormData();
  form.append('Latitude', String(data.latitude));
  form.append('Longitude', String(data.longitude));
  form.append('LocationName', data.locationName);
  form.append('IdDocument', data.idDocument);
  form.append('AddressProof', data.addressProof);

  const { data: result } = await api.post('/validations/verification-request', form, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
  return result;
}
```

### Flutter

```dart
Future<void> submitVerification({
  required double latitude,
  required double longitude,
  required String locationName,
  required File idDocument,
  required File addressProof,
}) async {
  final form = FormData.fromMap({
    'Latitude': latitude,
    'Longitude': longitude,
    'LocationName': locationName,
    'IdDocument': await MultipartFile.fromFile(idDocument.path),
    'AddressProof': await MultipartFile.fromFile(addressProof.path),
  });
  await dio.post('/validations/verification-request', data: form);
}
```
