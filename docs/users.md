# 👥 User APIs

### User Response Object

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "name": "Nguyen Van A",
  "dateOfBirth": "1990-01-15T00:00:00Z",
  "phone": "0901234567",
  "email": "user@example.com",
  "documents": "[\"doc1.pdf\", \"doc2.pdf\"]",
  "avatarUrl": "/uploads/avatars/abc123.jpg",
  "role": "SubAccount",
  "parentBusinessId": "a1b2c3d4-5717-4562-b3fc-2c963f66afa6",
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": null
}
```

> **Note:** `parentBusinessId` is only populated when `role = "SubAccount"`. For other roles, this field is `null`.  
> **Note:** `avatarUrl` is `null` if the user has not uploaded a profile picture.

---

## 1. Get user statistics

```http
GET /api/users/stats
```

**Authorization:** Admin

**Response:** `200 OK`
```json
{
  "totalUsers": 100,
  "adminUsers": 2,
  "validatorUsers": 5,
  "regularUsers": 93
}
```

---

## 2. Search users

```http
GET /api/users/search?searchTerm={term}&pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `searchTerm` (string): Search by name or email
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of User objects
```json
{
  "items": [
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "name": "Nguyen Van A",
      "email": "user@example.com",
      "role": "User",
      "createdAt": "2024-01-10T10:30:00Z"
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

## 3. Get all users

```http
GET /api/users?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of User objects

---

## 4. Filter users by role

```http
GET /api/users/filter/role/{role}?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Path Parameters:**
- `role`: `User` | `Admin` | `Validator` | `Business` | `SubAccount`

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of User objects

---

## 5. Get user by ID

```http
GET /api/users/{id}
```

**Authorization:** Authenticated

**Response:** `200 OK` - User object

**Errors:**
- `404` - User not found

---

## 6. Create a new user

```http
POST /api/users
```

**Authorization:** Admin

**Request Body:**
```json
{
  "name": "Nguyen Van B",
  "dateOfBirth": "1995-06-20T00:00:00Z",
  "phone": "0912345678",
  "email": "newuser@example.com",
  "password": "Password123",
  "documents": null,
  "role": "Validator"
}
```

**Response:** `201 Created` - User object

**Errors:**
- `400` - Email is already in use

---

## 7. Update user

```http
PUT /api/users/{id}
```

**Authorization:** Authenticated

> **Note:** Only Admin can change the `role`. Regular users can only update their own information.

**Request Body:** (all fields are optional)
```json
{
  "name": "Nguyen Van A Updated",
  "dateOfBirth": "1990-01-15T00:00:00Z",
  "phone": "0901234567",
  "email": "newemail@example.com",
  "documents": "[\"doc1.pdf\"]",
  "role": "Validator"
}
```

**Response:** `200 OK` - User object

**Errors:**
- `404` - User not found
- `400` - Email is already in use

---

## 8. Delete user

```http
DELETE /api/users/{id}
```

**Authorization:** Admin

> **Soft Delete:** The record is not physically deleted. The `IsDeleted` column is set to `true` and `DeletedAt` is recorded. The user will no longer appear in any API.

**Response:** `204 No Content`

**Errors:**
- `404` - User not found

---

## 9. Upload profile picture

```http
POST /api/users/{id}/avatar
Content-Type: multipart/form-data
```

**Authorization:** Authenticated

> **Note:** Users can only upload their own picture. Admin can upload for any user. The old picture is automatically deleted when a new one is uploaded.

**Form Data:**
- `avatar` (file, required): Profile picture file

**Limits:**
- Formats: `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`
- Max size: **5MB**

**Response:** `200 OK` - User object (with updated `avatarUrl`)

**Errors:**
- `400` - Invalid file (wrong format, exceeds 5MB, or no file provided)
- `403` - Not authorized to upload a picture for another user
- `404` - User not found

---

## 10. Change password

```http
POST /api/users/{id}/change-password
```

**Authorization:** Authenticated

**Request Body:**
```json
{
  "currentPassword": "OldPassword123",
  "newPassword": "NewPassword456"
}
```

> **Note:** Admin can change another user's password without providing `currentPassword`.

**Response:** `200 OK`
```json
{ "message": "Password changed successfully" }
```

**Errors:**
- `400` - Current password is incorrect
- `404` - User not found
