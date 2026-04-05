# 🖼️ Home Slide APIs

Manages image slides displayed on the homepage.

### HomeSlide Response Object

```json
{
  "id": "3fa85f64-...",
  "content": "Welcome to Localizy",
  "imageUrl": "/uploads/home-slides/slide1.jpg",
  "order": 1,
  "isActive": true,
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": null
}
```

---

## 1. Get active slides

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
      "content": "Welcome to Localizy",
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

## 2. Get all slides (Admin)

```http
GET /api/homeslides?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of HomeSlide objects (includes inactive slides)

---

## 3. Get slide by ID

```http
GET /api/homeslides/{id}
```

**Authorization:** Admin

**Response:** `200 OK`
```json
{
  "id": "3fa85f64-...",
  "content": "Welcome to Localizy",
  "imageUrl": "/uploads/home-slides/slide1.jpg",
  "order": 1,
  "isActive": true,
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": null
}
```

**Errors:**
- `404` - Slide not found

---

## 4. Create a slide

```http
POST /api/homeslides
```

**Authorization:** Admin

**Content-Type:** `multipart/form-data`

**Form Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | file | **Yes** | Slide image file |
| `content` | string | **Yes** | Slide content/title |
| `order` | integer | No | Display order (default: 0) |
| `isActive` | boolean | No | Whether to display (default: true) |

**cURL Example:**
```bash
curl -X POST http://localhost:5088/api/homeslides \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -F "image=@/path/to/slide.jpg" \
  -F "content=Welcome to Localizy" \
  -F "order=1" \
  -F "isActive=true"
```

**Response:** `201 Created` - HomeSlide object

**Errors:**
- `400` - Image file is missing

---

## 5. Update a slide

```http
PUT /api/homeslides/{id}
```

**Authorization:** Admin

**Content-Type:** `multipart/form-data`

**Form Fields:** (all optional)

| Field | Type | Description |
|-------|------|-------------|
| `image` | file | New image (to replace the existing one) |
| `content` | string | New content |
| `order` | integer | New display order |
| `isActive` | boolean | New active status |

**Response:** `200 OK` - Updated HomeSlide object

**Errors:**
- `404` - Slide not found

---

## 6. Delete a slide

```http
DELETE /api/homeslides/{id}
```

**Authorization:** Admin

> **Soft Delete:** The record is not physically deleted. The `IsDeleted` column is set to `true` and `DeletedAt` is recorded. The associated image file is also removed from the server (the physical file is still deleted).

**Response:** `204 No Content`

**Errors:**
- `404` - Slide not found
