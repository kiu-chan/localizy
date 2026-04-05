# 🏢 Business APIs

Manages sub-accounts and views addresses grouped by business.

> **Note:** `SubAccount` accounts have full permission to add addresses like `Business` (status is automatically `Reviewed`).

---

## 1. Business Dashboard

Returns an overview and recent activity for the business group.

```http
GET /api/business/dashboard
```

**Authorization:** Business, SubAccount

**Behavior by role:**
| Role | Data returned |
|------|---------------|
| `Business` | Stats for the business + all sub-accounts |
| `SubAccount` | Stats for the entire group (parent business + all sub-accounts) |

**Response:** `200 OK`
```json
{
  "totalLocations": 24,
  "subAccountCount": 8,
  "recentActivities": [
    {
      "type": "LocationAdded",
      "title": "New location added",
      "subtitle": "Coffee Shop",
      "timestamp": "2026-02-27T10:00:00Z",
      "actorName": "Staff A"
    },
    {
      "type": "SubAccountCreated",
      "title": "New sub account created",
      "subtitle": "Manager Account",
      "timestamp": "2026-02-27T07:00:00Z",
      "actorName": null
    },
    {
      "type": "LocationUpdated",
      "title": "Location updated",
      "subtitle": "Restaurant",
      "timestamp": "2026-02-26T10:00:00Z",
      "actorName": "Staff B"
    }
  ]
}
```

**Activity Types:**
| Type | Description | actorName |
|------|-------------|-----------|
| `LocationAdded` | A new address was added | Name of the person who added it |
| `LocationUpdated` | An address was updated | Name of the owner |
| `SubAccountCreated` | A sub-account was created | `null` |

> `recentActivities` returns a maximum of **10 most recent activities** sorted by newest first.

---

## 2. Get sub-accounts

```http
GET /api/business/sub-accounts?pageNumber={n}&pageSize={n}
```

**Authorization:** Business

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK`
```json
{
  "items": [
    {
      "id": "a1b2c3d4-5717-4562-b3fc-2c963f66afa6",
      "name": "Staff A",
      "phone": "0901234567",
      "email": "staff.a@company.com",
      "documents": null,
      "role": "SubAccount",
      "parentBusinessId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "createdAt": "2026-01-10T10:30:00Z",
      "updatedAt": null
    }
  ],
  "totalCount": 3,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 1,
  "hasPreviousPage": false,
  "hasNextPage": false
}
```

---

## 3. Create a sub-account

```http
POST /api/business/sub-accounts
```

**Authorization:** Business

**Request Body:**
```json
{
  "name": "Staff B",
  "email": "staff.b@company.com",
  "password": "Password123",
  "phone": "0912345678",
  "dateOfBirth": null,
  "documents": null
}
```

> Role is automatically set to `SubAccount`. The sub-account belongs to the currently logged-in Business.

**Response:** `201 Created` - User object with `role: "SubAccount"` and `parentBusinessId` pointing to the Business

**Errors:**
- `400` - Email is already in use
- `400` - Business account not found

---

## 4. Update a sub-account

```http
PUT /api/business/sub-accounts/{id}
```

**Authorization:** Business

**Path Parameters:**
- `id`: ID of the sub-account (must belong to the currently logged-in Business)

**Request Body:** (all fields are optional)
```json
{
  "name": "Staff B (renamed)",
  "phone": "0987654321",
  "email": "staff.b.new@company.com",
  "dateOfBirth": "1998-05-20T00:00:00Z",
  "documents": null
}
```

> The sub-account's role cannot be changed via this API.

**Response:** `200 OK` - Updated User object

**Errors:**
- `400` - Email is already in use
- `404` - Sub-account not found or does not belong to this business

---

## 5. Get all addresses for the business group

Returns addresses for **both the business and all its sub-accounts**.

```http
GET /api/business/addresses?pageNumber={n}&pageSize={n}
```

**Authorization:** Business, SubAccount

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Behavior by role:**
| Role | Data returned |
|------|---------------|
| `Business` | Addresses of the business + all sub-accounts |
| `SubAccount` | Addresses of the parent business + all peer sub-accounts (including itself) |

**Response:** `200 OK` - PagedResult of Address objects

```json
{
  "items": [
    {
      "id": "3fa85f64-...",
      "code": "HANX9K21",
      "name": "Main Office",
      "userId": "3fa85f64-...",
      "userName": "Company ABC",
      "status": "Reviewed"
    },
    {
      "id": "a1b2c3d4-...",
      "code": "HCMB3P54",
      "name": "Branch District 1",
      "userId": "a1b2c3d4-...",
      "userName": "Staff A",
      "status": "Reviewed"
    }
  ],
  "totalCount": 24,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 2,
  "hasPreviousPage": false,
  "hasNextPage": true
}
```

---

## 6. Get addresses added by the current account

Returns only addresses added by **the currently logged-in account** (excludes sub-accounts and parent).

```http
GET /api/business/addresses/mine?pageNumber={n}&pageSize={n}
```

**Authorization:** Business, SubAccount

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Address objects
```json
{
  "items": [
    {
      "id": "3fa85f64-...",
      "code": "HANX9K21",
      "name": "Main Office",
      "fullAddress": "Floor 5, 99 Lang Ha, Dong Da District, Hanoi",
      "latitude": 21.02,
      "longitude": 105.85,
      "status": "Reviewed",
      "isVerified": true,
      "userId": "3fa85f64-...",
      "userName": "Company ABC",
      "createdAt": "2024-01-10T10:30:00Z"
    }
  ],
  "totalCount": 10,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 1,
  "hasPreviousPage": false,
  "hasNextPage": false
}
```
