# Localizy Server - API Documentation

Tài liệu tổng quan về các API endpoints của Localizy Server.

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

API sử dụng **JWT Bearer Token**. Token có hiệu lực 24 giờ, được lấy qua endpoint đăng nhập.

```
Authorization: Bearer <token>
```

### Authorization Levels

| Level | Mô tả |
|-------|-------|
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

```json
{ "message": "Error description here" }
```

| Code | Status | Mô tả |
|------|--------|-------|
| 200 | OK | Request thành công |
| 201 | Created | Tạo resource thành công |
| 204 | No Content | Xóa thành công |
| 400 | Bad Request | Dữ liệu không hợp lệ |
| 401 | Unauthorized | Token không hợp lệ hoặc hết hạn |
| 403 | Forbidden | Không có quyền truy cập |
| 404 | Not Found | Resource không tồn tại |
| 500 | Internal Server Error | Lỗi server |

---

## 📚 Tài liệu chi tiết

| Module | Mô tả | Link |
|--------|-------|------|
| 🔑 Auth | Đăng ký, đăng nhập, kiểm tra phiên | [auth.md](docs/auth.md) |
| 📊 Dashboard | Tổng quan Admin & Validator | [admin-dashboard.md](docs/admin-dashboard.md) |
| 👥 Users | Quản lý người dùng | [users.md](docs/users.md) |
| 🏢 Business | Quản lý doanh nghiệp & tài khoản con | [business.md](docs/business.md) |
| 📍 Addresses | Quản lý địa chỉ | [addresses.md](docs/addresses.md) |
| ✅ Validations | Yêu cầu xác minh địa chỉ | [validations.md](docs/validations.md) |
| 🅿️ Parking | Vé đỗ xe | [parking.md](docs/parking.md) |
| 🔄 Transactions | Lịch sử giao dịch tổng hợp | [transactions.md](docs/transactions.md) |
| 🏙️ Cities | Quản lý thành phố | [cities.md](docs/cities.md) |
| ⚙️ Settings | Cấu hình hệ thống | [settings.md](docs/settings.md) |
| 🖼️ Home Slides | Slide ảnh trang chủ | [home-slides.md](docs/home-slides.md) |
| 🔄 Use Cases | Các luồng nghiệp vụ phổ biến | [use-cases.md](docs/use-cases.md) |
