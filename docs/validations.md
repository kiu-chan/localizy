# ✅ Validation APIs

Quản lý yêu cầu xác minh địa chỉ. Đây là flow cho người dùng thường yêu cầu xác minh địa chỉ của mình.

### Validation Status Flow

```
Pending → Assigned → Scheduled → Verified
                               ↘ Rejected
```

| Status | Mô tả | Ai thực hiện |
|--------|-------|--------------|
| `Pending` | Mới gửi, chờ admin xử lý | - |
| `Assigned` | Admin đã phân công validator | Admin |
| `Scheduled` | Validator đã xác nhận lịch hẹn | Validator |
| `Verified` | Đã xác minh thành công, địa chỉ vào danh sách | Admin/Validator |
| `Rejected` | Bị từ chối | Admin/Validator |

### Lưu ý về URL tài liệu

> Tất cả các trường `idDocumentUrl` và `addressProofUrl` trong response đều trả về **full URL** (bao gồm scheme + host), giúp client có thể truy cập trực tiếp để xem tài liệu xác minh.
>
> Ví dụ: `http://localhost:5088/uploads/verifications/cccd_xxx.jpg`

### Validation Response Object

```json
{
  "id": "3fa85f64-...",
  "requestId": "VAL-2024-001",
  "status": "Assigned",
  "priority": "Medium",
  "requestType": "NewAddress",
  "address": {
    "id": "a1b2c3d4-...",
    "code": "HANA3K92",
    "cityId": "d4e5f6a7-...",
    "cityName": "Hà Nội",
    "coordinates": { "lat": 21.0285, "lng": 105.8542 }
  },
  "submittedBy": {
    "userId": "b2c3d4e5-...",
    "name": "Nguyen Van A",
    "email": "user@example.com"
  },
  "submittedDate": "2024-01-10T10:30:00Z",
  "notes": "New address verification request",
  "verificationData": {
    "photosProvided": true,
    "documentsProvided": true,
    "locationVerified": false,
    "idDocumentUrl": "http://localhost:5088/uploads/verifications/cccd_xxx.jpg",
    "addressProofUrl": "http://localhost:5088/uploads/verifications/proof_xxx.jpg"
  },
  "attachmentsCount": 2,
  "assignedValidator": {
    "userId": "c3d4e5f6-...",
    "name": "Tran Van Validator"
  },
  "assignedDate": "2024-01-11T09:00:00Z",
  "processedBy": null,
  "processedDate": null,
  "processingNotes": null,
  "rejectionReason": null,
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": "2024-01-11T09:00:00Z"
}
```

---

## Endpoints dành cho Admin

### 1. Thống kê validations

```http
GET /api/validations/stats
```

**Authorization:** Admin

**Response:** `200 OK`
```json
{
  "totalRequests": 200,
  "pendingRequests": 50,
  "verifiedRequests": 130,
  "rejectedRequests": 20,
  "highPriorityRequests": 10,
  "todayRequests": 5
}
```

---

### 2. Lấy tất cả validation requests

```http
GET /api/validations
```

**Authorization:** Admin

**Response:** `200 OK` - Array of Validation objects

---

### 3. Tìm kiếm validations

```http
GET /api/validations/search?searchTerm={term}
```

**Authorization:** Admin

**Query Parameters:**
- `searchTerm`: Tìm theo requestId, address code, tên người gửi, notes

**Response:** `200 OK` - Array of Validation objects

---

### 4. Lọc theo status

```http
GET /api/validations/filter/status/{status}
```

**Authorization:** Admin

**Path Parameters:**
- `status`: `Pending` | `Assigned` | `Scheduled` | `Verified` | `Rejected`

**Response:** `200 OK` - Array of Validation objects

---

### 5. Lọc theo priority

```http
GET /api/validations/filter/priority/{priority}
```

**Authorization:** Admin

**Path Parameters:**
- `priority`: `Low` | `Medium` | `High`

**Response:** `200 OK` - Array of Validation objects

---

### 6. Lấy validation theo ID

```http
GET /api/validations/{id}
```

**Authorization:** Admin

**Response:** `200 OK` - Validation object

---

### 7. Lấy validation theo Request ID

```http
GET /api/validations/request/{requestId}
```

**Authorization:** Admin

**Example:** `GET /api/validations/request/VAL-2024-001`

**Response:** `200 OK` - Validation object

**Errors:**
- `404` - Validation request không tồn tại

---

### 8. Phân công validator

Admin chỉ định validator sẽ đến xác minh địa chỉ.

```http
POST /api/validations/{id}/assign-validator
```

**Authorization:** Admin

**Request Body:**
```json
{
  "validatorId": "c3d4e5f6-5717-4562-b3fc-2c963f66afa6"
}
```

**Response:** `200 OK` - Validation object với `status: "Assigned"`

**Errors:**
- `400` - Validator not found
- `404` - Validation request không tồn tại

---

### 9. Xác minh địa chỉ

Sau khi xác minh, địa chỉ sẽ được thêm vào danh sách `AddressCodes` với status `Reviewed`. Trường `fullAddress` từ yêu cầu xác minh sẽ được gán vào địa chỉ được tạo mới.

```http
POST /api/validations/{id}/verify
```

**Authorization:** Admin, Validator

**Request Body:**
```json
{
  "notes": "Đã xác minh thực địa, địa chỉ chính xác"
}
```

**Response:** `200 OK` - Validation object với `status: "Verified"`

---

### 10. Từ chối validation

```http
POST /api/validations/{id}/reject
```

**Authorization:** Admin, Validator

**Request Body:**
```json
{
  "reason": "Tọa độ không khớp với địa chỉ thực tế"
}
```

**Response:** `200 OK` - Validation object với `status: "Rejected"`

**Errors:**
- `400` - Reason không được để trống

---

### 11. Cập nhật thông tin địa chỉ (Admin & Validator)

Admin hoặc Validator chỉnh sửa thông tin địa chỉ liên quan đến yêu cầu xác minh.

```http
PUT /api/validations/{id}/address-info
```

**Authorization:** Admin, Validator

**Điều kiện:**
| Role | Điều kiện cho phép |
|------|-------------------|
| `Admin` | Status là `Pending`, `Assigned`, hoặc `Scheduled` (trước khi Verified/Rejected) |
| `Validator` | Được phân công cho request đó + Status là `Assigned` hoặc `Scheduled` |

**Request Body:** (tất cả fields đều optional)
```json
{
  "name": "Nhà hàng Phở Bắc",
  "fullAddress": "123 Nguyễn Trãi, P. Thượng Đình, Q. Thanh Xuân, Hà Nội",
  "district": "Thanh Xuân",
  "cityId": "d4e5f6a7-5717-4562-b3fc-2c963f66afa6",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "locationName": "Nhà hàng Phở Bắc",
  "notes": "Ghi chú cập nhật"
}
```

> **Lưu ý:** Nếu validation có `addressId` (địa chỉ đã tồn tại), các trường `name`, `fullAddress`, `district`, `cityId`, `latitude`, `longitude` sẽ được cập nhật trực tiếp vào bảng `AddressCodes`. Ngược lại, chỉ `latitude`, `longitude`, `locationName`, `notes` trên Validation được cập nhật.

**Response:** `200 OK` - Validation object đã cập nhật

**Errors:**
- `400` - Không thể sửa sau khi đã Verified/Rejected
- `403` - Validator không được phân công cho request này
- `404` - Validation request không tồn tại

---

### 12. Cập nhật validation (Admin)

```http
PUT /api/validations/{id}
```

**Authorization:** Admin

**Request Body:** (tất cả fields đều optional)
```json
{
  "priority": "High",
  "notes": "Cập nhật ghi chú",
  "photosProvided": true,
  "documentsProvided": true,
  "locationVerified": false
}
```

**Response:** `200 OK` - Validation object đã cập nhật

**Errors:**
- `404` - Validation request không tồn tại

---

### 13. Xóa validation

```http
DELETE /api/validations/{id}
```

**Authorization:** Admin

**Response:** `204 No Content`

---

## Endpoints dành cho Validator

### 14. Xem các task được phân công

Validator xem danh sách các yêu cầu xác minh được Admin phân công.

```http
GET /api/validations/my-assignments
```

**Authorization:** Validator

**Response:** `200 OK` - Array of Validation objects (chỉ các yêu cầu được phân công cho validator hiện tại)

---

### 15. Xác nhận lịch hẹn

Validator xác nhận sẽ đến xác minh theo lịch hẹn đã đặt.

```http
POST /api/validations/{id}/confirm-appointment
```

**Authorization:** Validator

**Response:** `200 OK` - Validation object với `status: "Scheduled"`

**Errors:**
- `403` - Validation này không được phân công cho bạn
- `404` - Validation request không tồn tại

---

## Endpoints dành cho User

### 16. Gửi yêu cầu xác minh địa chỉ

User thường gửi yêu cầu xác minh kèm tài liệu chứng minh.

```http
POST /api/validations/verification-request
```

**Authorization:** User (role = User)

**Content-Type:** `multipart/form-data`

**Form Fields:**

| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `IdDocument` | file | Không | Ảnh CCCD hoặc Hộ chiếu |
| `AddressProof` | file | Không | Giấy tờ chứng minh địa chỉ |
| `AddressId` | string (Guid) | Không | ID địa chỉ hiện có (nếu cập nhật) |
| `RequestType` | string | Không | `NewAddress` \| `UpdateAddress` (default: `NewAddress`) |
| `Priority` | string | Không | `Low` \| `Medium` \| `High` (default: `Medium`) |
| `IdType` | string | Không | Loại giấy tờ: `CCCD`, `Passport`, ... |
| `PhotosProvided` | boolean | Không | Có cung cấp ảnh không |
| `DocumentsProvided` | boolean | Không | Có cung cấp tài liệu không |
| `AttachmentsCount` | integer | Không | Số lượng tệp đính kèm |
| `Latitude` | double | Không | Vĩ độ của địa chỉ |
| `Longitude` | double | Không | Kinh độ của địa chỉ |
| `LocationName` | string | Không | Tên địa điểm (VD: "Nhà hàng Phở Bắc") |
| `FullAddress` | string | Không | Địa chỉ đầy đủ (VD: "123 Nguyễn Trãi, Q. Thanh Xuân, Hà Nội") — sẽ được gán vào `Address.FullAddress` khi được xác nhận |
| `PaymentMethod` | string | Không | Phương thức thanh toán |
| `PaymentAmount` | decimal | Không | Số tiền thanh toán |
| `AppointmentDate` | datetime | Không | Ngày hẹn xác minh |
| `AppointmentTimeSlot` | string | Không | Khung giờ hẹn (VD: "9:00-11:00") |

**cURL Example:**
```bash
curl -X POST http://localhost:5088/api/validations/verification-request \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -F "IdDocument=@/path/to/cccd.jpg" \
  -F "AddressProof=@/path/to/address_proof.pdf" \
  -F "IdType=CCCD" \
  -F "Latitude=21.0285" \
  -F "Longitude=105.8542" \
  -F "LocationName=Nhà hàng Phở Bắc" \
  -F "FullAddress=123 Nguyễn Trãi, P. Thượng Đình, Q. Thanh Xuân, Hà Nội" \
  -F "PaymentMethod=Cash" \
  -F "PaymentAmount=150000" \
  -F "AppointmentDate=2024-02-15T09:00:00Z" \
  -F "AppointmentTimeSlot=9:00-11:00"
```

**Response:** `201 Created`
```json
{
  "id": "3fa85f64-...",
  "requestId": "VAL-2024-042",
  "status": "Pending",
  "priority": "Medium",
  "address": {},
  "documents": {
    "idType": "CCCD",
    "photosProvided": true,
    "documentsProvided": true,
    "attachmentsCount": 2,
    "idDocumentUrl": "http://localhost:5088/uploads/verifications/cccd_xxx.jpg",
    "addressProofUrl": "http://localhost:5088/uploads/verifications/proof_xxx.jpg"
  },
  "location": {
    "latitude": 21.0285,
    "longitude": 105.8542,
    "locationName": "Nhà hàng Phở Bắc",
    "fullAddress": "123 Nguyễn Trãi, P. Thượng Đình, Q. Thanh Xuân, Hà Nội"
  },
  "payment": {
    "method": "Cash",
    "amount": 150000,
    "status": "Pending"
  },
  "appointment": {
    "date": "2024-02-15T09:00:00Z",
    "timeSlot": "9:00-11:00"
  },
  "submittedDate": "2024-01-10T10:30:00Z",
  "createdAt": "2024-01-10T10:30:00Z"
}
```

---

### 17. Lấy chi tiết verification request

```http
GET /api/validations/verification-request/{id}
```

**Authorization:** Authenticated

**Response:** `200 OK` - Verification request object

---

### 18. Lấy validations theo user ID

```http
GET /api/validations/user/{userId}
```

**Authorization:** Authenticated

**Response:** `200 OK` - Array of Validation objects

---

### 19. Lấy validations của user hiện tại

```http
GET /api/validations/my-validations
```

**Authorization:** Authenticated

**Response:** `200 OK`
```json
[
  {
    "id": "3fa85f64-...",
    "requestId": "VAL-2024-042",
    "status": "Pending",
    "createdAt": "2024-01-10T10:30:00Z",
    "notes": "New address verification request",
    "paymentInfo": {
      "amount": 150000,
      "method": "momo",
      "status": "Pending"
    },
    "locationInfo": {
      "latitude": 21.0285,
      "longitude": 105.8542
    },
    "documentFiles": {
      "idType": "CCCD",
      "idDocumentUrl": "http://localhost:5088/uploads/verifications/cccd_xxx.jpg",
      "addressProofUrl": "http://localhost:5088/uploads/verifications/proof_xxx.jpg"
    },
    "appointmentInfo": {
      "date": "2024-02-15T09:00:00Z",
      "timeSlot": "9:00-11:00"
    }
  }
]
```

> **Lưu ý:** `appointmentInfo` là `null` nếu chưa có lịch hẹn.
