# 📍 Address APIs

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
  "userId": "a1b2c3d4-...",
  "userName": "Nguyen Van A",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "cityId": "d4e5f6a7-5717-4562-b3fc-2c963f66afa6",
  "cityName": "Hà Nội",
  "status": "Reviewed",
  "isVerified": true,
  "validatorId": "b2c3d4e5-...",
  "validatorName": "Tran Van B",
  "comments": "Đã xác minh tại thực địa",
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
> - Ví dụ: City có `code = "HAN"` → `code = "HANA3K92"`

---

## 1. Thống kê địa chỉ

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

## 2. Tìm kiếm địa chỉ (simple)

```http
GET /api/addresses/search?searchTerm={term}&pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Query Parameters:**
- `searchTerm` (string): Tìm theo `code`, `name`, `fullAddress` hoặc `cityName`
- `pageNumber` (int, default: 1): Số trang
- `pageSize` (int, default: 20, max: 100): Số bản ghi mỗi trang

**Response:** `200 OK`
```json
{
  "items": [
    {
      "id": "3fa85f64-...",
      "code": "HANA3K92",
      "name": "Nhà hàng Phở Bắc",
      "fullAddress": "123 Nguyễn Trãi, P. Thượng Đình, Q. Thanh Xuân",
      "latitude": 21.0285,
      "longitude": 105.8542,
      "cityId": "d4e5f6a7-...",
      "cityName": "Hà Nội",
      "status": "Reviewed",
      "isVerified": true,
      "parkingAvailable": false,
      "totalParkingSpots": 0,
      "availableSpots": 0,
      "pricePerHour": 0
    }
  ],
  "totalCount": 42,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 3,
  "hasPreviousPage": false,
  "hasNextPage": true
}
```

---

## 3. Lọc theo status

```http
GET /api/addresses/filter/status/{status}?pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Path Parameters:**
- `status`: `Pending` | `Reviewed` | `Rejected`

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Address objects

---

## 4. Lấy địa chỉ theo user

```http
GET /api/addresses/user/{userId}?pageNumber={n}&pageSize={n}
```

**Authorization:** Authenticated

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Address objects

---

## 5. Lấy địa chỉ của user hiện tại

```http
GET /api/addresses/my-addresses?pageNumber={n}&pageSize={n}
```

**Authorization:** Authenticated

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Address simple objects

---

## 6. Lấy tất cả địa chỉ

```http
GET /api/addresses?pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Address objects

---

## 7. Lấy tọa độ tất cả địa chỉ

```http
GET /api/addresses/coordinates
```

**Authorization:** Public

**Response:** `200 OK`
```json
[
  {
    "id": "3fa85f64-...",
    "code": "HANA3K92",
    "coordinates": {
      "lat": 21.0285,
      "lng": 105.8542
    }
  }
]
```

---

## 8. Lấy chi tiết địa chỉ

```http
GET /api/addresses/detail/{id}
```

**Authorization:** Public

**Response:** `200 OK` - Address object đầy đủ

---

## 9. Lấy địa chỉ theo ID

```http
GET /api/addresses/{id}
```

**Authorization:** Public

**Response:** `200 OK` - Address object

**Errors:**
- `404` - Địa chỉ không tồn tại

---

## 10. Thêm địa chỉ mới

```http
POST /api/addresses
```

**Authorization:** Authenticated

> **Mã địa chỉ được tự động sinh** — không cần truyền `code`. Hệ thống lấy `code` của thành phố (3 ký tự) từ `cityId` rồi ghép thêm 5 ký tự ngẫu nhiên, tạo thành mã 8 ký tự đảm bảo không trùng lặp.

**Request Body:**
```json
{
  "cityId": "d4e5f6a7-5717-4562-b3fc-2c963f66afa6",
  "name": "Nhà hàng Phở Bắc",
  "fullAddress": "123 Nguyễn Trãi, P. Thượng Đình, Q. Thanh Xuân, Hà Nội",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "parkingAvailable": false,
  "totalParkingSpots": 0,
  "pricePerHour": 0
}
```

**Validation:**
- `cityId`: bắt buộc, phải là ID của thành phố hợp lệ trong hệ thống (xem [cities.md](cities.md))

**Quy tắc theo role:**
| Role | Status sau khi tạo |
|------|--------------------|
| `User` | `Pending` - cần xác minh |
| `Admin` | `Pending` - cần xác minh |
| `Business` | `Reviewed` - không cần xác minh |
| `SubAccount` | `Reviewed` - không cần xác minh |

**Response:** `201 Created` - Address object (bao gồm `code` đã được sinh tự động)

**Errors:**
- `400` - `cityId` không hợp lệ hoặc thành phố không tồn tại

---

## 11. Cập nhật địa chỉ

```http
PUT /api/addresses/{id}
```

**Authorization:** Authenticated

**Request Body:** (tất cả fields đều optional)
```json
{
  "name": "Nhà hàng Phở Bắc (đã đổi tên)",
  "fullAddress": "456 Lê Duẩn, P. Điện Biên, Q. Ba Đình, Hà Nội",
  "latitude": 21.0290,
  "longitude": 105.8550,
  "cityId": "d4e5f6a7-5717-4562-b3fc-2c963f66afa6",
  "validatorId": "b2c3d4e5-...",
  "comments": "Ghi chú cập nhật",
  "parkingAvailable": true,
  "totalParkingSpots": 20,
  "pricePerHour": 10000
}
```

> **Lưu ý:** `code` không thể cập nhật — mã địa chỉ được sinh một lần tại thời điểm tạo và cố định.

**Response:** `200 OK` - Address object

---

## 12. Xóa địa chỉ

```http
DELETE /api/addresses/{id}
```

**Authorization:** Admin

> **Soft Delete:** Bản ghi không bị xóa vật lý. Cột `IsDeleted` được đặt `true` và `DeletedAt` được ghi nhận. Địa chỉ sẽ không còn xuất hiện trong bất kỳ API nào.

**Response:** `204 No Content`

---

## 13. Xác minh địa chỉ (Review)

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

## 14. Từ chối địa chỉ

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

## 15. Lấy danh sách bãi đỗ xe

Trả về các địa chỉ có `parkingAvailable = true` và `status = Reviewed`. `availableSpots` được tính động theo số vé đang active.

```http
GET /api/addresses/parking-zones?pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK`
```json
{
  "items": [
    {
      "id": "3fa85f64-...",
      "code": "HANP7M21",
      "name": "Bãi đỗ xe Trần Duy Hưng",
      "fullAddress": "123 Trần Duy Hưng, Q. Cầu Giấy, Hà Nội",
      "latitude": 21.0075,
      "longitude": 105.7989,
      "cityId": "d4e5f6a7-...",
      "cityName": "Hà Nội",
      "status": "Reviewed",
      "isVerified": true,
      "parkingAvailable": true,
      "totalParkingSpots": 50,
      "availableSpots": 35,
      "pricePerHour": 10000
    }
  ],
  "totalCount": 8,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 1,
  "hasPreviousPage": false,
  "hasNextPage": false
}
```
