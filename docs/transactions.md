# 🔄 Transaction APIs

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

## 1. Lấy lịch sử giao dịch của user hiện tại

Trả về tổng hợp vé đỗ xe + yêu cầu xác minh địa chỉ, sắp xếp theo thời gian mới nhất.

```http
GET /api/transactions/my-transactions
```

**Authorization:** Authenticated

**Response:** `200 OK`
```json
[
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
  },
  {
    "id": "3fa85f64-...",
    "type": "verification",
    "title": "Address Verification",
    "location": "Nhà hàng Phở Bắc",
    "amount": 150000,
    "status": "pending",
    "date": "2024-01-09T08:00:00Z",
    "paymentMethod": "cash"
  }
]
```

> Kết quả được sắp xếp theo `date` giảm dần (mới nhất trước).
