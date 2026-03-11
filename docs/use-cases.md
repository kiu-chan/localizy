# 🔄 Common Use Cases

## Flow 1: User thường xác minh địa chỉ

```
1. User đăng nhập
   POST /api/auth/login

2. User gửi yêu cầu xác minh kèm ảnh CCCD và giấy tờ địa chỉ
   POST /api/validations/verification-request
   (multipart/form-data: IdDocument, AddressProof, Latitude, Longitude, LocationName, AppointmentDate, ...)

3. Admin xem danh sách yêu cầu
   GET /api/validations?status=Pending

4. Admin phân công validator
   POST /api/validations/{id}/assign-validator
   { "validatorId": "..." }

5. Validator xem task được phân công
   GET /api/validations/my-assignments

6. Validator xác nhận lịch hẹn
   POST /api/validations/{id}/confirm-appointment

7. Validator đến thực địa, xác minh xong
   POST /api/validations/{id}/verify
   { "notes": "Đã xác minh, hợp lệ" }

✅ Địa chỉ được thêm vào AddressCodes với status = Reviewed
```

---

## Flow 2: Business thêm địa chỉ trực tiếp

```
1. Business đăng nhập (role = Business hoặc SubAccount)
   POST /api/auth/login

2. Thêm địa chỉ trực tiếp (không cần xác minh) — mã địa chỉ tự động sinh
   POST /api/addresses
   { "name": "Văn phòng Công ty ABC", "fullAddress": "Tầng 5, 99 Láng Hạ, Q. Đống Đa, Hà Nội", "latitude": 21.02, "longitude": 105.85, "cityCode": "HAN" }

✅ Địa chỉ ngay lập tức có status = Reviewed
```

---

## Flow 3: Business quản lý tài khoản con

```
1. Business đăng nhập
   POST /api/auth/login

2. Tạo tài khoản con cho nhân viên
   POST /api/business/sub-accounts
   { "name": "Nhân viên A", "email": "staff.a@company.com", "password": "Pass@123", "phone": "0901234567" }

3. Nhân viên (SubAccount) đăng nhập và thêm địa chỉ
   POST /api/auth/login  (dùng tài khoản sub-account)
   POST /api/addresses
   { "name": "Chi nhánh Q.3", "cityCode": "HCM", "latitude": ..., "longitude": ... }
   → Status = Reviewed ngay lập tức, mã địa chỉ tự động sinh (ví dụ: HCMB7X21)

4. Business xem tất cả địa chỉ của nhóm (cả mình lẫn sub-accounts)
   GET /api/business/addresses

5. Business chỉ xem địa chỉ mà mình đã thêm
   GET /api/business/addresses/mine

6. SubAccount xem tất cả địa chỉ trong nhóm (bao gồm địa chỉ của parent và các sub-account cùng cấp)
   GET /api/business/addresses  (dùng token của SubAccount)

7. Business cập nhật thông tin tài khoản con
   PUT /api/business/sub-accounts/{subAccountId}
   { "phone": "0912345678" }
```

---

## Flow 4: Admin xác minh trực tiếp (không qua validator)

```
1. Admin xem danh sách yêu cầu pending
   GET /api/validations/filter/status/Pending

2. Admin xác minh trực tiếp
   POST /api/validations/{id}/verify
   { "notes": "Admin xác minh trực tiếp" }

✅ Địa chỉ được thêm vào AddressCodes với status = Reviewed
```

---

## Flow 5: Tìm kiếm địa chỉ

```
# Tìm theo code, name, fullAddress, district hoặc cityCode
GET /api/addresses/search?searchTerm=HAN
GET /api/addresses/search?searchTerm=HANA3K92
GET /api/addresses/search?searchTerm=Phở+Bắc
GET /api/addresses/search?searchTerm=Thanh+Xuân

# Lấy tất cả tọa độ để hiển thị trên map
GET /api/addresses/coordinates

# Lọc theo status
GET /api/addresses/filter/status/Reviewed
```

---

## Flow 6: Đăng ký và kiểm tra vé đỗ xe

```
1. Lấy danh sách bãi đỗ xe để hiển thị trên map
   GET /api/addresses/parking-zones

2. Đăng ký vé đỗ xe (có thể không cần đăng nhập)
   POST /api/parking
   { "licensePlate": "30A-12345", "addressId": "3fa85f64-...", "duration": "4h", "paymentMethod": "momo" }
   → Trả về ticketCode: "PKT12345678"

3. Kiểm tra vé theo mã vé
   GET /api/parking/ticket/PKT12345678

4. Kiểm tra vé theo biển số (vé mới nhất)
   GET /api/parking/license/30A-12345

5. Gia hạn vé
   POST /api/parking/{id}/extend
   { "duration": "2h", "paymentMethod": "momo" }

6. User đã đăng nhập xem lịch sử vé đỗ xe
   GET /api/parking/my-tickets
```

---

## Flow 7: Xem lịch sử giao dịch tổng hợp

```
1. Lấy tất cả giao dịch (đỗ xe + xác minh) của user hiện tại
   GET /api/transactions/my-transactions
   → Trả về list sắp xếp theo ngày giảm dần, gồm cả type "parking" và "verification"

2. Chỉ xem lịch sử vé đỗ xe
   GET /api/parking/my-tickets

3. Chỉ xem lịch sử xác minh địa chỉ
   GET /api/validations/my-validations
```
