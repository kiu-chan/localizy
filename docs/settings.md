# ⚙️ Setting APIs

### Setting Response Object

```json
{
  "key": "site_name",
  "value": "Localizy",
  "category": "general",
  "description": "Website name"
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

## 1. Get website configuration

```http
GET /api/settings/website-config
```

**Authorization:** Public (no token required)

**Response:** `200 OK` - WebsiteConfig object

---

## 2. Get all settings

```http
GET /api/settings?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Setting objects

---

## 3. Get settings by category

```http
GET /api/settings/category/{category}?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Path Parameters:**
- `category`: Category name (e.g. `general`, `parking`, `payment`)

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Setting objects

---

## 4. Get setting by key

```http
GET /api/settings/{key}
```

**Authorization:** Admin

**Path Parameters:**
- `key`: Setting key (e.g. `site_name`)

**Response:** `200 OK` - Setting object

**Errors:**
- `404` - Setting not found

---

## 5. Update a setting

```http
PUT /api/settings/{key}
```

**Authorization:** Admin

**Path Parameters:**
- `key`: Key of the setting to update

**Request Body:**
```json
{
  "value": "Localizy Platform",
  "description": "New description (optional)"
}
```

**Response:** `200 OK` - Updated Setting object

**Errors:**
- `404` - Setting not found
