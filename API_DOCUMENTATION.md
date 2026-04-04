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

## 📄 Pagination

Tất cả các API trả về danh sách đều hỗ trợ phân trang qua query parameters.

### Query Parameters

| Tham số | Kiểu | Mặc định | Tối đa | Mô tả |
|---------|------|----------|--------|-------|
| `pageNumber` | int | `1` | - | Số trang (bắt đầu từ 1) |
| `pageSize` | int | `20` | `100` | Số bản ghi mỗi trang |

**Ví dụ:**
```
GET /api/addresses?pageNumber=2&pageSize=10
GET /api/users?pageNumber=1&pageSize=50
GET /api/validations/search?searchTerm=abc&pageNumber=1&pageSize=20
```

### Paged Response Format

Tất cả list endpoints trả về định dạng `PagedResult<T>`:

```json
{
  "items": [ ... ],
  "totalCount": 150,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 8,
  "hasPreviousPage": false,
  "hasNextPage": true
}
```

| Field | Mô tả |
|-------|-------|
| `items` | Danh sách bản ghi của trang hiện tại |
| `totalCount` | Tổng số bản ghi (không phân trang) |
| `pageNumber` | Trang hiện tại |
| `pageSize` | Số bản ghi mỗi trang |
| `totalPages` | Tổng số trang |
| `hasPreviousPage` | Còn trang trước không |
| `hasNextPage` | Còn trang sau không |

> **Lưu ý:** Endpoint `GET /api/addresses/coordinates` không phân trang vì trả về toàn bộ tọa độ để hiển thị bản đồ.

---

## 🗑️ Soft Delete

Hệ thống sử dụng **xóa mềm (soft delete)** cho tất cả các bảng dữ liệu. Khi gọi API xóa:

- Bản ghi **không bị xóa vật lý** khỏi cơ sở dữ liệu.
- Cột `IsDeleted` được đặt thành `true`.
- Cột `DeletedAt` được ghi nhận thời điểm xóa (UTC).
- Tất cả các API `GET` sẽ **tự động lọc** bản ghi đã xóa — client không bao giờ thấy dữ liệu đã xóa.

### Các bảng áp dụng Soft Delete

`AddressCodes`, `Cities`, `HomeSlides`, `ParkingTickets`, `Projects`, `Settings`, `Translations`, `Users`, `Validations`

---

## 📚 Tài liệu chi tiết

| Module | Mô tả | Link |
|--------|-------|------|
| 🔌 Integration Guide | Hướng dẫn tích hợp cho Web & Mobile App | [integration-guide.md](docs/integration-guide.md) |
| 🔑 Auth | Đăng ký, đăng nhập, quên/đặt lại mật khẩu | [auth.md](docs/auth.md) |
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
| 📈 Statistics | Thống kê & phân tích dữ liệu | [statistics.md](docs/statistics.md) |
| 🔄 Use Cases | Các luồng nghiệp vụ phổ biến | [use-cases.md](docs/use-cases.md) |
