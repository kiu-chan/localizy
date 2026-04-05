# 📈 Statistics API

Returns all statistics and analytics data for the Admin Statistics page, including user growth, address growth, validation activity, distribution by city/role, and key metrics.

```http
GET /api/statistics?timeRange=7days
```

**Authorization:** Admin

### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `timeRange` | string | `7days` | Time range: `7days` \| `30days` \| `90days` \| `1year` |

---

## Response `200 OK`

```json
{
  "summary": { ... },
  "userGrowth": [ ... ],
  "addressGrowth": [ ... ],
  "validationActivity": [ ... ],
  "userRoleDistribution": [ ... ],
  "topContributors": [ ... ],
  "cityDistribution": [ ... ],
  "activityByHour": [ ... ],
  "keyMetrics": { ... }
}
```

---

### `summary` — Overall statistics

```json
{
  "totalUsers": 1234,
  "totalUsersChange": 12.5,
  "totalAddresses": 5678,
  "totalAddressesChange": 8.3,
  "verifiedToday": 47,
  "verifiedTodayChange": -3.2,
  "activeUsers": 892,
  "activeUsersChange": 5.7
}
```

| Field | Description |
|-------|-------------|
| `totalUsers` | Total current users |
| `totalUsersChange` | % change compared to the previous period |
| `totalAddresses` | Total current addresses |
| `totalAddressesChange` | % change compared to the previous period |
| `verifiedToday` | Number of addresses verified today |
| `verifiedTodayChange` | % change compared to yesterday |
| `activeUsers` | Users who created at least one address in the period |
| `activeUsersChange` | % change compared to the previous period |

---

### `userGrowth` — Daily user growth

```json
[
  { "date": "2024-03-18", "users": 1150, "active": 45, "new": 12 }
]
```

| Field | Description |
|-------|-------------|
| `date` | Date (yyyy-MM-dd) |
| `users` | Cumulative total users up to that date |
| `active` | Users who created an address on that day |
| `new` | New users registered on that day |

---

### `addressGrowth` — Daily address growth

```json
[
  { "date": "2024-03-18", "total": 5450, "verified": 4100, "pending": 180 }
]
```

| Field | Description |
|-------|-------------|
| `date` | Date (yyyy-MM-dd) |
| `total` | Cumulative total addresses up to that date |
| `verified` | Total reviewed addresses (status = Reviewed) up to that date |
| `pending` | Pending addresses created on that day |

---

### `validationActivity` — Daily verification activity

```json
[
  { "date": "2024-03-18", "verified": 45, "rejected": 8, "pending": 180 }
]
```

| Field | Description |
|-------|-------------|
| `date` | Date (yyyy-MM-dd) |
| `verified` | Requests approved on that day (processedDate = that date) |
| `rejected` | Requests rejected on that day (processedDate = that date) |
| `pending` | Pending requests created up to that day (createdAt <= that date) |

---

### `userRoleDistribution` — User distribution by role

```json
[
  { "name": "User", "value": 1050, "percentage": 85.1 },
  { "name": "Business", "value": 120, "percentage": 9.7 },
  { "name": "Validator", "value": 45, "percentage": 3.6 },
  { "name": "Admin", "value": 19, "percentage": 1.5 }
]
```

| Field | Description |
|-------|-------------|
| `name` | Role name: `User` \| `Admin` \| `Validator` \| `Business` \| `SubAccount` |
| `value` | Number of users |
| `percentage` | Percentage |

---

### `topContributors` — Top contributors

```json
[
  { "rank": 1, "name": "Nguyen Van A", "addresses": 45, "verified": 42 }
]
```

| Field | Description |
|-------|-------------|
| `rank` | Rank (1–10) |
| `name` | User name |
| `addresses` | Total addresses created |
| `verified` | Addresses that were approved |

---

### `cityDistribution` — Address distribution by city

```json
[
  { "city": "Ha Noi", "count": 3245, "percentage": 57.1 },
  { "city": "Others", "count": 173, "percentage": 3.0 }
]
```

Top 5 cities with the most addresses + an "Others" group for the rest.

---

### `activityByHour` — Activity by hour of day

```json
[
  { "hour": "00:00", "activity": 45 },
  { "hour": "18:00", "activity": 412 }
]
```

24 entries (00:00 → 23:00). `activity` is the total number of addresses and verification requests created in that hour, calculated across the entire `timeRange`.

---

### `keyMetrics` — Key metrics

```json
{
  "avgResponseTimeHours": 2.5,
  "verificationRate": 76.2,
  "userEngagement": 72.3,
  "avgAddressesPerUser": 4.6,
  "rejectionRate": 8.5,
  "peakActivityHour": "18:00"
}
```

| Field | Formula | Description |
|-------|---------|-------------|
| `avgResponseTimeHours` | avg(processedDate - submittedDate) | Average response time (hours) for processed validations |
| `verificationRate` | reviewed / totalAddresses × 100 | % of addresses that have been approved |
| `userEngagement` | usersWithAddresses / totalUsers × 100 | % of users who created at least 1 address |
| `avgAddressesPerUser` | totalAddresses / totalUsers | Average addresses per user |
| `rejectionRate` | rejected / totalValidations × 100 | % of verification requests that were rejected |
| `peakActivityHour` | hour with highest activity | The busiest hour of the day |
