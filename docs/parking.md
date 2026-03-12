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
GET /api/parking/my-tickets
```

**Authorization:** Authenticated

**Response:** `200 OK`
```json
[
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
]
```

---

## 6. Lấy tất cả vé (Admin)

```http
GET /api/parking
```

**Authorization:** Admin

**Response:** `200 OK` - Array of Parking Ticket objects

---

## 7. Gia hạn vé đỗ xe

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
