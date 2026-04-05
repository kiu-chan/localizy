# 🔄 Common Use Cases

## Flow 1: Regular user verifies an address

```
1. User logs in
   POST /api/auth/login

2. User submits a verification request with ID document and address proof
   POST /api/validations/verification-request
   (multipart/form-data: IdDocument, AddressProof, Latitude, Longitude, LocationName, AppointmentDate, ...)

3. Admin views the list of pending requests
   GET /api/validations?status=Pending

4. Admin assigns a validator
   POST /api/validations/{id}/assign-validator
   { "validatorId": "..." }

5. Validator views their assigned tasks
   GET /api/validations/my-assignments

6. Validator confirms the appointment
   POST /api/validations/{id}/confirm-appointment
   🔔 Push notification sent to user: "Appointment confirmed"

7. Validator goes on-site and completes verification
   POST /api/validations/{id}/verify
   { "notes": "Verified on-site, address is valid" }
   🔔 Push notification sent to user: "Address verified"

✅ Address is added to AddressCodes with status = Reviewed
```

---

## Flow 2: Business adds an address directly

```
1. Business logs in (role = Business or SubAccount)
   POST /api/auth/login

2. Add address directly (no verification required) — address code is auto-generated
   POST /api/addresses
   { "name": "Company ABC Office", "fullAddress": "Floor 5, 99 Lang Ha, Dong Da District, Hanoi", "latitude": 21.02, "longitude": 105.85, "cityCode": "HAN" }

✅ Address immediately has status = Reviewed
```

---

## Flow 3: Business manages sub-accounts

```
1. Business logs in
   POST /api/auth/login

2. Create a sub-account for a staff member
   POST /api/business/sub-accounts
   { "name": "Staff A", "email": "staff.a@company.com", "password": "Pass@123", "phone": "0901234567" }

3. Staff member (SubAccount) logs in and adds an address
   POST /api/auth/login  (using sub-account credentials)
   POST /api/addresses
   { "name": "Branch District 3", "cityCode": "HCM", "latitude": ..., "longitude": ... }
   → Status = Reviewed immediately, address code is auto-generated (e.g. HCMB7X21)

4. Business views all addresses for the group (self + sub-accounts)
   GET /api/business/addresses

5. Business views only addresses they added themselves
   GET /api/business/addresses/mine

6. SubAccount views all addresses in the group (parent + all peer sub-accounts)
   GET /api/business/addresses  (using SubAccount token)

7. Business updates a sub-account's information
   PUT /api/business/sub-accounts/{subAccountId}
   { "phone": "0912345678" }
```

---

## Flow 4: Admin verifies directly (without a validator)

```
1. Admin views the list of pending requests
   GET /api/validations/filter/status/Pending

2. Admin verifies directly
   POST /api/validations/{id}/verify
   { "notes": "Verified directly by Admin" }
   🔔 Push notification sent to user: "Address verified"

✅ Address is added to AddressCodes with status = Reviewed
```

---

## Flow 5: Search addresses

```
# Search by code, name, fullAddress, district, or cityCode
GET /api/addresses/search?searchTerm=HAN
GET /api/addresses/search?searchTerm=HANA3K92
GET /api/addresses/search?searchTerm=Pho+Bac

# Get all coordinates for map display
GET /api/addresses/coordinates

# Filter by status
GET /api/addresses/filter/status/Reviewed
```

---

## Flow 6: Register and check parking tickets

```
1. Get the list of parking zones for map display
   GET /api/addresses/parking-zones

2. Purchase a parking ticket (login not required)
   POST /api/parking
   { "licensePlate": "30A-12345", "addressId": "3fa85f64-...", "duration": "4h", "paymentMethod": "momo" }
   → Returns ticketCode: "PKT12345678"

3. Check ticket by ticket code
   GET /api/parking/ticket/PKT12345678

4. Check ticket by license plate (most recent ticket)
   GET /api/parking/license/30A-12345

5. Extend a ticket
   POST /api/parking/{id}/extend
   { "duration": "2h", "paymentMethod": "momo" }

6. Logged-in user views their parking ticket history
   GET /api/parking/my-tickets
```

---

## Flow 7: View combined transaction history

```
1. Get all transactions (parking + verification) for the current user
   GET /api/transactions/my-transactions
   → Returns a list sorted by date descending, including both "parking" and "verification" types

2. View only parking ticket history
   GET /api/parking/my-tickets

3. View only address verification history
   GET /api/validations/my-validations
```
