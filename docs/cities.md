# 🏙️ City APIs

### City Response Object

```json
{
  "id": "3fa85f64-...",
  "name": "Hà Nội",
  "code": "HAN",
  "description": "Thủ đô Việt Nam",
  "isActive": true,
  "totalAddresses": 150,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": null
}
```

> **Mã thành phố (`code`)** phải đúng **3 ký tự** (ví dụ: `HAN`, `HCM`, `DAN`). Đây là prefix dùng để sinh mã địa chỉ tự động.

### Danh sách thành phố mặc định

| Thành phố | `code` |
|-----------|--------|
| Hà Nội | `HAN` |
| Hồ Chí Minh | `HCM` |
| Đà Nẵng | `DAN` |
| Hải Phòng | `HPH` |
| Cần Thơ | `CTH` |

---

## 1. Thống kê cities

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
    { "id": "3fa85f64-...", "name": "Hà Nội", "code": "HAN", "addressCount": 150 }
  ]
}
```

---

## 2. Tìm kiếm cities

```http
GET /api/cities/search?searchTerm={term}&pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Query Parameters:**
- `searchTerm`: Tìm theo `name` hoặc `code`
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of City objects

---

## 3. Lấy cities đang active

```http
GET /api/cities/active?pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of City objects (chỉ các city có `isActive = true`)

---

## 4. Lấy tất cả cities

```http
GET /api/cities?pageNumber={n}&pageSize={n}
```

**Authorization:** Public

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of City objects

---

## 5. Lấy city theo ID

```http
GET /api/cities/{id}
```

**Authorization:** Public

**Response:** `200 OK` - City object

**Errors:**
- `404` - City không tồn tại

---

## 6. Lấy city theo code

```http
GET /api/cities/code/{code}
```

**Authorization:** Public

**Example:** `GET /api/cities/code/HAN`

**Response:** `200 OK` - City object

**Errors:**
- `404` - City không tồn tại

---

## 7. Tạo city mới

```http
POST /api/cities
```

**Authorization:** Admin

**Request Body:**
```json
{
  "name": "Đà Nẵng",
  "code": "DAN",
  "description": "Thành phố biển miền Trung"
}
```

**Validation:**
- `name`: bắt buộc
- `code`: bắt buộc, đúng **3 ký tự**, tự động chuyển thành chữ hoa, phải là duy nhất

**Response:** `201 Created` - City object

**Errors:**
- `400` - Code đã tồn tại hoặc không đúng 3 ký tự

---

## 8. Cập nhật city

```http
PUT /api/cities/{id}
```

**Authorization:** Admin

**Request Body:** (tất cả fields đều optional)
```json
{
  "name": "Đà Nẵng",
  "code": "DAN",
  "description": "Thành phố biển miền Trung",
  "isActive": true
}
```

**Validation:**
- `code`: nếu có, phải đúng **3 ký tự** và không trùng với city khác

**Response:** `200 OK` - City object đã cập nhật

**Errors:**
- `400` - Code không đúng 3 ký tự hoặc đã tồn tại
- `404` - City không tồn tại

---

## 9. Xóa city

```http
DELETE /api/cities/{id}
```

**Authorization:** Admin

> **Soft Delete:** Bản ghi không bị xóa vật lý. Cột `IsDeleted` được đặt `true` và `DeletedAt` được ghi nhận.

**Response:** `204 No Content`

**Errors:**
- `404` - City không tồn tại

---

## 10. Toggle active/inactive

```http
PATCH /api/cities/{id}/toggle-active
```

**Authorization:** Admin

**Response:** `200 OK` - City object với `isActive` đã được đảo ngược

**Errors:**
- `404` - City không tồn tại
