# Localizy Server - API Documentation

Tài liệu chi tiết về tất cả API endpoints của Localizy Server.

## 📋 Danh sách tài liệu

- [Overview & Authentication](README.md) *(file này)*
- [Auth APIs](auth.md)
- [Admin Dashboard API](admin-dashboard.md)
- [User APIs](users.md)
- [Business APIs](business.md)
- [Address APIs](addresses.md)
- [Validation APIs](validations.md)
- [Parking APIs](parking.md)
- [Transaction APIs](transactions.md)
- [City APIs](cities.md)
- [Setting APIs](settings.md)
- [Home Slide APIs](home-slides.md)
- [Common Use Cases](use-cases.md)

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
