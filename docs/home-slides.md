# 🖼️ Home Slide APIs

Manages image slides displayed on the homepage.

### Image Rules

Slide images are uploaded through the API (no external URL is accepted):

- Allowed extensions: `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`
- Maximum size: **5MB**
- The original file name is discarded and replaced with a GUID
- Files are stored under the `home-slides` folder and served at `/uploads/home-slides/<guid>.<ext>`

A file that breaks these rules is rejected with `400 Bad Request`.

### HomeSlide Response Object

`imageUrl` is a **relative** path — prepend the API base URL to display it.

```json
{
  "id": "3fa85f64-...",
  "content": "Welcome to Localizy",
  "imageUrl": "/uploads/home-slides/9f3c1e2a-5b7d-4c81-a0f6-2d3e4b5a6c7d.jpg",
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
      "imageUrl": "/uploads/home-slides/9f3c1e2a-5b7d-4c81-a0f6-2d3e4b5a6c7d.jpg",
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
  "imageUrl": "/uploads/home-slides/9f3c1e2a-5b7d-4c81-a0f6-2d3e4b5a6c7d.jpg",
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
| `image` | file | **Yes** | Slide image file (see [Image Rules](#image-rules)) |
| `content` | string | No | Slide content/title, max 1000 chars. May be omitted or sent empty for an image-only slide — it is then stored as an empty string |
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

# Image-only slide (no text)
curl -X POST http://localhost:5088/api/homeslides \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -F "image=@/path/to/slide.jpg"
```

**Response:** `201 Created` - HomeSlide object

**Errors:**
- `400` - Image file is missing (`Image file is required`)
- `400` - Extension not allowed (`Invalid file type. Only images are allowed.`)
- `400` - File larger than 5MB (`File size exceeds 5MB limit.`)

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
| `image` | file | New image (to replace the existing one, see [Image Rules](#image-rules)) |
| `content` | string | New content, max 1000 chars. Send it **empty** to clear the content (image-only slide) |
| `order` | integer | New display order |
| `isActive` | boolean | New active status |

Only the fields sent are changed; the others keep their current value. For `content` the distinction matters: leaving the field out keeps the current text, while sending it with an empty value clears it. When a new image is accepted, the old file is deleted from the server. If the new image is rejected, the old one is kept.

**Response:** `200 OK` - Updated HomeSlide object

**Errors:**
- `400` - Extension not allowed (`Invalid file type. Only images are allowed.`)
- `400` - File larger than 5MB (`File size exceeds 5MB limit.`)
- `404` - Slide not found

---

## 6. Delete a slide

```http
DELETE /api/homeslides/{id}
```

**Authorization:** Admin

> **Soft Delete:** The record is not physically deleted — the `IsDeleted` column is set to `true` and `DeletedAt` is recorded. The image file, however, **is** removed from disk, so a restored record would point to a missing file.

**Response:** `204 No Content`

**Errors:**
- `404` - Slide not found
