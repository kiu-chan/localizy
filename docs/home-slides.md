# 🖼️ Home Slide APIs

Quản lý các slide ảnh hiển thị trên trang chủ.

### HomeSlide Response Object

```json
{
  "id": "3fa85f64-...",
  "content": "Chào mừng đến với Localizy",
  "imageUrl": "/uploads/home-slides/slide1.jpg",
  "order": 1,
  "isActive": true,
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": null
}
```

---

## 1. Lấy các slide đang active

```http
GET /api/homeslides/active?pageNumber={n}&pageSize={n}
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
      "content": "Chào mừng đến với Localizy",
      "imageUrl": "/uploads/home-slides/slide1.jpg",
      "order": 1,
      "isActive": true,
      "createdAt": "2024-01-10T10:30:00Z",
      "updatedAt": null
    }
  ],
  "totalCount": 5,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 1,
  "hasPreviousPage": false,
  "hasNextPage": false
}
```

---

## 2. Lấy tất cả slides (Admin)

```http
GET /api/homeslides?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of HomeSlide objects (bao gồm cả slide inactive)

---

## 3. Lấy slide theo ID

```http
GET /api/homeslides/{id}
```

**Authorization:** Admin

**Response:** `200 OK`
```json
{
  "id": "3fa85f64-...",
  "content": "Chào mừng đến với Localizy",
  "imageUrl": "/uploads/home-slides/slide1.jpg",
  "order": 1,
  "isActive": true,
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": null
}
```

**Errors:**
- `404` - Slide không tồn tại

---

## 4. Tạo slide mới

```http
POST /api/homeslides
```

**Authorization:** Admin

**Content-Type:** `multipart/form-data`

**Form Fields:**

| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `image` | file | **Có** | File ảnh slide |
| `content` | string | **Có** | Nội dung/tiêu đề slide |
| `order` | integer | Không | Thứ tự hiển thị (default: 0) |
| `isActive` | boolean | Không | Hiển thị hay không (default: true) |

**cURL Example:**
```bash
curl -X POST http://localhost:5088/api/homeslides \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -F "image=@/path/to/slide.jpg" \
  -F "content=Chào mừng đến với Localizy" \
  -F "order=1" \
  -F "isActive=true"
```

**Response:** `201 Created` - HomeSlide object

**Errors:**
- `400` - Thiếu file ảnh

---

## 5. Cập nhật slide

```http
PUT /api/homeslides/{id}
```

**Authorization:** Admin

**Content-Type:** `multipart/form-data`

**Form Fields:** (tất cả đều optional)

| Field | Type | Mô tả |
|-------|------|-------|
| `image` | file | Ảnh mới (nếu muốn thay ảnh) |
| `content` | string | Nội dung mới |
| `order` | integer | Thứ tự mới |
| `isActive` | boolean | Trạng thái mới |

**Response:** `200 OK` - HomeSlide object đã cập nhật

**Errors:**
- `404` - Slide không tồn tại

---

## 6. Xóa slide

```http
DELETE /api/homeslides/{id}
```

**Authorization:** Admin

> **Soft Delete:** Bản ghi không bị xóa vật lý. Cột `IsDeleted` được đặt `true` và `DeletedAt` được ghi nhận. File ảnh liên quan cũng bị xóa khỏi server (file vật lý vẫn được xóa).

**Response:** `204 No Content`

**Errors:**
- `404` - Slide không tồn tại
