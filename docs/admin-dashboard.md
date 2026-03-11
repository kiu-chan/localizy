# 📊 Admin Dashboard API

Trả về tổng quan toàn hệ thống cho Admin, bao gồm thống kê users, địa chỉ, validations, parking và cities.

```http
GET /api/dashboard
```

**Authorization:** Admin

**Response:** `200 OK`
```json
{
  "users": {
    "totalUsers": 100,
    "adminUsers": 2,
    "validatorUsers": 5,
    "regularUsers": 93
  },
  "addresses": {
    "totalAddresses": 500,
    "reviewedAddresses": 420,
    "pendingAddresses": 60,
    "rejectedAddresses": 20
  },
  "validations": {
    "totalRequests": 200,
    "pendingRequests": 50,
    "verifiedRequests": 130,
    "rejectedRequests": 20,
    "highPriorityRequests": 10,
    "todayRequests": 5
  },
  "parking": {
    "totalTickets": 1500,
    "activeTickets": 80,
    "expiredTickets": 1400,
    "todayTickets": 25,
    "totalRevenue": 52500000
  },
  "cities": {
    "totalCities": 10,
    "activeCities": 8,
    "inactiveCities": 2,
    "totalAddresses": 500,
    "topCities": [
      { "id": "...", "name": "Hà Nội", "code": "HAN", "addressCount": 150 }
    ]
  }
}
```

> 5 stats được fetch tuần tự (EF Core DbContext không hỗ trợ concurrent queries trên cùng một scoped instance).

---

## Validator Dashboard

Lấy dữ liệu tổng quan cho Validator: thống kê task và 10 task được phân công gần nhất.

```http
GET /api/dashboard/validator
```

**Authorization:** Validator

**Response:** `200 OK`
```json
{
  "taskStats": {
    "totalAssigned": 20,
    "assignedCount": 3,
    "scheduledCount": 5,
    "verifiedCount": 10,
    "rejectedCount": 2,
    "todayAppointments": 2
  },
  "recentAssignments": [ /* Array of Validation objects */ ]
}
```

| Field | Mô tả |
|-------|-------|
| `totalAssigned` | Tổng số task được phân công |
| `assignedCount` | Task đang chờ xác nhận lịch hẹn |
| `scheduledCount` | Task đã xác nhận lịch hẹn |
| `verifiedCount` | Task đã xác minh thành công |
| `rejectedCount` | Task đã từ chối |
| `todayAppointments` | Số lịch hẹn hôm nay |
| `recentAssignments` | 10 task được phân công gần nhất |
