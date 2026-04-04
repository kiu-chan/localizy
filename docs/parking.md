# 🅿️ Parking APIs

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
  "addressId": "b2c3d4e5-...",
  "duration": "4h",
  "startTime": "2024-01-10T10:00:00Z",
  "endTime": "2024-01-10T14:00:00Z",
  "amount": 35000,
  "paymentMethod": "momo",
  "status": "active",
  "paidAt": "2024-01-10T10:00:00Z",
  "userId": "a1b2c3d4-...",
  "createdAt": "2024-01-10T10:00:00Z"
}
```

---

## 1. Tạo vé đỗ xe

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
| `addressId` | Guid | **Có** | ID điểm đỗ xe (Address có `parkingAvailable = true`) |
| `duration` | string | **Có** | `1h` \| `2h` \| `4h` \| `8h` \| `1day` |
| `paymentMethod` | string | **Có** | `momo` \| `zalopay` \| `bank` \| `card` \| `cash` |
| `startTime` | datetime | Không | Thời gian bắt đầu (mặc định: UtcNow) |

**Response:** `201 Created` - Parking Ticket object

**Errors:**
- `400` - Duration không hợp lệ
- `400` - Bãi đỗ xe không chấp nhận đỗ xe
- `400` - Bãi đỗ xe đã đầy (không còn chỗ)

---

## 2. Lấy vé theo ID

```http
GET /api/parking/{id}
```

**Authorization:** Public

**Response:** `200 OK` - Parking Ticket object

**Errors:**
- `404` - Vé không tồn tại

---

## 3. Lấy vé theo Ticket Code

```http
GET /api/parking/ticket/{ticketCode}
```

**Authorization:** Public

**Example:** `GET /api/parking/ticket/PKT12345678`

**Response:** `200 OK` - Parking Ticket object (với trạng thái đã đồng bộ)

**Errors:**
- `404` - Mã vé không tồn tại

---

## 4. Lấy vé mới nhất theo biển số

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

## 5. Lấy vé của user hiện tại

```http
GET /api/parking/my-tickets?pageNumber={n}&pageSize={n}
```

**Authorization:** Authenticated

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK`
```json
{
  "items": [
    {
      "id": "3fa85f64-...",
      "ticketCode": "PKT12345678",
      "licensePlate": "30A-12345",
      "addressId": "b2c3d4e5-...",
      "duration": "4h",
      "startTime": "2024-01-10T10:00:00Z",
      "endTime": "2024-01-10T14:00:00Z",
      "amount": 35000,
      "paymentMethod": "momo",
      "status": "expired",
      "createdAt": "2024-01-10T10:00:00Z"
    }
  ],
  "totalCount": 12,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 1,
  "hasPreviousPage": false,
  "hasNextPage": false
}
```

---

## 6. Lấy tất cả vé (Admin)

```http
GET /api/parking?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Parking Ticket objects

---

## 7. Lọc vé đỗ xe (Admin)

```http
GET /api/parking/filter?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| `status` | string | Lọc theo trạng thái: `active` \| `expired` \| `cancelled` |
| `fromDate` | datetime | Lọc vé tạo từ ngày này (ISO 8601) |
| `toDate` | datetime | Lọc vé tạo đến ngày này (ISO 8601) |
| `addressId` | Guid | Lọc theo điểm đỗ xe |
| `licensePlate` | string | Tìm kiếm theo biển số (chứa chuỗi) |
| `pageNumber` | int | Trang hiện tại (default: 1) |
| `pageSize` | int | Số bản ghi/trang (default: 20, max: 100) |

**Examples:**
```
GET /api/parking/filter?status=active&pageNumber=1&pageSize=20
GET /api/parking/filter?fromDate=2024-01-01T00:00:00Z&toDate=2024-01-31T23:59:59Z
GET /api/parking/filter?licensePlate=30A&addressId=b2c3d4e5-...
```

**Response:** `200 OK` - PagedResult of Parking Ticket objects

---

## 8. Thống kê đỗ xe (Admin)

```http
GET /api/parking/stats
```

**Authorization:** Admin

**Response:** `200 OK`
```json
{
  "totalTickets": 350,
  "activeTickets": 42,
  "expiredTickets": 295,
  "todayTickets": 18,
  "totalRevenue": 7850000
}
```

| Field | Mô tả |
|-------|-------|
| `totalTickets` | Tổng số vé đã tạo |
| `activeTickets` | Số vé đang còn hiệu lực |
| `expiredTickets` | Số vé đã hết hạn |
| `todayTickets` | Số vé được tạo hôm nay |
| `totalRevenue` | Tổng doanh thu (VND) |

---

## 9. Huỷ vé đỗ xe (Admin)

```http
PATCH /api/parking/{id}/cancel
```

**Authorization:** Admin

**Response:** `200 OK` - Parking Ticket object với `status: "cancelled"`

> Nếu vé đang **Active**, hệ thống tự động giải phóng 1 chỗ đậu tại bãi (`availableParkingSpots++`).

**Errors:**
- `400` - Vé đã bị huỷ trước đó
- `404` - Vé không tồn tại

---

## 10. Gia hạn vé đỗ xe

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
