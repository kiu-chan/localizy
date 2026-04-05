# ✅ Validation APIs

Manages address verification requests. This is the flow for regular users to request verification of their address.

### Validation Status Flow

```
Pending → Assigned → Scheduled → Verified
                               ↘ Rejected
```

| Status | Description | Who performs it |
|--------|-------------|-----------------|
| `Pending` | Newly submitted, awaiting admin action | - |
| `Assigned` | Admin has assigned a validator | Admin |
| `Scheduled` | Validator has confirmed the appointment | Validator |
| `Verified` | Successfully verified, address added to the list | Admin/Validator |
| `Rejected` | Rejected | Admin/Validator |

### Note on document URLs

> All `idDocumentUrl` and `addressProofUrl` fields in responses return **full URLs** (including scheme + host), allowing clients to access them directly to view verification documents.
>
> Example: `http://localhost:5088/uploads/verifications/cccd_xxx.jpg`

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
    "cityName": "Ha Noi",
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
    "idDocumentUrl": "http://localhost:5088/uploads/verifications/cccd_xxx.jpg",
    "addressProofUrl": "http://localhost:5088/uploads/verifications/proof_xxx.jpg"
  },
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

## Admin Endpoints

### 1. Validation statistics

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

### 2. Get all validation requests

```http
GET /api/validations?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Validation objects

---

### 3. Search validations

```http
GET /api/validations/search?searchTerm={term}&pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Query Parameters:**
- `searchTerm`: Search by requestId, address code, submitter name, or notes
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Validation objects

---

### 4. Filter by status

```http
GET /api/validations/filter/status/{status}?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Path Parameters:**
- `status`: `Pending` | `Assigned` | `Scheduled` | `Verified` | `Rejected`

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Validation objects

---

### 5. Filter by priority

```http
GET /api/validations/filter/priority/{priority}?pageNumber={n}&pageSize={n}
```

**Authorization:** Admin

**Path Parameters:**
- `priority`: `Low` | `Medium` | `High`

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Validation objects

---

### 6. Get validation by ID

```http
GET /api/validations/{id}
```

**Authorization:** Admin

**Response:** `200 OK` - Validation object

---

### 7. Get validation by Request ID

```http
GET /api/validations/request/{requestId}
```

**Authorization:** Admin

**Example:** `GET /api/validations/request/VAL-2024-001`

**Response:** `200 OK` - Validation object

**Errors:**
- `404` - Validation request not found

---

### 8. Assign a validator

Admin assigns a validator to go verify the address.

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

**Response:** `200 OK` - Validation object with `status: "Assigned"`

**Errors:**
- `400` - Validator not found
- `404` - Validation request not found

---

### 9. Verify an address

After verification, the address is added to `AddressCodes` with `status = Reviewed`. The `fullAddress` from the verification request is assigned to the newly created address.

```http
POST /api/validations/{id}/verify
```

**Authorization:** Admin, Validator

**Request Body:**
```json
{
  "notes": "Verified on-site, address is accurate"
}
```

**Response:** `200 OK` - Validation object with `status: "Verified"`

> 🔔 **Push Notification:** The server automatically sends an FCM notification to the submitter's device (if an FCM token is registered) with the message **"Address verified"**.

---

### 10. Reject a validation

```http
POST /api/validations/{id}/reject
```

**Authorization:** Admin, Validator

**Request Body:**
```json
{
  "reason": "Coordinates do not match the actual address"
}
```

**Response:** `200 OK` - Validation object with `status: "Rejected"`

**Errors:**
- `400` - Reason must not be empty

> 🔔 **Push Notification:** The server automatically sends an FCM notification to the submitter's device (if an FCM token is registered) with the message **"Verification request rejected"** including the reason.

---

### 11. Update address info (Admin & Validator)

Admin or Validator edits address information related to a verification request.

```http
PUT /api/validations/{id}/address-info
```

**Authorization:** Admin, Validator

**Conditions:**
| Role | Allowed conditions |
|------|-------------------|
| `Admin` | Status is `Pending`, `Assigned`, or `Scheduled` (before Verified/Rejected) |
| `Validator` | Assigned to the request + Status is `Assigned` or `Scheduled` |

**Request Body:** (all fields are optional)
```json
{
  "name": "Pho Bac Restaurant",
  "fullAddress": "123 Nguyen Trai, Thuong Dinh Ward, Thanh Xuan District, Hanoi",
  "cityId": "d4e5f6a7-5717-4562-b3fc-2c963f66afa6",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "locationName": "Pho Bac Restaurant",
  "notes": "Updated note"
}
```

> **Note:** If the validation has an `addressId` (existing address), the fields `name`, `fullAddress`, `cityId`, `latitude`, `longitude` are updated directly in the `AddressCodes` table. Otherwise, only `latitude`, `longitude`, `locationName`, `notes` on the Validation are updated.

**Response:** `200 OK` - Updated Validation object

**Errors:**
- `400` - Cannot edit after Verified/Rejected
- `403` - Validator is not assigned to this request
- `404` - Validation request not found

---

### 12. Update validation (Admin)

```http
PUT /api/validations/{id}
```

**Authorization:** Admin

**Request Body:** (all fields are optional)
```json
{
  "priority": "High",
  "notes": "Updated note"
}
```

**Response:** `200 OK` - Updated Validation object

**Errors:**
- `404` - Validation request not found

---

### 13. Delete validation

```http
DELETE /api/validations/{id}
```

**Authorization:** Admin

> **Soft Delete:** The record is not physically deleted. The `IsDeleted` column is set to `true` and `DeletedAt` is recorded.

**Response:** `204 No Content`

---

## Validator Endpoints

### 14. View assigned tasks

Validator views the list of verification requests assigned by Admin.

```http
GET /api/validations/my-assignments?pageNumber={n}&pageSize={n}
```

**Authorization:** Validator

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Validation objects (only requests assigned to the current validator)

---

### 15. Confirm appointment

Validator confirms they will attend the verification appointment.

```http
POST /api/validations/{id}/confirm-appointment
```

**Authorization:** Validator

**Response:** `200 OK` - Validation object with `status: "Scheduled"`

**Errors:**
- `403` - This validation is not assigned to you
- `404` - Validation request not found

> 🔔 **Push Notification:** The server automatically sends an FCM notification to the submitter's device (if an FCM token is registered) with the message **"Appointment confirmed"** including the date and time.

---

## User Endpoints

### 16. Submit an address verification request

Regular users submit a verification request along with supporting documents.

```http
POST /api/validations/verification-request
```

**Authorization:** User (role = User)

**Content-Type:** `multipart/form-data`

**Form Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `IdDocument` | file | No | ID card or passport image |
| `AddressProof` | file | No | Document proving the address |
| `AddressId` | string (Guid) | No | Existing address ID (for updates) |
| `RequestType` | string | No | `NewAddress` \| `UpdateAddress` (default: `NewAddress`) |
| `Priority` | string | No | `Low` \| `Medium` \| `High` (default: `Medium`) |
| `IdType` | string | No | Document type: `CCCD`, `Passport`, etc. |
| `Latitude` | double | No | Address latitude |
| `Longitude` | double | No | Address longitude |
| `LocationName` | string | No | Location name (e.g. "Pho Bac Restaurant") |
| `FullAddress` | string | No | Full address (e.g. "123 Nguyen Trai, Thanh Xuan District, Hanoi") — assigned to `Address.FullAddress` when approved |
| `PaymentMethod` | string | No | Payment method |
| `PaymentAmount` | decimal | No | Payment amount |
| `AppointmentDate` | datetime | No | Verification appointment date |
| `AppointmentTimeSlot` | string | No | Appointment time slot (e.g. "9:00-11:00") |

**cURL Example:**
```bash
curl -X POST http://localhost:5088/api/validations/verification-request \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -F "IdDocument=@/path/to/cccd.jpg" \
  -F "AddressProof=@/path/to/address_proof.pdf" \
  -F "IdType=CCCD" \
  -F "Latitude=21.0285" \
  -F "Longitude=105.8542" \
  -F "LocationName=Pho Bac Restaurant" \
  -F "FullAddress=123 Nguyen Trai, Thuong Dinh Ward, Thanh Xuan District, Hanoi" \
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
    "idDocumentUrl": "http://localhost:5088/uploads/verifications/cccd_xxx.jpg",
    "addressProofUrl": "http://localhost:5088/uploads/verifications/proof_xxx.jpg"
  },
  "location": {
    "latitude": 21.0285,
    "longitude": 105.8542,
    "locationName": "Pho Bac Restaurant",
    "fullAddress": "123 Nguyen Trai, Thuong Dinh Ward, Thanh Xuan District, Hanoi"
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

### 17. Get verification request detail

```http
GET /api/validations/verification-request/{id}
```

**Authorization:** Authenticated

**Response:** `200 OK` - Verification request object

---

### 18. Get validations by user ID

```http
GET /api/validations/user/{userId}?pageNumber={n}&pageSize={n}
```

**Authorization:** Authenticated

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK` - PagedResult of Validation objects

---

### 19. Get current user's validations

```http
GET /api/validations/my-validations?pageNumber={n}&pageSize={n}
```

**Authorization:** Authenticated

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 20, max: 100)

**Response:** `200 OK`
```json
{
  "items": [
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
  ],
  "totalCount": 3,
  "pageNumber": 1,
  "pageSize": 20,
  "totalPages": 1,
  "hasPreviousPage": false,
  "hasNextPage": false
}
```

> **Note:** `appointmentInfo` is `null` if no appointment has been set.
