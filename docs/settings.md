# ⚙️ Setting APIs

### Setting Response Object

```json
{
  "key": "site_name",
  "value": "Localizy",
  "category": "general",
  "description": "Tên website"
}
```

### WebsiteConfig Response Object

```json
{
  "siteName": "Localizy",
  "siteDescription": "...",
  "logoUrl": "/uploads/logo.png",
  "primaryColor": "#1976D2"
}
```

---

## 1. Lấy cấu hình website

```http
GET /api/settings/website-config
```

**Authorization:** Public (không cần token)

**Response:** `200 OK` - WebsiteConfig object

---

## 2. Lấy tất cả settings

```http
GET /api/settings?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Setting objects

---

## 3. Lấy settings theo category

```http
GET /api/settings/category/{category}?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Path Parameters:**
- `category`: Tên category (VD: `general`, `parking`, `payment`)

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Setting objects

---

## 4. Lấy setting theo key

```http
GET /api/settings/{key}
```

**Authorization:** Admin

**Path Parameters:**
- `key`: Key của setting (VD: `site_name`)

**Response:** `200 OK` - Setting object

**Errors:**
- `404` - Setting không tồn tại

---

## 5. Cập nhật setting

```http
PUT /api/settings/{key}
```

**Authorization:** Admin

**Path Parameters:**
- `key`: Key của setting cần cập nhật

**Request Body:**
```json
{
  "value": "Localizy Platform",
  "description": "Mô tả mới (optional)"
}
```

**Response:** `200 OK` - Setting object đã cập nhật

**Errors:**
- `404` - Setting không tồn tại
