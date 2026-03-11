# Localizy Server - API Documentation

Tài liệu chi tiết về tất cả API endpoints của Localizy Server.

## 📋 Table of Contents
- [Overview](#overview)
- [Authentication](#authentication)
- [Error Handling](#error-handling)
- [Auth APIs](#auth-apis)
- [Admin Dashboard API](#admin-dashboard-api)
- [User APIs](#user-apis)
- [Business APIs](#business-apis)
- [Address APIs](#address-apis)
- [Validation APIs](#validation-apis)
- [Parking APIs](#parking-apis)
- [Transaction APIs](#transaction-apis)
- [City APIs](#city-apis)
- [Setting APIs](#setting-apis)
- [Home Slide APIs](#home-slide-apis)
- [Common Use Cases](#common-use-cases)

---

## 🌐 Overview

### Base URL
```
http://localhost:5088/api
```

### Content Type
```
Content-Type: application/json
```

### Date Format
```
ISO 8601: 2024-01-10T10:30:00Z
```

---

## 🔐 Authentication

### JWT Bearer Token

API sử dụng JWT (JSON Web Token) để xác thực người dùng.

#### Cách lấy token:
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "admin@localizy.com",
  "password": "Admin@123"
}
```

#### Sử dụng token:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Token Properties:
- **Expiration**: 24 giờ
- **Algorithm**: HS256
- **Claims**: UserId, Email, Name, Role

### Authorization Levels

| Level | Description |
|-------|-------------|
| **Public** | Không cần token |
| **Authenticated** | Cần token hợp lệ (mọi role) |
| **Admin** | Chỉ role Admin |
| **Validator** | Chỉ role Validator |
| **Admin,Validator** | Admin hoặc Validator |
| **Business** | Chỉ role Business |
| **Business,SubAccount** | Business hoặc SubAccount |

### User Roles

| Role | Mô tả |
|------|-------|
| `User` | Người dùng thường - gửi yêu cầu xác minh địa chỉ |
| `Admin` | Quản trị viên - quản lý toàn hệ thống |
| `Validator` | Người xác minh - xác minh địa chỉ tại thực địa |
| `Business` | Tài khoản doanh nghiệp - thêm địa chỉ trực tiếp |
| `SubAccount` | Tài khoản phụ của doanh nghiệp - thêm địa chỉ trực tiếp |

---

## ⚠️ Error Handling

### Error Response Format

```json
{
  "message": "Error description here"
}
```

### HTTP Status Codes

| Code | Status | Description |
|------|--------|-------------|
| 200 | OK | Request thành công |
| 201 | Created | Tạo resource thành công |
| 204 | No Content | Xóa thành công |
| 400 | Bad Request | Dữ liệu không hợp lệ |
| 401 | Unauthorized | Invalid token or expired |
| 403 | Forbidden | Không có quyền truy cập |
| 404 | Not Found | Resource không tồn tại |
| 500 | Internal Server Error | Lỗi server |

---

## 📊 Admin Dashboard API

Trả về tổng quan toàn hệ thống cho Admin, bao gồm thống kê users, địa chỉ, validations, parking và cities.

```http
GET /api/dashboard
```

**Authorization:** Admin

**Response:** `200 OK`
```json
{
  "users": {
    "totalUsers": 100,
    "adminUsers": 2,
    "validatorUsers": 5,
    "regularUsers": 93
  },
  "addresses": {
    "totalAddresses": 500,
    "reviewedAddresses": 420,
    "pendingAddresses": 60,
    "rejectedAddresses": 20
  },
  "validations": {
    "totalRequests": 200,
    "pendingRequests": 50,
    "verifiedRequests": 130,
    "rejectedRequests": 20,
    "highPriorityRequests": 10,
    "todayRequests": 5
  },
  "parking": {
    "totalTickets": 1500,
    "activeTickets": 80,
    "expiredTickets": 1400,
    "todayTickets": 25,
    "totalRevenue": 52500000
  },
  "cities": {
    "totalCities": 10,
    "activeCities": 8,
    "inactiveCities": 2,
    "totalAddresses": 500,
    "topCities": [
      { "id": "...", "name": "Hà Nội", "code": "HAN", "addressCount": 150 }
    ]
  }
}
```

> 5 stats được fetch tuần tự (EF Core DbContext không hỗ trợ concurrent queries trên cùng một scoped instance).

---

## 🔑 Auth APIs

### 1. Đăng ký

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

### 2. Đăng nhập

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

### 3. Kiểm tra phiên đăng nhập

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

---

## 👥 User APIs

### User Response Object

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "name": "Nguyen Van A",
  "dateOfBirth": "1990-01-15T00:00:00Z",
  "phone": "0901234567",
  "email": "user@example.com",
  "documents": "[\"doc1.pdf\", \"doc2.pdf\"]",
  "role": "SubAccount",
  "parentBusinessId": "a1b2c3d4-5717-4562-b3fc-2c963f66afa6",
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": null
}
```

> **Lưu ý:** `parentBusinessId` chỉ có giá trị khi `role = "SubAccount"`. Với các role khác, trường này là `null`.

---

### 1. Lấy thống kê users

```http
GET /api/users/stats
```

**Authorization:** Admin

**Response:** `200 OK`
```json
{
  "totalUsers": 100,
  "adminUsers": 2,
  "validatorUsers": 5,
  "regularUsers": 93
}
```

---

### 2. Tìm kiếm users

```http
GET /api/users/search?searchTerm={term}
```

**Authorization:** Admin

**Query Parameters:**
- `searchTerm` (string): Tìm theo name hoặc email

**Response:** `200 OK` - Array of User objects

---

### 3. Lấy tất cả users

```http
GET /api/users
```

**Authorization:** Admin

**Response:** `200 OK` - Array of User objects

---

### 4. Lọc users theo role

```http
GET /api/users/filter/role/{role}
```

**Authorization:** Admin

**Path Parameters:**
- `role`: `User` | `Admin` | `Validator` | `Business` | `SubAccount`

**Response:** `200 OK` - Array of User objects

---

### 5. Lấy thông tin user theo ID

```http
GET /api/users/{id}
```

**Authorization:** Authenticated

**Response:** `200 OK` - User object

**Errors:**
- `404` - User not found

---

### 6. Tạo user mới

```http
POST /api/users
```

**Authorization:** Admin

**Request Body:**
```json
{
  "name": "Nguyen Van B",
  "dateOfBirth": "1995-06-20T00:00:00Z",
  "phone": "0912345678",
  "email": "newuser@example.com",
  "password": "Password123",
  "documents": null,
  "role": "Validator"
}
```

**Response:** `201 Created` - User object

**Errors:**
- `400` - Email is already in use

---

### 7. Cập nhật user

```http
PUT /api/users/{id}
```

**Authorization:** Authenticated

> **Lưu ý:** Chỉ Admin mới có thể thay đổi `role`. User thường chỉ cập nhật được thông tin của chính mình.

**Request Body:** (tất cả fields đều optional)
```json
{
  "name": "Nguyen Van A Updated",
  "dateOfBirth": "1990-01-15T00:00:00Z",
  "phone": "0901234567",
  "email": "newemail@example.com",
  "documents": "[\"doc1.pdf\"]",
  "role": "Validator"
}
```

**Response:** `200 OK` - User object

**Errors:**
- `404` - User not found
- `400` - Email is already in use

---

### 8. Xóa user

```http
DELETE /api/users/{id}
```

**Authorization:** Admin

**Response:** `204 No Content`

**Errors:**
- `404` - User not found

---

### 9. Đổi mật khẩu

```http
POST /api/users/{id}/change-password
```

**Authorization:** Authenticated

**Request Body:**
```json
{
  "currentPassword": "OldPassword123",
  "newPassword": "NewPassword456"
}
```

> **Lưu ý:** Admin có thể đổi mật khẩu của user khác mà không cần nhập `currentPassword`.

**Response:** `200 OK`
```json
{ "message": "Password changed successfully" }
```

**Errors:**
- `400` - Mật khẩu hiện tại không đúng
- `404` - User not found

---

## 🏢 Business APIs

Quản lý tài khoản con (SubAccount) và xem địa chỉ theo nhóm doanh nghiệp.

> **Lưu ý:** Tài khoản `SubAccount` có đầy đủ quyền thêm địa chỉ như `Business` (status tự động = `Reviewed`).

---

### 1. Trang chủ doanh nghiệp (Dashboard)

Trả về tổng quan và hoạt động gần đây của nhóm doanh nghiệp.

```http
GET /api/business/dashboard
```

**Authorization:** Business, SubAccount

**Hành vi theo role:**
| Role | Kết quả trả về |
|------|----------------|
| `Business` | Thống kê của business + tất cả sub-accounts |
| `SubAccount` | Thống kê của toàn nhóm (parent business + các sub-accounts) |

**Response:** `200 OK`
```json
{
  "totalLocations": 24,
  "subAccountCount": 8,
  "recentActivities": [
    {
      "type": "LocationAdded",
      "title": "New location added",
      "subtitle": "Coffee Shop",
      "timestamp": "2026-02-27T10:00:00Z",
      "actorName": "Nhân viên A"
    },
    {
      "type": "SubAccountCreated",
      "title": "New sub account created",
      "subtitle": "Manager Account",
      "timestamp": "2026-02-27T07:00:00Z",
      "actorName": null
    },
    {
      "type": "LocationUpdated",
      "title": "Location updated",
      "subtitle": "Restaurant",
      "timestamp": "2026-02-26T10:00:00Z",
      "actorName": "Nhân viên B"
    }
  ]
}
```

**Activity Types:**
| Type | Mô tả | actorName |
|------|--------|-----------|
| `LocationAdded` | Địa chỉ mới được thêm | Tên người thêm |
| `LocationUpdated` | Địa chỉ được cập nhật | Tên người sở hữu |
| `SubAccountCreated` | Tài khoản con được tạo | `null` |

> `recentActivities` trả về tối đa **10 hoạt động gần nhất** sắp xếp theo thời gian mới nhất.

---

### 2. Lấy danh sách tài khoản con

```http
GET /api/business/sub-accounts
```

**Authorization:** Business

**Response:** `200 OK`
```json
[
  {
    "id": "a1b2c3d4-5717-4562-b3fc-2c963f66afa6",
    "name": "Nhân viên A",
    "phone": "0901234567",
    "email": "staff.a@company.com",
    "documents": null,
    "role": "SubAccount",
    "parentBusinessId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "createdAt": "2026-01-10T10:30:00Z",
    "updatedAt": null
  }
]
```

---

### 3. Tạo tài khoản con mới

```http
POST /api/business/sub-accounts
```

**Authorization:** Business

**Request Body:**
```json
{
  "name": "Nhân viên B",
  "email": "staff.b@company.com",
  "password": "Password123",
  "phone": "0912345678",
  "dateOfBirth": null,
  "documents": null
}
```

> Role tự động được gán là `SubAccount`. Tài khoản con thuộc về Business đang đăng nhập.

**Response:** `201 Created` - User object với `role: "SubAccount"` và `parentBusinessId` trỏ về Business

**Errors:**
- `400` - Email is already in use
- `400` - Business account not found

---

### 4. Cập nhật tài khoản con

```http
PUT /api/business/sub-accounts/{id}
```

**Authorization:** Business

**Path Parameters:**
- `id`: ID của tài khoản con (phải thuộc Business đang đăng nhập)

**Request Body:** (tất cả fields đều optional)
```json
{
  "name": "Nhân viên B (đã đổi tên)",
  "phone": "0987654321",
  "email": "staff.b.new@company.com",
  "dateOfBirth": "1998-05-20T00:00:00Z",
  "documents": null
}
```

> Role của tài khoản con không thể thay đổi qua API này.

**Response:** `200 OK` - User object đã cập nhật

**Errors:**
- `400` - Email is already in use
- `404` - Sub-account not found or does not belong to this business

---

### 5. Lấy tất cả địa chỉ của nhóm doanh nghiệp

Trả về địa chỉ của **cả doanh nghiệp lẫn tất cả tài khoản con**.

```http
GET /api/business/addresses
```

**Authorization:** Business, SubAccount

**Hành vi theo role:**
| Role | Kết quả trả về |
|------|----------------|
| `Business` | Địa chỉ của business + tất cả sub-accounts |
| `SubAccount` | Địa chỉ của parent business + tất cả sub-accounts cùng cấp (bao gồm bản thân) |

**Response:** `200 OK` - Array of Address objects

```json
[
  {
    "id": "3fa85f64-...",
    "code": "HANX9K21",
    "name": "Văn phòng chính",
    "userId": "3fa85f64-...",
    "userName": "Công ty ABC",
    "status": "Reviewed",
    ...
  },
  {
    "id": "a1b2c3d4-...",
    "code": "HCMB3P54",
    "name": "Chi nhánh Q.1",
    "userId": "a1b2c3d4-...",
    "userName": "Nhân viên A",
    "status": "Reviewed",
    ...
  }
]
```

---

### 6. Lấy địa chỉ do tài khoản hiện tại thêm

Chỉ trả về địa chỉ mà **chính tài khoản đang đăng nhập** đã thêm (không bao gồm sub-accounts hay parent).

```http
GET /api/business/addresses/mine
```

**Authorization:** Business, SubAccount

**Response:** `200 OK` - Array of Address objects

---

## 📍 Address APIs

Quản lý danh sách địa chỉ (`AddressCodes`).

### Address Status

| Status | Mô tả |
|--------|-------|
| `Pending` | Chờ xác minh (địa chỉ do User thường gửi) |
| `Reviewed` | Đã được xác minh và chấp nhận |
| `Rejected` | Bị từ chối |

> **Lưu ý:** Business và SubAccount thêm địa chỉ sẽ có status `Reviewed` ngay lập tức, không cần xác minh.

### Address Response Object

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "code": "HANA3K92",
  "name": "Nhà hàng Phở Bắc",
  "fullAddress": "123 Nguyễn Trãi, P. Thượng Đình, Q. Thanh Xuân, Hà Nội",
  "district": "Thanh Xuân",
  "userId": "a1b2c3d4-...",
  "userName": "Nguyen Van A",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "cityCode": "HAN",
  "status": "Reviewed",
  "isVerified": true,
  "validatorId": "b2c3d4e5-...",
  "validatorName": "Tran Van B",
  "comments": "Đã xác minh tại thực địa",
  "extraDocs": "[\"photo1.jpg\"]",
  "parkingAvailable": true,
  "totalParkingSpots": 20,
  "availableSpots": 15,
  "pricePerHour": 10000,
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": "2024-01-11T08:00:00Z"
}
```

> **Ghi chú về mã địa chỉ (`code`):**
> - Được **tự động sinh** bởi hệ thống, không do người dùng nhập.
> - Format: `{CityCode}{5 ký tự ngẫu nhiên}` — tổng **8 ký tự** (`A-Z`, `0-9`).
> - Ví dụ: `cityCode = "HAN"` → `code = "HANA3K92"`

---

### 1. Thống kê địa chỉ

```http
GET /api/addresses/stats
```

**Authorization:** Admin

**Response:** `200 OK`
```json
{
  "totalAddresses": 500,
  "reviewedAddresses": 420,
  "pendingAddresses": 60,
  "rejectedAddresses": 20
}
```

---

### 2. Tìm kiếm địa chỉ (simple)

```http
GET /api/addresses/search?searchTerm={term}
```

**Authorization:** Public

**Query Parameters:**
- `searchTerm` (string): Tìm theo `code`, `name`, `fullAddress`, `district` hoặc `cityCode`

**Response:** `200 OK`
```json
[
  {
    "id": "3fa85f64-...",
    "code": "HANA3K92",
    "name": "Nhà hàng Phở Bắc",
    "fullAddress": "123 Nguyễn Trãi, P. Thượng Đình, Q. Thanh Xuân",
    "district": "Thanh Xuân",
    "latitude": 21.0285,
    "longitude": 105.8542,
    "cityCode": "HAN",
    "status": "Reviewed",
    "isVerified": true,
    "parkingAvailable": false,
    "totalParkingSpots": 0,
    "availableSpots": 0,
    "pricePerHour": 0
  }
]
```

---

### 3. Lọc theo status

```http
GET /api/addresses/filter/status/{status}
```

**Authorization:** Public

**Path Parameters:**
- `status`: `Pending` | `Reviewed` | `Rejected`

**Response:** `200 OK` - Array of Address objects

---

### 4. Lấy địa chỉ theo user

```http
GET /api/addresses/user/{userId}
```

**Authorization:** Authenticated

**Response:** `200 OK` - Array of Address objects

---

### 5. Lấy địa chỉ của user hiện tại

```http
GET /api/addresses/my-addresses
```

**Authorization:** Authenticated

**Response:** `200 OK` - Array of Address simple objects

---

### 6. Lấy tất cả địa chỉ

```http
GET /api/addresses
```

**Authorization:** Public

**Response:** `200 OK` - Array of Address objects

---

### 7. Lấy tọa độ tất cả địa chỉ

```http
GET /api/addresses/coordinates
```

**Authorization:** Public

**Response:** `200 OK`
```json
[
  {
    "id": "3fa85f64-...",
    "coordinates": {
      "lat": 21.0285,
      "lng": 105.8542
    }
  }
]
```

---

### 8. Lấy chi tiết địa chỉ

```http
GET /api/addresses/detail/{id}
```

**Authorization:** Public

**Response:** `200 OK` - Address object đầy đủ

---

### 9. Lấy địa chỉ theo ID

```http
GET /api/addresses/{id}
```

**Authorization:** Public

**Response:** `200 OK` - Address object

**Errors:**
- `404` - Địa chỉ không tồn tại

---

### 10. Thêm địa chỉ mới

```http
POST /api/addresses
```

**Authorization:** Authenticated

> **Mã địa chỉ được tự động sinh** — không cần truyền `code`. Hệ thống tạo mã dựa trên `cityCode` theo format `{cityCode}{5 ký tự ngẫu nhiên}` (8 ký tự, đảm bảo không trùng lặp).

**Request Body:**
```json
{
  "cityCode": "HAN",
  "name": "Nhà hàng Phở Bắc",
  "fullAddress": "123 Nguyễn Trãi, P. Thượng Đình, Q. Thanh Xuân, Hà Nội",
  "district": "Thanh Xuân",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "extraDocs": null,
  "parkingAvailable": false,
  "totalParkingSpots": 0,
  "pricePerHour": 0
}
```

**Validation:**
- `cityCode`: bắt buộc, đúng **3 ký tự** (ví dụ: `HAN`, `HCM`, `DAN`)

**Quy tắc theo role:**
| Role | Status sau khi tạo |
|------|--------------------|
| `User` | `Pending` - cần xác minh |
| `Admin` | `Pending` - cần xác minh |
| `Business` | `Reviewed` - không cần xác minh |
| `SubAccount` | `Reviewed` - không cần xác minh |

**Response:** `201 Created` - Address object (bao gồm `code` đã được sinh tự động)

**Errors:**
- `400` - `cityCode` không hợp lệ (không đúng 3 ký tự hoặc thiếu)

---

### 11. Cập nhật địa chỉ

```http
PUT /api/addresses/{id}
```

**Authorization:** Authenticated

**Request Body:** (tất cả fields đều optional)
```json
{
  "name": "Nhà hàng Phở Bắc (đã đổi tên)",
  "fullAddress": "456 Lê Duẩn, P. Điện Biên, Q. Ba Đình, Hà Nội",
  "district": "Ba Đình",
  "latitude": 21.0290,
  "longitude": 105.8550,
  "cityCode": "HAN",
  "validatorId": "b2c3d4e5-...",
  "comments": "Ghi chú cập nhật",
  "extraDocs": "[\"newdoc.pdf\"]",
  "parkingAvailable": true,
  "totalParkingSpots": 20,
  "pricePerHour": 10000
}
```

> **Lưu ý:** `code` không thể cập nhật — mã địa chỉ được sinh một lần tại thời điểm tạo và cố định. `cityCode` nếu cập nhật phải đúng **3 ký tự**.

**Response:** `200 OK` - Address object

---

### 12. Xóa địa chỉ

```http
DELETE /api/addresses/{id}
```

**Authorization:** Admin

**Response:** `204 No Content`

---

### 13. Xác minh địa chỉ (Review)

```http
POST /api/addresses/{id}/review
```

**Authorization:** Admin, Validator

**Request Body:**
```json
{
  "comments": "Đã xác minh thực địa, địa chỉ hợp lệ"
}
```

**Response:** `200 OK` - Address object với `status: "Reviewed"`

---

### 14. Từ chối địa chỉ

```http
POST /api/addresses/{id}/reject
```

**Authorization:** Admin, Validator

**Request Body:**
```json
{
  "comments": "Địa chỉ không tồn tại tại tọa độ đã cung cấp"
}
```

**Response:** `200 OK` - Address object với `status: "Rejected"`

---

### 15. Lấy danh sách bãi đỗ xe

Trả về các địa chỉ có `parkingAvailable = true` và `status = Reviewed`. `availableSpots` được tính động theo số vé đang active.

```http
GET /api/addresses/parking-zones
```

**Authorization:** Public

**Response:** `200 OK`
```json
[
  {
    "id": "3fa85f64-...",
    "code": "HANP7M21",
    "name": "Bãi đỗ xe Trần Duy Hưng",
    "fullAddress": "123 Trần Duy Hưng, Q. Cầu Giấy, Hà Nội",
    "district": "Cầu Giấy",
    "latitude": 21.0075,
    "longitude": 105.7989,
    "cityCode": "HAN",
    "status": "Reviewed",
    "isVerified": true,
    "parkingAvailable": true,
    "totalParkingSpots": 50,
    "availableSpots": 35,
    "pricePerHour": 10000
  }
]
```

---

## ✅ Validation APIs

Quản lý yêu cầu xác minh địa chỉ. Đây là flow cho người dùng thường yêu cầu xác minh địa chỉ của mình.

### Validation Status Flow

```
Pending → Assigned → Scheduled → Verified
                               ↘ Rejected
```

| Status | Mô tả | Ai thực hiện |
|--------|-------|--------------|
| `Pending` | Mới gửi, chờ admin xử lý | - |
| `Assigned` | Admin đã phân công validator | Admin |
| `Scheduled` | Validator đã xác nhận lịch hẹn | Validator |
| `Verified` | Đã xác minh thành công, địa chỉ vào danh sách | Admin/Validator |
| `Rejected` | Bị từ chối | Admin/Validator |

### Lưu ý về URL tài liệu

> Tất cả các trường `idDocumentUrl` và `addressProofUrl` trong response đều trả về **full URL** (bao gồm scheme + host), giúp client có thể truy cập trực tiếp để xem tài liệu xác minh.
>
> Ví dụ: `http://localhost:5088/uploads/verifications/cccd_xxx.jpg`

### Validation Response Object

```json
{
  "id": "3fa85f64-...",
  "requestId": "VAL-2024-001",
  "status": "Assigned",
  "priority": "Medium",
  "requestType": "NewAddress",
  "address": {
    "id": "a1b2c3d4-...",
    "code": "HANA3K92",
    "cityCode": "HAN",
    "coordinates": { "lat": 21.0285, "lng": 105.8542 }
  },
  "submittedBy": {
    "userId": "b2c3d4e5-...",
    "name": "Nguyen Van A",
    "email": "user@example.com"
  },
  "submittedDate": "2024-01-10T10:30:00Z",
  "notes": "New address verification request",
  "verificationData": {
    "photosProvided": true,
    "documentsProvided": true,
    "locationVerified": false,
    "idDocumentUrl": "http://localhost:5088/uploads/verifications/cccd_xxx.jpg",
    "addressProofUrl": "http://localhost:5088/uploads/verifications/proof_xxx.jpg"
  },
  "attachmentsCount": 2,
  "assignedValidator": {
    "userId": "c3d4e5f6-...",
    "name": "Tran Van Validator"
  },
  "assignedDate": "2024-01-11T09:00:00Z",
  "processedBy": null,
  "processedDate": null,
  "processingNotes": null,
  "rejectionReason": null,
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": "2024-01-11T09:00:00Z"
}
```

---

## Endpoints dành cho Admin

### 1. Thống kê validations

```http
GET /api/validations/stats
```

**Authorization:** Admin

**Response:** `200 OK`
```json
{
  "totalRequests": 200,
  "pendingRequests": 50,
  "verifiedRequests": 130,
  "rejectedRequests": 20,
  "highPriorityRequests": 10,
  "todayRequests": 5
}
```

---

### 2. Lấy tất cả validation requests

```http
GET /api/validations
```

**Authorization:** Admin

**Response:** `200 OK` - Array of Validation objects

---

### 3. Tìm kiếm validations

```http
GET /api/validations/search?searchTerm={term}
```

**Authorization:** Admin

**Query Parameters:**
- `searchTerm`: Tìm theo requestId, address code, tên người gửi, notes

**Response:** `200 OK` - Array of Validation objects

---

### 4. Lọc theo status

```http
GET /api/validations/filter/status/{status}
```

**Authorization:** Admin

**Path Parameters:**
- `status`: `Pending` | `Assigned` | `Scheduled` | `Verified` | `Rejected`

---

### 5. Lọc theo priority

```http
GET /api/validations/filter/priority/{priority}
```

**Authorization:** Admin

**Path Parameters:**
- `priority`: `Low` | `Medium` | `High`

---

### 6. Lấy validation theo ID

```http
GET /api/validations/{id}
```

**Authorization:** Admin

**Response:** `200 OK` - Validation object

---

### 7. Lấy validation theo Request ID

```http
GET /api/validations/request/{requestId}
```

**Authorization:** Admin

**Example:** `GET /api/validations/request/VAL-2024-001`

---

### 8. Phân công validator

Admin chỉ định validator sẽ đến xác minh địa chỉ.

```http
POST /api/validations/{id}/assign-validator
```

**Authorization:** Admin

**Request Body:**
```json
{
  "validatorId": "c3d4e5f6-5717-4562-b3fc-2c963f66afa6"
}
```

**Response:** `200 OK` - Validation object với `status: "Assigned"`

**Errors:**
- `400` - Validator not found
- `404` - Validation request không tồn tại

---

### 9. Xác minh địa chỉ (Admin)

Sau khi xác minh, địa chỉ sẽ được thêm vào danh sách `AddressCodes` với status `Reviewed`.

```http
POST /api/validations/{id}/verify
```

**Authorization:** Admin, Validator

**Request Body:**
```json
{
  "notes": "Đã xác minh thực địa, địa chỉ chính xác"
}
```

**Response:** `200 OK` - Validation object với `status: "Verified"`

---

### 10. Từ chối validation

```http
POST /api/validations/{id}/reject
```

**Authorization:** Admin, Validator

**Request Body:**
```json
{
  "reason": "Tọa độ không khớp với địa chỉ thực tế"
}
```

**Response:** `200 OK` - Validation object với `status: "Rejected"`

**Errors:**
- `400` - Reason không được để trống

---

### 11. Cập nhật validation

```http
PUT /api/validations/{id}
```

**Authorization:** Admin

**Request Body:** (tất cả fields đều optional)
```json
{
  "priority": "High",
  "notes": "Cập nhật ghi chú",
  "photosProvided": true,
  "documentsProvided": true,
  "locationVerified": false
}
```

---

### 12. Xóa validation

```http
DELETE /api/validations/{id}
```

**Authorization:** Admin

**Response:** `204 No Content`

---

## Endpoints dành cho Validator

### 12. Validator Dashboard

Lấy dữ liệu tổng quan cho Validator: thống kê task và 10 task được phân công gần nhất.

```http
GET /api/dashboard/validator
```

**Authorization:** Validator

**Response:** `200 OK`
```json
{
  "taskStats": {
    "totalAssigned": 20,
    "assignedCount": 3,
    "scheduledCount": 5,
    "verifiedCount": 10,
    "rejectedCount": 2,
    "todayAppointments": 2
  },
  "recentAssignments": [ /* Array of Validation objects */ ]
}
```

| Field | Mô tả |
|-------|-------|
| `totalAssigned` | Tổng số task được phân công |
| `assignedCount` | Task đang chờ xác nhận lịch hẹn |
| `scheduledCount` | Task đã xác nhận lịch hẹn |
| `verifiedCount` | Task đã xác minh thành công |
| `rejectedCount` | Task đã từ chối |
| `todayAppointments` | Số lịch hẹn hôm nay |
| `recentAssignments` | 10 task được phân công gần nhất |

---

### 13. Xem các task được phân công

Validator xem danh sách các yêu cầu xác minh được Admin phân công.

```http
GET /api/validations/my-assignments
```

**Authorization:** Validator

**Response:** `200 OK` - Array of Validation objects (chỉ các yêu cầu được phân công cho validator hiện tại)

---

### 14. Xác nhận lịch hẹn

Validator xác nhận sẽ đến xác minh theo lịch hẹn đã đặt.

```http
POST /api/validations/{id}/confirm-appointment
```

**Authorization:** Validator

**Response:** `200 OK` - Validation object với `status: "Scheduled"`

**Errors:**
- `403` - Validation này không được phân công cho bạn
- `404` - Validation request không tồn tại

---

### 15. Xác minh địa chỉ (Validator)

Sau khi đến thực địa và xác minh xong.

```http
POST /api/validations/{id}/verify
```

**Authorization:** Admin, Validator

*(Xem endpoint #9 ở trên)*

---

### 16. Từ chối (Validator)

```http
POST /api/validations/{id}/reject
```

**Authorization:** Admin, Validator

*(Xem endpoint #10 ở trên)*

---

## Endpoints dành cho User

### 17. Gửi yêu cầu xác minh địa chỉ

User thường gửi yêu cầu xác minh kèm tài liệu chứng minh.

```http
POST /api/validations/verification-request
```

**Authorization:** User (role = User)

**Content-Type:** `multipart/form-data`

**Form Fields:**

| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `IdDocument` | file | Không | Ảnh CCCD hoặc Hộ chiếu |
| `AddressProof` | file | Không | Giấy tờ chứng minh địa chỉ |
| `AddressId` | string (Guid) | Không | ID địa chỉ hiện có (nếu cập nhật) |
| `RequestType` | string | Không | `NewAddress` \| `UpdateAddress` (default: `NewAddress`) |
| `Priority` | string | Không | `Low` \| `Medium` \| `High` (default: `Medium`) |
| `IdType` | string | Không | Loại giấy tờ: `CCCD`, `Passport`, ... |
| `PhotosProvided` | boolean | Không | Có cung cấp ảnh không |
| `DocumentsProvided` | boolean | Không | Có cung cấp tài liệu không |
| `AttachmentsCount` | integer | Không | Số lượng tệp đính kèm |
| `Latitude` | double | Không | Vĩ độ của địa chỉ |
| `Longitude` | double | Không | Kinh độ của địa chỉ |
| `LocationName` | string | Không | Tên địa điểm (VD: "Nhà hàng Phở Bắc", "Chung cư HH1") |
| `PaymentMethod` | string | Không | Phương thức thanh toán |
| `PaymentAmount` | decimal | Không | Số tiền thanh toán |
| `AppointmentDate` | datetime | Không | Ngày hẹn xác minh |
| `AppointmentTimeSlot` | string | Không | Khung giờ hẹn (VD: "9:00-11:00") |

**cURL Example:**
```bash
curl -X POST http://localhost:5088/api/validations/verification-request \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -F "IdDocument=@/path/to/cccd.jpg" \
  -F "AddressProof=@/path/to/address_proof.pdf" \
  -F "IdType=CCCD" \
  -F "Latitude=21.0285" \
  -F "Longitude=105.8542" \
  -F "LocationName=Nhà hàng Phở Bắc" \
  -F "PaymentMethod=Cash" \
  -F "PaymentAmount=150000" \
  -F "AppointmentDate=2024-02-15T09:00:00Z" \
  -F "AppointmentTimeSlot=9:00-11:00"
```

**Response:** `201 Created`
```json
{
  "id": "3fa85f64-...",
  "requestId": "VAL-2024-042",
  "status": "Pending",
  "priority": "Medium",
  "address": {},
  "documents": {
    "idType": "CCCD",
    "photosProvided": true,
    "documentsProvided": true,
    "attachmentsCount": 2,
    "idDocumentUrl": "http://localhost:5088/uploads/verifications/cccd_xxx.jpg",
    "addressProofUrl": "http://localhost:5088/uploads/verifications/proof_xxx.jpg"
  },
  "location": {
    "latitude": 21.0285,
    "longitude": 105.8542,
    "locationName": "Nhà hàng Phở Bắc"
  },
  "payment": {
    "method": "Cash",
    "amount": 150000,
    "status": "Pending"
  },
  "appointment": {
    "date": "2024-02-15T09:00:00Z",
    "timeSlot": "9:00-11:00"
  },
  "submittedDate": "2024-01-10T10:30:00Z",
  "createdAt": "2024-01-10T10:30:00Z"
}
```

---

### 18. Lấy chi tiết verification request

```http
GET /api/validations/verification-request/{id}
```

**Authorization:** Authenticated

**Response:** `200 OK` - Verification request object

---

### 19. Lấy validations theo user ID

```http
GET /api/validations/user/{userId}
```

**Authorization:** Authenticated

**Response:** `200 OK` - Array of Validation objects

---

### 20. Lấy validations của user hiện tại

```http
GET /api/validations/my-validations
```

**Authorization:** Authenticated

**Response:** `200 OK`
```json
[
  {
    "id": "3fa85f64-...",
    "requestId": "VAL-2024-042",
    "status": "Pending",
    "createdAt": "2024-01-10T10:30:00Z",
    "notes": "New address verification request",
    "paymentInfo": {
      "amount": 150000,
      "method": "momo",
      "status": "Pending"
    },
    "locationInfo": {
      "latitude": 21.0285,
      "longitude": 105.8542
    },
    "documentFiles": {
      "idType": "CCCD",
      "idDocumentUrl": "http://localhost:5088/uploads/verifications/cccd_xxx.jpg",
      "addressProofUrl": "http://localhost:5088/uploads/verifications/proof_xxx.jpg"
    },
    "appointmentInfo": {
      "date": "2024-02-15T09:00:00Z",
      "timeSlot": "9:00-11:00"
    }
  }
]
```

> **Lưu ý:** `appointmentInfo` là `null` nếu chưa có lịch hẹn.

---

## 🅿️ Parking APIs

Quản lý vé đỗ xe. Địa điểm đỗ xe là các địa chỉ có `parkingAvailable = true` và `status = Reviewed`.

### Parking Ticket Status

| Status | Mô tả |
|--------|-------|
| `Active` | Vé đang có hiệu lực |
| `Expired` | Vé đã hết hạn |
| `Cancelled` | Vé đã bị hủy |

### Duration & Price

| Duration | Giá (VND) |
|----------|-----------|
| `1h` | 10,000 |
| `2h` | 18,000 |
| `4h` | 35,000 |
| `8h` | 65,000 |
| `1day` | 100,000 |

### Parking Ticket Response Object

```json
{
  "id": "3fa85f64-...",
  "ticketCode": "PKT12345678",
  "licensePlate": "30A-12345",
  "parkingZone": "Bãi đỗ xe Trần Duy Hưng",
  "duration": "4h",
  "startTime": "2024-01-10T10:00:00Z",
  "endTime": "2024-01-10T14:00:00Z",
  "amount": 35000,
  "paymentMethod": "momo",
  "status": "Active",
  "paidAt": "2024-01-10T10:00:00Z",
  "userId": "a1b2c3d4-...",
  "addressId": "b2c3d4e5-...",
  "createdAt": "2024-01-10T10:00:00Z"
}
```

---

### 1. Tạo vé đỗ xe

```http
POST /api/parking
```

**Authorization:** Public (không bắt buộc đăng nhập)

**Request Body:**
```json
{
  "licensePlate": "30A-12345",
  "addressId": "3fa85f64-...",
  "duration": "4h",
  "paymentMethod": "momo",
  "startTime": null
}
```

| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `licensePlate` | string | **Có** | Biển số xe |
| `addressId` | Guid | Không | ID bãi đỗ xe (ưu tiên) |
| `parkingZone` | string | Không | Tên khu vực (fallback nếu không có addressId) |
| `duration` | string | **Có** | `1h` \| `2h` \| `4h` \| `8h` \| `1day` |
| `paymentMethod` | string | **Có** | `momo` \| `zalopay` \| `bank` \| `card` \| `cash` |
| `startTime` | datetime | Không | Thời gian bắt đầu (mặc định: UtcNow) |

**Response:** `201 Created` - Parking Ticket object

**Errors:**
- `400` - Duration không hợp lệ
- `400` - Bãi đỗ xe không chấp nhận đỗ xe
- `400` - Bãi đỗ xe đã đầy (không còn chỗ)

---

### 2. Lấy vé theo ID

```http
GET /api/parking/{id}
```

**Authorization:** Public

**Response:** `200 OK` - Parking Ticket object

**Errors:**
- `404` - Vé không tồn tại

---

### 3. Lấy vé theo Ticket Code

```http
GET /api/parking/ticket/{ticketCode}
```

**Authorization:** Public

**Example:** `GET /api/parking/ticket/PKT12345678`

**Response:** `200 OK` - Parking Ticket object (với trạng thái đã đồng bộ)

**Errors:**
- `404` - Mã vé không tồn tại

---

### 4. Lấy vé mới nhất theo biển số

Trả về vé gần đây nhất của một biển số xe (dùng cho trang kiểm tra thanh toán).

```http
GET /api/parking/license/{licensePlate}
```

**Authorization:** Public

**Example:** `GET /api/parking/license/30A-12345`

**Response:** `200 OK` - Parking Ticket object

**Errors:**
- `404` - Không có vé nào cho biển số này

---

### 5. Lấy vé của user hiện tại

```http
GET /api/parking/my-tickets
```

**Authorization:** Authenticated

**Response:** `200 OK` - Array of Parking Ticket objects

---

### 6. Lấy tất cả vé (Admin)

```http
GET /api/parking
```

**Authorization:** Admin

**Response:** `200 OK` - Array of Parking Ticket objects

---

### 7. Gia hạn vé đỗ xe

```http
POST /api/parking/{id}/extend
```

**Authorization:** Public

**Request Body:**
```json
{
  "duration": "2h",
  "paymentMethod": "momo"
}
```

**Response:** `200 OK` - Parking Ticket object với `endTime` đã được cộng thêm

**Errors:**
- `400` - Không thể gia hạn vé đã hết hạn hoặc bị hủy
- `404` - Vé không tồn tại

---

## 🔄 Transaction APIs

Lịch sử giao dịch tổng hợp (đỗ xe + xác minh địa chỉ).

### Transaction Response Object

```json
{
  "id": "PKT12345678",
  "type": "parking",
  "title": "Parking Payment",
  "location": "Bãi đỗ xe Trần Duy Hưng",
  "licensePlate": "30A-12345",
  "amount": 35000,
  "status": "success",
  "date": "2024-01-10T10:00:00Z",
  "paymentMethod": "momo",
  "duration": "4h"
}
```

| Field | Mô tả |
|-------|-------|
| `type` | `parking` hoặc `verification` |
| `status` | `success` \| `failed` \| `pending` |
| `licensePlate` | Chỉ có khi `type = parking` |
| `duration` | Chỉ có khi `type = parking` |

**Mapping trạng thái:**
- Parking: `Active/Expired` → `success`, `Cancelled` → `failed`
- Verification: `Verified` → `success`, `Rejected` → `failed`, còn lại → `pending`

---

### 1. Lấy lịch sử giao dịch của user hiện tại

Trả về tổng hợp vé đỗ xe + yêu cầu xác minh địa chỉ, sắp xếp theo thời gian mới nhất.

```http
GET /api/transactions/my-transactions
```

**Authorization:** Authenticated

**Response:** `200 OK` - Array of Transaction objects (sắp xếp theo `date` giảm dần)

---

## 🏙️ City APIs

### City Response Object

```json
{
  "id": "3fa85f64-...",
  "name": "Hà Nội",
  "code": "HAN",
  "description": "Thủ đô Việt Nam",
  "isActive": true,
  "totalAddresses": 150,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": null
}
```

> **Mã thành phố (`code`)** phải đúng **3 ký tự** (ví dụ: `HAN`, `HCM`, `DAN`). Đây là prefix dùng để sinh mã địa chỉ tự động.

### Danh sách thành phố mặc định

| Thành phố | `code` |
|-----------|--------|
| Hà Nội | `HAN` |
| Hồ Chí Minh | `HCM` |
| Đà Nẵng | `DAN` |
| Hải Phòng | `HPH` |
| Cần Thơ | `CTH` |

### 1. Thống kê cities

```http
GET /api/cities/stats
```

**Authorization:** Admin

---

### 2. Tìm kiếm cities

```http
GET /api/cities/search?searchTerm={term}
```

**Authorization:** Public

**Query Parameters:**
- `searchTerm`: Tìm theo `name` hoặc `code`

---

### 3. Lấy cities đang active

```http
GET /api/cities/active
```

**Authorization:** Public

---

### 4. Lấy tất cả cities

```http
GET /api/cities
```

**Authorization:** Public

---

### 5. Lấy city theo ID

```http
GET /api/cities/{id}
```

**Authorization:** Public

---

### 6. Lấy city theo code

```http
GET /api/cities/code/{code}
```

**Authorization:** Public

---

### 7. Tạo city mới

```http
POST /api/cities
```

**Authorization:** Admin

**Request Body:**
```json
{
  "name": "Đà Nẵng",
  "code": "DAN",
  "description": "Thành phố biển miền Trung"
}
```

**Validation:**
- `name`: bắt buộc
- `code`: bắt buộc, đúng **3 ký tự**, tự động chuyển thành chữ hoa, phải là duy nhất

**Errors:**
- `400` - Code đã tồn tại hoặc không đúng 3 ký tự

---

### 8. Cập nhật city

```http
PUT /api/cities/{id}
```

**Authorization:** Admin

**Request Body:** (tất cả fields đều optional)
```json
{
  "name": "Đà Nẵng",
  "code": "DAN",
  "description": "Thành phố biển miền Trung",
  "isActive": true
}
```

**Validation:**
- `code`: nếu có, phải đúng **3 ký tự** và không trùng với city khác

---

### 9. Xóa city

```http
DELETE /api/cities/{id}
```

**Authorization:** Admin

---

### 10. Toggle active/inactive

```http
PATCH /api/cities/{id}/toggle-active
```

**Authorization:** Admin

---

## ⚙️ Setting APIs

### Setting Response Object

```json
{
  "key": "site_name",
  "value": "Localizy",
  "category": "general",
  "description": "Tên website"
}
```

### WebsiteConfig Response Object

```json
{
  "siteName": "Localizy",
  "siteDescription": "...",
  "logoUrl": "/uploads/logo.png",
  "primaryColor": "#1976D2"
}
```

---

### 1. Lấy cấu hình website

```http
GET /api/settings/website-config
```

**Authorization:** Public (không cần token)

**Response:** `200 OK` - WebsiteConfig object

---

### 2. Lấy tất cả settings

```http
GET /api/settings
```

**Authorization:** Admin

**Response:** `200 OK` - Array of Setting objects

---

### 3. Lấy settings theo category

```http
GET /api/settings/category/{category}
```

**Authorization:** Admin

**Path Parameters:**
- `category`: Tên category (VD: `general`, `parking`, `payment`)

**Response:** `200 OK` - Array of Setting objects

---

### 4. Lấy setting theo key

```http
GET /api/settings/{key}
```

**Authorization:** Admin

**Path Parameters:**
- `key`: Key của setting (VD: `site_name`)

**Response:** `200 OK` - Setting object

**Errors:**
- `404` - Setting không tồn tại

---

### 5. Cập nhật setting

```http
PUT /api/settings/{key}
```

**Authorization:** Admin

**Path Parameters:**
- `key`: Key của setting cần cập nhật

**Request Body:**
```json
{
  "value": "Localizy Platform",
  "description": "Mô tả mới (optional)"
}
```

**Response:** `200 OK` - Setting object đã cập nhật

**Errors:**
- `404` - Setting không tồn tại

---

## 🖼️ Home Slide APIs

Quản lý các slide ảnh hiển thị trên trang chủ.

### HomeSlide Response Object

```json
{
  "id": "3fa85f64-...",
  "content": "Chào mừng đến với Localizy",
  "imageUrl": "/uploads/home-slides/slide1.jpg",
  "order": 1,
  "isActive": true,
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": null
}
```

---

### 1. Lấy các slide đang active

```http
GET /api/homeslides/active
```

**Authorization:** Public

**Response:** `200 OK` - Array of HomeSlide objects (chỉ các slide có `isActive = true`)

---

### 2. Lấy tất cả slides (Admin)

```http
GET /api/homeslides
```

**Authorization:** Admin

**Response:** `200 OK` - Array of HomeSlide objects (bao gồm cả slide inactive)

---

### 3. Lấy slide theo ID

```http
GET /api/homeslides/{id}
```

**Authorization:** Admin

**Response:** `200 OK` - HomeSlide object

**Errors:**
- `404` - Slide không tồn tại

---

### 4. Tạo slide mới

```http
POST /api/homeslides
```

**Authorization:** Admin

**Content-Type:** `multipart/form-data`

**Form Fields:**

| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `image` | file | **Có** | File ảnh slide |
| `content` | string | **Có** | Nội dung/tiêu đề slide |
| `order` | integer | Không | Thứ tự hiển thị (default: 0) |
| `isActive` | boolean | Không | Hiển thị hay không (default: true) |

**cURL Example:**
```bash
curl -X POST http://localhost:5088/api/homeslides \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -F "image=@/path/to/slide.jpg" \
  -F "content=Chào mừng đến với Localizy" \
  -F "order=1" \
  -F "isActive=true"
```

**Response:** `201 Created` - HomeSlide object

**Errors:**
- `400` - Thiếu file ảnh

---

### 5. Cập nhật slide

```http
PUT /api/homeslides/{id}
```

**Authorization:** Admin

**Content-Type:** `multipart/form-data`

**Form Fields:** (tất cả đều optional)

| Field | Type | Mô tả |
|-------|------|-------|
| `image` | file | Ảnh mới (nếu muốn thay ảnh) |
| `content` | string | Nội dung mới |
| `order` | integer | Thứ tự mới |
| `isActive` | boolean | Trạng thái mới |

**Response:** `200 OK` - HomeSlide object đã cập nhật

**Errors:**
- `404` - Slide không tồn tại

---

### 6. Xóa slide

```http
DELETE /api/homeslides/{id}
```

**Authorization:** Admin

File ảnh liên quan cũng bị xóa khỏi server.

**Response:** `204 No Content`

**Errors:**
- `404` - Slide không tồn tại

---

## 🔄 Common Use Cases

### Flow 1: User thường xác minh địa chỉ

```
1. User đăng nhập
   POST /api/auth/login

2. User gửi yêu cầu xác minh kèm ảnh CCCD và giấy tờ địa chỉ
   POST /api/validations/verification-request
   (multipart/form-data: IdDocument, AddressProof, Latitude, Longitude, LocationName, AppointmentDate, ...)

3. Admin xem danh sách yêu cầu
   GET /api/validations?status=Pending

4. Admin phân công validator
   POST /api/validations/{id}/assign-validator
   { "validatorId": "..." }

5. Validator xem task được phân công
   GET /api/validations/my-assignments

6. Validator xác nhận lịch hẹn
   POST /api/validations/{id}/confirm-appointment

7. Validator đến thực địa, xác minh xong
   POST /api/validations/{id}/verify
   { "notes": "Đã xác minh, hợp lệ" }

✅ Địa chỉ được thêm vào AddressCodes với status = Reviewed
```

---

### Flow 2: Business thêm địa chỉ trực tiếp

```
1. Business đăng nhập (role = Business hoặc SubAccount)
   POST /api/auth/login

2. Thêm địa chỉ trực tiếp (không cần xác minh) — mã địa chỉ tự động sinh
   POST /api/addresses
   { "name": "Văn phòng Công ty ABC", "fullAddress": "Tầng 5, 99 Láng Hạ, Q. Đống Đa, Hà Nội", "latitude": 21.02, "longitude": 105.85, "cityCode": "HAN" }

✅ Địa chỉ ngay lập tức có status = Reviewed
```

---

### Flow 3: Business quản lý tài khoản con

```
1. Business đăng nhập
   POST /api/auth/login

2. Tạo tài khoản con cho nhân viên
   POST /api/business/sub-accounts
   { "name": "Nhân viên A", "email": "staff.a@company.com", "password": "Pass@123", "phone": "0901234567" }

3. Nhân viên (SubAccount) đăng nhập và thêm địa chỉ
   POST /api/auth/login  (dùng tài khoản sub-account)
   POST /api/addresses
   { "name": "Chi nhánh Q.3", "cityCode": "HCM", "latitude": ..., "longitude": ... }
   → Status = Reviewed ngay lập tức, mã địa chỉ tự động sinh (ví dụ: HCMB7X21)

4. Business xem tất cả địa chỉ của nhóm (cả mình lẫn sub-accounts)
   GET /api/business/addresses

5. Business chỉ xem địa chỉ mà mình đã thêm
   GET /api/business/addresses/mine

6. SubAccount xem tất cả địa chỉ trong nhóm (bao gồm địa chỉ của parent và các sub-account cùng cấp)
   GET /api/business/addresses  (dùng token của SubAccount)

7. Business cập nhật thông tin tài khoản con
   PUT /api/business/sub-accounts/{subAccountId}
   { "phone": "0912345678" }
```

---

### Flow 4: Admin xác minh trực tiếp (không qua validator)

```
1. Admin xem danh sách yêu cầu pending
   GET /api/validations/filter/status/Pending

2. Admin xác minh trực tiếp
   POST /api/validations/{id}/verify
   { "notes": "Admin xác minh trực tiếp" }

✅ Địa chỉ được thêm vào AddressCodes với status = Reviewed
```

---

### Flow 5: Tìm kiếm địa chỉ

```
# Tìm theo code, name, fullAddress, district hoặc cityCode
GET /api/addresses/search?searchTerm=HAN
GET /api/addresses/search?searchTerm=HANA3K92
GET /api/addresses/search?searchTerm=Phở+Bắc
GET /api/addresses/search?searchTerm=Thanh+Xuân

# Lấy tất cả tọa độ để hiển thị trên map
GET /api/addresses/coordinates

# Lọc theo status
GET /api/addresses/filter/status/Reviewed
```

---

### Flow 6: Đăng ký và kiểm tra vé đỗ xe

```
1. Lấy danh sách bãi đỗ xe để hiển thị trên map
   GET /api/addresses/parking-zones

2. Đăng ký vé đỗ xe (có thể không cần đăng nhập)
   POST /api/parking
   { "licensePlate": "30A-12345", "addressId": "3fa85f64-...", "duration": "4h", "paymentMethod": "momo" }
   → Trả về ticketCode: "PKT12345678"

3. Kiểm tra vé theo mã vé
   GET /api/parking/ticket/PKT12345678

4. Kiểm tra vé theo biển số (vé mới nhất)
   GET /api/parking/license/30A-12345

5. Gia hạn vé
   POST /api/parking/{id}/extend
   { "duration": "2h", "paymentMethod": "momo" }

6. User đã đăng nhập xem lịch sử vé đỗ xe
   GET /api/parking/my-tickets
```

---

### Flow 7: Xem lịch sử giao dịch tổng hợp

```
1. Lấy tất cả giao dịch (đỗ xe + xác minh) của user hiện tại
   GET /api/transactions/my-transactions
   → Trả về list sắp xếp theo ngày giảm dần, gồm cả type "parking" và "verification"

2. Chỉ xem lịch sử vé đỗ xe
   GET /api/parking/my-tickets

3. Chỉ xem lịch sử xác minh địa chỉ
   GET /api/validations/my-validations
```
