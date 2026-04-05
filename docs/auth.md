# 🔑 Auth APIs

## 1. Register

```http
POST /api/auth/register
```

**Authorization:** Public

**Request Body:**
```json
{
  "email": "user@example.com",
  "name": "Nguyen Van A",
  "password": "Password123"
}
```

**Response:** `200 OK`
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "user@example.com",
  "name": "Nguyen Van A",
  "role": "User",
  "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
}
```

**Errors:**
- `400` - Email is already in use

---

## 2. Login

```http
POST /api/auth/login
```

**Authorization:** Public

**Request Body:**
```json
{
  "email": "admin@localizy.com",
  "password": "Admin@123"
}
```

**Response:** `200 OK`
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "admin@localizy.com",
  "name": "System Administrator",
  "role": "Admin",
  "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
}
```

**Errors:**
- `401` - Invalid email or password

---

## 3. Login with Google (Firebase)

```http
POST /api/auth/google-login
```

**Authorization:** Public

**Request Body:**
```json
{
  "idToken": "<Firebase ID Token>"
}
```

> `idToken` is obtained from the Firebase SDK after the user successfully signs in with Google on the client.

**Response:** `200 OK`
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "user@gmail.com",
  "name": "Nguyen Van A",
  "role": "User",
  "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
}
```

> If the email does not exist in the system, a new account is automatically created with the `User` role.

**Errors:**
- `401` - Invalid or expired Firebase token
  ```json
  { "message": "Invalid or expired Firebase token" }
  ```
- `401` - Email not found in token
  ```json
  { "message": "Email not found in token" }
  ```

---

## 4. Forgot Password

```http
POST /api/auth/forgot-password
```

**Authorization:** Public

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:** `200 OK`
```json
{
  "message": "If the email exists, we have sent a password reset link."
}
```

> **Note:** The API always returns `200` regardless of whether the email exists — this prevents attackers from enumerating valid emails.  
> The reset link is sent via email in the format: `{WEBSITE_BASE_URL}/reset-password?token=...`  
> Token is valid for **1 hour**.

---

## 5. Reset Password

```http
POST /api/auth/reset-password
```

**Authorization:** Public

**Request Body:**
```json
{
  "token": "<token from the reset email link>",
  "newPassword": "NewPassword123"
}
```

**Response:** `200 OK`
```json
{
  "message": "Password has been reset successfully."
}
```

**Errors:**
- `400` - Invalid or expired token
  ```json
  { "message": "Invalid or expired token" }
  ```

---

## 6. Register FCM Token (Push Notifications)

```http
PUT /api/auth/fcm-token
```

**Authorization:** Authenticated (any role)

Saves the device FCM token to the server to receive push notifications. Call this API after a successful login and after obtaining the FCM token from the Firebase SDK.

**Request Body:**
```json
{
  "fcmToken": "dHv3K2...Firebase_FCM_Device_Token"
}
```

**Response:** `200 OK`
```json
{
  "message": "FCM token updated successfully."
}
```

**Errors:**
- `401` - Invalid JWT token
- `400` - User not found

> **When to call again:**  
> - After every login  
> - When Firebase issues a new token (`onTokenRefresh`)  
> - When the app restarts and the token has changed

---

## 7. Verify Session

```http
GET /api/auth/verify
```

**Authorization:** Public (token passed via header)

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:** `200 OK` — Token is valid
```json
{
  "message": "Session is valid",
  "isExpired": false,
  "expiresAt": "2024-01-11T10:30:00Z"
}
```

**Errors:**
- `400` - Missing or malformed Authorization header
  ```json
  { "message": "Invalid token" }
  ```
- `401` - Token expired
  ```json
  { "message": "Session has expired", "isExpired": true, "expiresAt": "2024-01-10T10:30:00Z" }
  ```
- `401` - Invalid token (wrong signature, wrong issuer/audience, ...)
  ```json
  { "message": "Invalid token", "isExpired": false, "expiresAt": null }
  ```
