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

## 3. Kiểm tra phiên đăng nhập

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
