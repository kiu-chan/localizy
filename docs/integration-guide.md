# 🔌 API Integration Guide

Integration guide for **Web (React/Next.js)** and **Mobile (Flutter/Dart)** apps.

---

## Table of Contents

- [Base URL configuration](#base-url-configuration)
- [Authentication & token storage](#authentication--token-storage)
- [Attaching the token to requests](#attaching-the-token-to-requests)
- [Handling token expiry](#handling-token-expiry)
- [Login flow](#login-flow)
- [Google login flow](#google-login-flow)
- [Forgot password & reset password flow](#forgot-password--reset-password-flow)
- [Push Notification (FCM)](#push-notification-fcm)
- [General error handling](#general-error-handling)
- [File upload](#file-upload)

---

## Base URL configuration

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

## Authentication & token storage

### Web

```ts
// After a successful login/register
localStorage.setItem('auth_token', response.token);
localStorage.setItem('auth_user', JSON.stringify({
  userId: response.userId,
  name: response.name,
  email: response.email,
  role: response.role,
}));
```

> **Security note:** If the application is vulnerable to XSS, use `HttpOnly` cookies instead of `localStorage`.

### Flutter

```dart
// Use flutter_secure_storage
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

## Attaching the token to requests

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

## Handling token expiry

JWT tokens are valid for **24 hours**. When a token expires, the server returns `401`.

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

Or proactively check before making API calls:

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
// In AuthInterceptor
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

## Login flow

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

## Google login flow

Requires integrating the **Firebase SDK** on the client to obtain an `idToken`.

### Web

```ts
import { getAuth, signInWithPopup, GoogleAuthProvider } from 'firebase/auth';

async function loginWithGoogle(): Promise<AuthResponse> {
  const auth = getAuth();
  const provider = new GoogleAuthProvider();

  // 1. Sign in with Firebase, get idToken
  const result = await signInWithPopup(auth, provider);
  const idToken = await result.user.getIdToken();

  // 2. Send idToken to server
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
    // 1. Sign in with Google
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;

    // 2. Get Firebase idToken
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
    final idToken = await userCred.user!.getIdToken();

    // 3. Send idToken to server
    final res = await dio.post('/auth/google-login', data: {'idToken': idToken});
    final auth = AuthResponse.fromJson(res.data);
    await saveToken(auth.token);
    return auth;
  }
}
```

---

## Forgot password & reset password flow

### Step 1 — User enters email (Forgot Password page)

**Web:**
```ts
async function forgotPassword(email: string): Promise<void> {
  await api.post('/auth/forgot-password', { email });
  // Always succeeds (200), does not reveal whether the email exists
}
```

**Flutter:**
```dart
Future<void> forgotPassword(String email) async {
  await dio.post('/auth/forgot-password', data: {'email': email});
}
```

### Step 2 — Server sends an email with a reset link

Link format: `https://your-app.com/reset-password?token=abc123...`

### Step 3 — Web reads token from URL and shows the form

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
    // Redirect to login
  }

  if (!token) return <p>Invalid link.</p>;

  return (
    <form onSubmit={...}>
      <input type="password" placeholder="New password" />
      <button type="submit">Reset password</button>
    </form>
  );
}
```

**Flutter** — Handle token via deep link:
```dart
// Configure deep link: yourapp://reset-password?token=...
// In the app, listen for deep links and navigate accordingly
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

## Push Notification (FCM)

The server uses **Firebase Cloud Messaging (FCM)** to send push notifications to user devices when their verification request status changes.

### Events that trigger notifications

| Event | Title | When |
|-------|-------|------|
| Validator confirms appointment | Appointment confirmed | `status` → `Scheduled` |
| Admin/Validator approves verification | Address verified | `status` → `Verified` |
| Admin/Validator rejects | Verification request rejected | `status` → `Rejected` |

### Data payload structure

Every notification includes a `data` payload for the app to navigate to the correct screen:

```json
{
  "validationId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "requestId": "VAL-2024-042",
  "type": "appointment_confirmed | address_verified | address_rejected"
}
```

### Step 1 — Initialize Firebase and get the FCM Token

#### Flutter

```dart
// pubspec.yaml
// dependencies:
//   firebase_core: ^3.x.x
//   firebase_messaging: ^15.x.x

import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  static Future<String?> getToken() async {
    // Request permission (iOS)
    await FirebaseMessaging.instance.requestPermission();
    return await FirebaseMessaging.instance.getToken();
  }
}
```

### Step 2 — Register the FCM Token with the server after login

After a successful login and receiving a JWT token, immediately call `PUT /api/auth/fcm-token`.

#### Flutter

```dart
class AuthService {
  Future<void> loginAndRegisterFcm(String email, String password) async {
    // 1. Log in
    final res = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final auth = AuthResponse.fromJson(res.data);
    await saveToken(auth.token);

    // 2. Get FCM token and register it
    final fcmToken = await FcmService.getToken();
    if (fcmToken != null) {
      await dio.put('/auth/fcm-token', data: {'fcmToken': fcmToken});
    }
  }
}
```

> **Same for Google Login:** call `PUT /api/auth/fcm-token` immediately after receiving the JWT from `/auth/google-login`.

### Step 3 — Update the token when Firebase refreshes it

The FCM token may change. Listen for `onTokenRefresh` and update the server immediately when the token changes.

#### Flutter

```dart
// In main() or the root widget's initState()
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
  // Update the new token (only when logged in)
  final jwt = await getToken(); // User's JWT
  if (jwt != null) {
    await dio.put('/auth/fcm-token', data: {'fcmToken': newToken});
  }
});
```

### Step 4 — Handle incoming notifications

#### Flutter

```dart
// Foreground notification
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  final type = message.data['type'];
  final requestId = message.data['requestId'];
  final validationId = message.data['validationId'];

  // Show local notification or update UI
  showLocalNotification(
    title: message.notification?.title ?? '',
    body: message.notification?.body ?? '',
  );
});

// Background / terminated — tap to open app
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  final type = message.data['type'];
  final validationId = message.data['validationId'];

  // Navigate to the detail screen
  navigatorKey.currentState?.pushNamed(
    '/validation-detail',
    arguments: validationId,
  );
});
```

### Important notes

- FCM tokens are **only needed for mobile**. Web apps do not need to integrate this.
- If a user **has not registered an FCM token**, the server silently skips the notification — no error occurs.
- Make sure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are correctly configured in your Flutter project.

---

## General error handling

All errors have the format: `{ "message": "..." }`

### Web

```ts
async function apiCall<T>(fn: () => Promise<T>): Promise<T> {
  try {
    return await fn();
  } catch (error: any) {
    const message = error.response?.data?.message ?? 'Something went wrong, please try again.';
    throw new Error(message);
  }
}

// Usage:
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
    final message = e.response?.data?['message'] ?? 'Something went wrong, please try again.';
    throw ApiException(message);
  }
}

// Usage:
try {
  await apiCall(() => authService.login(email, password));
} on ApiException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
}
```

---

## File upload

Some APIs accept `multipart/form-data` (e.g. submitting a verification request with an ID document image).

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
