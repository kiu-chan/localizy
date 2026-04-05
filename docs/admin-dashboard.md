# 📊 Admin Dashboard API

Returns a system-wide overview for Admin, including stats for users, addresses, validations, parking, and cities.

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
      { "id": "...", "name": "Ha Noi", "code": "HAN", "addressCount": 150 }
    ]
  }
}
```

> The 5 stats are fetched sequentially (EF Core DbContext does not support concurrent queries on the same scoped instance).

---

## Validator Dashboard

Returns an overview for the Validator: task statistics and the 10 most recently assigned tasks.

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

| Field | Description |
|-------|-------------|
| `totalAssigned` | Total number of assigned tasks |
| `assignedCount` | Tasks waiting for appointment confirmation |
| `scheduledCount` | Tasks with confirmed appointments |
| `verifiedCount` | Successfully verified tasks |
| `rejectedCount` | Rejected tasks |
| `todayAppointments` | Number of appointments scheduled for today |
| `recentAssignments` | 10 most recently assigned tasks |
