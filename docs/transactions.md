# 🔄 Transaction APIs

Lịch sử giao dịch tổng hợp (đỗ xe + xác minh địa chỉ).

### Transaction Response Object

```json
{
  "id": "PKT12345678",
  "type": "parking",
  "title": "Parking Payment",
  "location": "b2c3d4e5-...",
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
| `location` | Parking: `addressId` (Guid) của điểm đỗ xe; Verification: tọa độ `"Lat: x, Lng: y"` |
| `licensePlate` | Chỉ có khi `type = parking` |
| `duration` | Chỉ có khi `type = parking` |

**Mapping trạng thái:**
- Parking: `active/expired` → `success`, `cancelled` → `failed`
- Verification: `verified` → `success`, `rejected` → `failed`, còn lại → `pending`

---

## 1. Lấy lịch sử giao dịch của user hiện tại

Trả về tổng hợp vé đỗ xe + yêu cầu xác minh địa chỉ, sắp xếp theo thời gian mới nhất.

```http
GET /api/transactions/my-transactions?pageNumber={n}&pageSize={n}
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
      "id": "PKT12345678",
      "type": "parking",
      "title": "Parking Payment",
      "location": "b2c3d4e5-...",
      "licensePlate": "30A-12345",
      "amount": 35000,
      "status": "success",
      "date": "2024-01-10T10:00:00Z",
      "paymentMethod": "momo",
      "duration": "4h"
    },
    {
      "id": "3fa85f64-...",
      "type": "verification",
      "title": "Address Verification",
      "location": "Lat: 21.0285, Lng: 105.8542",
      "amount": 150000,
      "status": "pending",
      "date": "2024-01-09T08:00:00Z",
      "paymentMethod": "cash"
    }
  ],
  "totalCount": 25,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 2,
  "hasPreviousPage": false,
  "hasNextPage": true
}
```

> Kết quả được sắp xếp theo `date` giảm dần (mới nhất trước).
