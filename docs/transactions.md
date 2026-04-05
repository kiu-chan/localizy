# 🔄 Transaction APIs

Combined transaction history (parking + address verification).

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

| Field | Description |
|-------|-------------|
| `type` | `parking` or `verification` |
| `status` | `success` \| `failed` \| `pending` |
| `location` | Parking: `addressId` (Guid) of the parking location; Verification: coordinates `"Lat: x, Lng: y"` |
| `licensePlate` | Only present when `type = parking` |
| `duration` | Only present when `type = parking` |

**Status mapping:**
- Parking: `active/expired` → `success`, `cancelled` → `failed`
- Verification: `verified` → `success`, `rejected` → `failed`, others → `pending`

---

## 1. Get current user's transaction history

Returns a combined list of parking tickets + address verification requests, sorted by newest first.

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

> Results are sorted by `date` descending (newest first).
