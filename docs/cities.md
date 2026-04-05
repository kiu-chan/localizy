# 🏙️ City APIs

### City Response Object

```json
{
  "id": "3fa85f64-...",
  "name": "Ha Noi",
  "code": "HAN",
  "description": "Capital of Vietnam",
  "isActive": true,
  "totalAddresses": 150,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": null
}
```

> **City code (`code`)** must be exactly **3 characters** (e.g. `HAN`, `HCM`, `DAN`). This is the prefix used to auto-generate address codes.

### Default Cities

| City | `code` |
|------|--------|
| Ha Noi | `HAN` |
| Ho Chi Minh | `HCM` |
| Da Nang | `DAN` |
| Hai Phong | `HPH` |
| Can Tho | `CTH` |

---

## 1. City statistics

```http
GET /api/cities/stats
```

**Authorization:** Admin

**Response:** `200 OK`
```json
{
  "totalCities": 10,
  "activeCities": 8,
  "inactiveCities": 2,
  "totalAddresses": 500,
  "topCities": [
    { "id": "3fa85f64-...", "name": "Ha Noi", "code": "HAN", "addressCount": 150 }
  ]
}
```

---

## 2. Search cities

```http
GET /api/cities/search?searchTerm={term}&pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Query Parameters:**
- `searchTerm`: Search by `name` or `code`
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of City objects

---

## 3. Get active cities

```http
GET /api/cities/active?pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of City objects (only cities with `isActive = true`)

---

## 4. Get all cities

```http
GET /api/cities?pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of City objects

---

## 5. Get city by ID

```http
GET /api/cities/{id}
```

**Authorization:** Public

**Response:** `200 OK` - City object

**Errors:**
- `404` - City not found

---

## 6. Get city by code

```http
GET /api/cities/code/{code}
```

**Authorization:** Public

**Example:** `GET /api/cities/code/HAN`

**Response:** `200 OK` - City object

**Errors:**
- `404` - City not found

---

## 7. Create a city

```http
POST /api/cities
```

**Authorization:** Admin

**Request Body:**
```json
{
  "name": "Da Nang",
  "code": "DAN",
  "description": "Coastal city in Central Vietnam"
}
```

**Validation:**
- `name`: required
- `code`: required, exactly **3 characters**, automatically uppercased, must be unique

**Response:** `201 Created` - City object

**Errors:**
- `400` - Code already exists or is not exactly 3 characters

---

## 8. Update a city

```http
PUT /api/cities/{id}
```

**Authorization:** Admin

**Request Body:** (all fields are optional)
```json
{
  "name": "Da Nang",
  "code": "DAN",
  "description": "Coastal city in Central Vietnam",
  "isActive": true
}
```

**Validation:**
- `code`: if provided, must be exactly **3 characters** and not duplicate another city

**Response:** `200 OK` - Updated City object

**Errors:**
- `400` - Code is not 3 characters or already exists
- `404` - City not found

---

## 9. Delete a city

```http
DELETE /api/cities/{id}
```

**Authorization:** Admin

> **Soft Delete:** The record is not physically deleted. The `IsDeleted` column is set to `true` and `DeletedAt` is recorded.

**Response:** `204 No Content`

**Errors:**
- `404` - City not found

---

## 10. Toggle active/inactive

```http
PATCH /api/cities/{id}/toggle-active
```

**Authorization:** Admin

**Response:** `200 OK` - City object with `isActive` toggled

**Errors:**
- `404` - City not found
