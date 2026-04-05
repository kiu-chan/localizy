# 🅿️ Parking APIs

Manages parking tickets. Parking locations are addresses with `parkingAvailable = true` and `status = Reviewed`.

### Parking Ticket Status

| Status | Description |
|--------|-------------|
| `Active` | Ticket is currently valid |
| `Expired` | Ticket has expired |
| `Cancelled` | Ticket has been cancelled |

### Duration & Price

| Duration | Price (VND) |
|----------|-------------|
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

## 1. Create a parking ticket

```http
POST /api/parking
```

**Authorization:** Public (login not required)

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

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `licensePlate` | string | **Yes** | Vehicle license plate |
| `addressId` | Guid | **Yes** | Parking location ID (Address with `parkingAvailable = true`) |
| `duration` | string | **Yes** | `1h` \| `2h` \| `4h` \| `8h` \| `1day` |
| `paymentMethod` | string | **Yes** | `momo` \| `zalopay` \| `bank` \| `card` \| `cash` |
| `startTime` | datetime | No | Start time (default: UtcNow) |

**Response:** `201 Created` - Parking Ticket object

**Errors:**
- `400` - Invalid duration
- `400` - Parking location does not accept parking
- `400` - Parking lot is full (no available spots)

---

## 2. Get ticket by ID

```http
GET /api/parking/{id}
```

**Authorization:** Public

**Response:** `200 OK` - Parking Ticket object

**Errors:**
- `404` - Ticket not found

---

## 3. Get ticket by Ticket Code

```http
GET /api/parking/ticket/{ticketCode}
```

**Authorization:** Public

**Example:** `GET /api/parking/ticket/PKT12345678`

**Response:** `200 OK` - Parking Ticket object (with synchronized status)

**Errors:**
- `404` - Ticket code not found

---

## 4. Get latest ticket by license plate

Returns the most recent ticket for a given license plate (used for payment check page).

```http
GET /api/parking/license/{licensePlate}
```

**Authorization:** Public

**Example:** `GET /api/parking/license/30A-12345`

**Response:** `200 OK` - Parking Ticket object

**Errors:**
- `404` - No ticket found for this license plate

---

## 5. Get current user's tickets

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

## 6. Get all tickets (Admin)

```http
GET /api/parking?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Parking Ticket objects

---

## 7. Filter tickets (Admin)

```http
GET /api/parking/filter?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | Filter by status: `active` \| `expired` \| `cancelled` |
| `fromDate` | datetime | Filter tickets created from this date (ISO 8601) |
| `toDate` | datetime | Filter tickets created up to this date (ISO 8601) |
| `addressId` | Guid | Filter by parking location |
| `licensePlate` | string | Search by license plate (contains) |
| `pageNumber` | int | Current page (default: 1) |
| `pageSize` | int | Records per page (default: 20, max: 100) |

**Examples:**
```
GET /api/parking/filter?status=active&pageNumber=1&pageSize=20
GET /api/parking/filter?fromDate=2024-01-01T00:00:00Z&toDate=2024-01-31T23:59:59Z
GET /api/parking/filter?licensePlate=30A&addressId=b2c3d4e5-...
```

**Response:** `200 OK` - PagedResult of Parking Ticket objects

---

## 8. Parking statistics (Admin)

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

| Field | Description |
|-------|-------------|
| `totalTickets` | Total tickets created |
| `activeTickets` | Currently valid tickets |
| `expiredTickets` | Expired tickets |
| `todayTickets` | Tickets created today |
| `totalRevenue` | Total revenue (VND) |

---

## 9. Cancel a parking ticket (Admin)

```http
PATCH /api/parking/{id}/cancel
```

**Authorization:** Admin

**Response:** `200 OK` - Parking Ticket object with `status: "cancelled"`

> If the ticket is **Active**, the system automatically frees one parking spot at the location (`availableParkingSpots++`).

**Errors:**
- `400` - Ticket has already been cancelled
- `404` - Ticket not found

---

## 10. Extend a parking ticket

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

**Response:** `200 OK` - Parking Ticket object with updated `endTime`

**Errors:**
- `400` - Cannot extend an expired or cancelled ticket
- `404` - Ticket not found
