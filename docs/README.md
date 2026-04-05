# Localizy Server - API Documentation

Detailed documentation for all API endpoints of Localizy Server.

## 📋 Table of Contents

- [Overview & Authentication](README.md) *(this file)*
- [Auth APIs](auth.md)
- [Admin Dashboard API](admin-dashboard.md)
- [User APIs](users.md)
- [Business APIs](business.md)
- [Address APIs](addresses.md)
- [Validation APIs](validations.md)
- [Parking APIs](parking.md)
- [Transaction APIs](transactions.md)
- [City APIs](cities.md)
- [Setting APIs](settings.md)
- [Home Slide APIs](home-slides.md)
- [Common Use Cases](use-cases.md)

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

### JWT Bearer Token

The API uses JWT (JSON Web Token) for user authentication.

#### Obtain a token:
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "admin@localizy.com",
  "password": "Admin@123"
}
```

#### Use the token:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Token Properties:
- **Expiration**: 24 hours
- **Algorithm**: HS256
- **Claims**: UserId, Email, Name, Role

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

### Error Response Format

```json
{
  "message": "Error description here"
}
```

### HTTP Status Codes

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
