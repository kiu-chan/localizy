# 📍 Address APIs

Manages the address list (`AddressCodes`).

### Address Status

| Status | Description |
|--------|-------------|
| `Pending` | Awaiting verification (submitted by a regular User) |
| `Reviewed` | Verified and accepted |
| `Rejected` | Rejected |

> **Note:** Addresses added by Business and SubAccount accounts have `Reviewed` status immediately — no verification required.

### Address Response Object

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "code": "HANA3K92",
  "name": "Pho Bac Restaurant",
  "fullAddress": "123 Nguyen Trai, Thuong Dinh Ward, Thanh Xuan District, Hanoi",
  "userId": "a1b2c3d4-...",
  "userName": "Nguyen Van A",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "cityId": "d4e5f6a7-5717-4562-b3fc-2c963f66afa6",
  "cityName": "Ha Noi",
  "status": "Reviewed",
  "isVerified": true,
  "validatorId": "b2c3d4e5-...",
  "validatorName": "Tran Van B",
  "comments": "Verified on-site",
  "parkingAvailable": true,
  "totalParkingSpots": 20,
  "availableSpots": 15,
  "pricePerHour": 10000,
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": "2024-01-11T08:00:00Z"
}
```

> **Note on address code (`code`):**
> - **Automatically generated** by the system — not entered by users.
> - Format: `{CityCode}{5 random characters}` — **8 characters** total (`A-Z`, `0-9`).
> - Example: City with `code = "HAN"` → address `code = "HANA3K92"`

---

## 1. Address statistics

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

## 2. Search addresses

```http
GET /api/addresses/search?searchTerm={term}&pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Query Parameters:**
- `searchTerm` (string): Search by `code`, `name`, `fullAddress`, or `cityName`
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK`
```json
{
  "items": [
    {
      "id": "3fa85f64-...",
      "code": "HANA3K92",
      "name": "Pho Bac Restaurant",
      "fullAddress": "123 Nguyen Trai, Thuong Dinh Ward, Thanh Xuan",
      "latitude": 21.0285,
      "longitude": 105.8542,
      "cityId": "d4e5f6a7-...",
      "cityName": "Ha Noi",
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

## 3. Filter by status

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

## 4. Get addresses by user

```http
GET /api/addresses/user/{userId}?pageNumber={n}&pageSize={n}
```

**Authorization:** Authenticated

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Address objects

---

## 5. Get current user's addresses

```http
GET /api/addresses/my-addresses?pageNumber={n}&pageSize={n}
```

**Authorization:** Authenticated

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Address simple objects

---

## 6. Get all addresses

```http
GET /api/addresses?pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Address objects

---

## 7. Get all address coordinates

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

## 8. Get address detail

```http
GET /api/addresses/detail/{id}
```

**Authorization:** Public

**Response:** `200 OK` - Full Address object

---

## 9. Get address by ID

```http
GET /api/addresses/{id}
```

**Authorization:** Public

**Response:** `200 OK` - Address object

**Errors:**
- `404` - Address not found

---

## 10. Create a new address

```http
POST /api/addresses
```

**Authorization:** Authenticated

> **Address code is auto-generated** — do not pass `code`. The system takes the city `code` (3 characters) from `cityId` and appends 5 random characters to create a unique 8-character code.

**Request Body:**
```json
{
  "cityId": "d4e5f6a7-5717-4562-b3fc-2c963f66afa6",
  "name": "Pho Bac Restaurant",
  "fullAddress": "123 Nguyen Trai, Thuong Dinh Ward, Thanh Xuan District, Hanoi",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "parkingAvailable": false,
  "totalParkingSpots": 0,
  "pricePerHour": 0
}
```

**Validation:**
- `cityId`: required, must be a valid city ID in the system (see [cities.md](cities.md))

**Role rules:**
| Role | Status after creation |
|------|-----------------------|
| `User` | `Pending` — requires verification |
| `Admin` | `Pending` — requires verification |
| `Business` | `Reviewed` — no verification needed |
| `SubAccount` | `Reviewed` — no verification needed |

**Response:** `201 Created` - Address object (including the auto-generated `code`)

**Errors:**
- `400` - Invalid `cityId` or city not found

---

## 11. Update address

```http
PUT /api/addresses/{id}
```

**Authorization:** Authenticated

**Request Body:** (all fields are optional)
```json
{
  "name": "Pho Bac Restaurant (renamed)",
  "fullAddress": "456 Le Duan, Dien Bien Ward, Ba Dinh District, Hanoi",
  "latitude": 21.0290,
  "longitude": 105.8550,
  "cityId": "d4e5f6a7-5717-4562-b3fc-2c963f66afa6",
  "validatorId": "b2c3d4e5-...",
  "comments": "Updated note",
  "parkingAvailable": true,
  "totalParkingSpots": 20,
  "pricePerHour": 10000
}
```

> **Note:** `code` cannot be updated — the address code is generated once at creation and is permanent.

**Response:** `200 OK` - Address object

---

## 12. Delete address

```http
DELETE /api/addresses/{id}
```

**Authorization:** Admin

> **Soft Delete:** The record is not physically deleted. The `IsDeleted` column is set to `true` and `DeletedAt` is recorded. The address will no longer appear in any API.

**Response:** `204 No Content`

---

## 13. Review address

```http
POST /api/addresses/{id}/review
```

**Authorization:** Admin, Validator

**Request Body:**
```json
{
  "comments": "Verified on-site, address is valid"
}
```

**Response:** `200 OK` - Address object with `status: "Reviewed"`

---

## 14. Reject address

```http
POST /api/addresses/{id}/reject
```

**Authorization:** Admin, Validator

**Request Body:**
```json
{
  "comments": "Address does not exist at the provided coordinates"
}
```

**Response:** `200 OK` - Address object with `status: "Rejected"`

---

## 15. Get parking zones

Returns addresses with `parkingAvailable = true` and `status = Reviewed`. `availableSpots` is calculated dynamically based on active tickets.

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
      "name": "Tran Duy Hung Parking",
      "fullAddress": "123 Tran Duy Hung, Cau Giay District, Hanoi",
      "latitude": 21.0075,
      "longitude": 105.7989,
      "cityId": "d4e5f6a7-...",
      "cityName": "Ha Noi",
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
