# 🔑 Auth APIs

## 1. Đăng ký

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

## 2. Đăng nhập

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

## 3. Đăng nhập bằng Google (Firebase)

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

> `idToken` lấy từ Firebase SDK sau khi người dùng đăng nhập Google thành công trên client.

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

> Nếu email chưa tồn tại trong hệ thống, tài khoản mới sẽ được tạo tự động với role `User`.

**Errors:**
- `401` - Firebase token không hợp lệ hoặc đã hết hạn
  ```json
  { "message": "Invalid or expired Firebase token" }
  ```
- `401` - Token không chứa email
  ```json
  { "message": "Email not found in token" }
  ```

---

## 4. Quên mật khẩu

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
  "message": "Nếu email tồn tại, chúng tôi đã gửi link đặt lại mật khẩu."
}
```

> **Lưu ý:** API luôn trả về `200` dù email có tồn tại hay không — điều này ngăn kẻ tấn công dò tìm email hợp lệ.  
> Link reset được gửi qua email có dạng: `{WEBSITE_BASE_URL}/reset-password?token=...`  
> Token có hiệu lực **1 giờ**.

---

## 5. Đặt lại mật khẩu

```http
POST /api/auth/reset-password
```

**Authorization:** Public

**Request Body:**
```json
{
  "token": "<token từ link trong email>",
  "newPassword": "NewPassword123"
}
```

**Response:** `200 OK`
```json
{
  "message": "Mật khẩu đã được đặt lại thành công."
}
```

**Errors:**
- `400` - Token không hợp lệ hoặc đã hết hạn
  ```json
  { "message": "Token không hợp lệ hoặc đã hết hạn" }
  ```

---

## 6. Kiểm tra phiên đăng nhập

```http
GET /api/auth/verify
```

**Authorization:** Public (token truyền qua header)

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:** `200 OK` - Token còn hiệu lực
```json
{
  "message": "Session is valid",
  "isExpired": false,
  "expiresAt": "2024-01-11T10:30:00Z"
}
```

**Errors:**
- `400` - Thiếu hoặc sai định dạng Authorization header
  ```json
  { "message": "Invalid token" }
  ```
- `401` - Token hết hạn
  ```json
  { "message": "Session has expired", "isExpired": true, "expiresAt": "2024-01-10T10:30:00Z" }
  ```
- `401` - Invalid token (wrong signature, wrong issuer/audience, ...)
  ```json
  { "message": "Invalid token", "isExpired": false, "expiresAt": null }
  ```
