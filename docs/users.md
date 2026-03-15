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
  "role": "SubAccount",
  "parentBusinessId": "a1b2c3d4-5717-4562-b3fc-2c963f66afa6",
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": null
}
```

> **Lưu ý:** `parentBusinessId` chỉ có giá trị khi `role = "SubAccount"`. Với các role khác, trường này là `null`.

---

## 1. Lấy thống kê users

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

## 2. Tìm kiếm users

```http
GET /api/users/search?searchTerm={term}&pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `searchTerm` (string): Tìm theo name hoặc email
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

## 3. Lấy tất cả users

```http
GET /api/users?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of User objects

---

## 4. Lọc users theo role

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

## 5. Lấy thông tin user theo ID

```http
GET /api/users/{id}
```

**Authorization:** Authenticated

**Response:** `200 OK` - User object

**Errors:**
- `404` - User not found

---

## 6. Tạo user mới

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

## 7. Cập nhật user

```http
PUT /api/users/{id}
```

**Authorization:** Authenticated

> **Lưu ý:** Chỉ Admin mới có thể thay đổi `role`. User thường chỉ cập nhật được thông tin của chính mình.

**Request Body:** (tất cả fields đều optional)
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

## 8. Xóa user

```http
DELETE /api/users/{id}
```

**Authorization:** Admin

> **Soft Delete:** Bản ghi không bị xóa vật lý. Cột `IsDeleted` được đặt `true` và `DeletedAt` được ghi nhận. User sẽ không còn xuất hiện trong bất kỳ API nào.

**Response:** `204 No Content`

**Errors:**
- `404` - User not found

---

## 9. Đổi mật khẩu

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

> **Lưu ý:** Admin có thể đổi mật khẩu của user khác mà không cần nhập `currentPassword`.

**Response:** `200 OK`
```json
{ "message": "Password changed successfully" }
```

**Errors:**
- `400` - Mật khẩu hiện tại không đúng
- `404` - User not found
