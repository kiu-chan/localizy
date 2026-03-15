# 🏢 Business APIs

Quản lý tài khoản con (SubAccount) và xem địa chỉ theo nhóm doanh nghiệp.

> **Lưu ý:** Tài khoản `SubAccount` có đầy đủ quyền thêm địa chỉ như `Business` (status tự động = `Reviewed`).

---

## 1. Trang chủ doanh nghiệp (Dashboard)

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

## 2. Lấy danh sách tài khoản con

```http
GET /api/business/sub-accounts?pageNumber={n}&pageSize={n}
```

**Authorization:** Business

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK`
```json
{
  "items": [
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
  ],
  "totalCount": 3,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 1,
  "hasPreviousPage": false,
  "hasNextPage": false
}
```

---

## 3. Tạo tài khoản con mới

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

## 4. Cập nhật tài khoản con

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

## 5. Lấy tất cả địa chỉ của nhóm doanh nghiệp

Trả về địa chỉ của **cả doanh nghiệp lẫn tất cả tài khoản con**.

```http
GET /api/business/addresses?pageNumber={n}&pageSize={n}
```

**Authorization:** Business, SubAccount

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Hành vi theo role:**
| Role | Kết quả trả về |
|------|----------------|
| `Business` | Địa chỉ của business + tất cả sub-accounts |
| `SubAccount` | Địa chỉ của parent business + tất cả sub-accounts cùng cấp (bao gồm bản thân) |

**Response:** `200 OK` - PagedResult of Address objects

```json
{
  "items": [
    {
      "id": "3fa85f64-...",
      "code": "HANX9K21",
      "name": "Văn phòng chính",
      "userId": "3fa85f64-...",
      "userName": "Công ty ABC",
      "status": "Reviewed"
    },
    {
      "id": "a1b2c3d4-...",
      "code": "HCMB3P54",
      "name": "Chi nhánh Q.1",
      "userId": "a1b2c3d4-...",
      "userName": "Nhân viên A",
      "status": "Reviewed"
    }
  ],
  "totalCount": 24,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 2,
  "hasPreviousPage": false,
  "hasNextPage": true
}
```

---

## 6. Lấy địa chỉ do tài khoản hiện tại thêm

Chỉ trả về địa chỉ mà **chính tài khoản đang đăng nhập** đã thêm (không bao gồm sub-accounts hay parent).

```http
GET /api/business/addresses/mine?pageNumber={n}&pageSize={n}
```

**Authorization:** Business, SubAccount

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Address objects
```json
{
  "items": [
    {
      "id": "3fa85f64-...",
      "code": "HANX9K21",
      "name": "Văn phòng chính",
      "fullAddress": "Tầng 5, 99 Láng Hạ, Q. Đống Đa, Hà Nội",
      "latitude": 21.02,
      "longitude": 105.85,
      "status": "Reviewed",
      "isVerified": true,
      "userId": "3fa85f64-...",
      "userName": "Công ty ABC",
      "createdAt": "2024-01-10T10:30:00Z"
    }
  ],
  "totalCount": 10,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 1,
  "hasPreviousPage": false,
  "hasNextPage": false
}
```
