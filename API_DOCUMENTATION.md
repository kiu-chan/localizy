# Localizy Server - API Documentation

Overview of all API endpoints for Localizy Server.

---

## 🌐 Overview

### Base URL
```
http://localhost:5088/api
```

### Content Type
```
Content-Type: application/json
```

### Date Format
```
ISO 8601: 2024-01-10T10:30:00Z
```

---

## 🔐 Authentication

The API uses **JWT Bearer Token**. Tokens are valid for 24 hours and obtained via the login endpoint.

```
Authorization: Bearer <token>
```

### Authorization Levels

| Level | Description |
|-------|-------------|
| **Public** | No token required |
| **Authenticated** | Valid token required (any role) |
| **Admin** | Admin role only |
| **Validator** | Validator role only |
| **Admin,Validator** | Admin or Validator |
| **Business** | Business role only |
| **Business,SubAccount** | Business or SubAccount |

### User Roles

| Role | Description |
|------|-------------|
| `User` | Regular user — submits address verification requests |
| `Admin` | Administrator — manages the entire system |
| `Validator` | Field validator — verifies addresses on-site |
| `Business` | Business account — adds addresses directly |
| `SubAccount` | Sub-account of a business — adds addresses directly |

---

## ⚠️ Error Handling

```json
{ "message": "Error description here" }
```

| Code | Status | Description |
|------|--------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 204 | No Content | Deleted successfully |
| 400 | Bad Request | Invalid data |
| 401 | Unauthorized | Invalid or expired token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource does not exist |
| 500 | Internal Server Error | Server error |

---

## 📄 Pagination

All list APIs support pagination via query parameters.

### Query Parameters

| Parameter | Type | Default | Max | Description |
|-----------|------|---------|-----|-------------|
| `pageNumber` | int | `1` | - | Page number (starts at 1) |
| `pageSize` | int | `20` | `100` | Records per page |

**Examples:**
```
GET /api/addresses?pageNumber=2&pageSize=10
GET /api/users?pageNumber=1&pageSize=50
GET /api/validations/search?searchTerm=abc&pageNumber=1&pageSize=20
```

### Paged Response Format

All list endpoints return `PagedResult<T>`:

```json
{
  "items": [ ... ],
  "totalCount": 150,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 8,
  "hasPreviousPage": false,
  "hasNextPage": true
}
```

| Field | Description |
|-------|-------------|
| `items` | Records for the current page |
| `totalCount` | Total number of records (unpaginated) |
| `pageNumber` | Current page |
| `pageSize` | Records per page |
| `totalPages` | Total number of pages |
| `hasPreviousPage` | Whether a previous page exists |
| `hasNextPage` | Whether a next page exists |

> **Note:** `GET /api/addresses/coordinates` does not paginate — it returns all coordinates for map display.

---

## 🗑️ Soft Delete

The system uses **soft delete** for all data tables. When a delete API is called:

- Records are **not physically deleted** from the database.
- The `IsDeleted` column is set to `true`.
- The `DeletedAt` column records the deletion timestamp (UTC).
- All `GET` APIs **automatically filter out** deleted records — clients never see deleted data.

### Tables with Soft Delete

`AddressCodes`, `Cities`, `HomeSlides`, `ParkingTickets`, `Projects`, `Settings`, `Translations`, `Users`, `Validations`

---

## 📚 Detailed Documentation

| Module | Description | Link |
|--------|-------------|------|
| 🔌 Integration Guide | Integration guide for Web & Mobile apps | [integration-guide.md](docs/integration-guide.md) |
| 🔑 Auth | Register, login, forgot/reset password, FCM token | [auth.md](docs/auth.md) |
| 📊 Dashboard | Admin & Validator overview | [admin-dashboard.md](docs/admin-dashboard.md) |
| 👥 Users | User management | [users.md](docs/users.md) |
| 🏢 Business | Business accounts & sub-accounts | [business.md](docs/business.md) |
| 📍 Addresses | Address management | [addresses.md](docs/addresses.md) |
| ✅ Validations | Address verification requests | [validations.md](docs/validations.md) |
| 🅿️ Parking | Parking tickets | [parking.md](docs/parking.md) |
| 🔄 Transactions | Combined transaction history | [transactions.md](docs/transactions.md) |
| 🏙️ Cities | City management | [cities.md](docs/cities.md) |
| ⚙️ Settings | System configuration | [settings.md](docs/settings.md) |
| 🖼️ Home Slides | Homepage image slides | [home-slides.md](docs/home-slides.md) |
| 📈 Statistics | Statistics & analytics | [statistics.md](docs/statistics.md) |
| 🔄 Use Cases | Common business flows | [use-cases.md](docs/use-cases.md) |
