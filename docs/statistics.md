# 📈 Statistics API

Trả về toàn bộ dữ liệu thống kê và phân tích cho trang Statistics của Admin, bao gồm tăng trưởng người dùng, địa chỉ, hoạt động validation, phân bổ theo thành phố/role và các chỉ số quan trọng.

```http
GET /api/statistics?timeRange=7days
```

**Authorization:** Admin

### Query Parameters

| Tham số | Kiểu | Mặc định | Mô tả |
|---------|------|----------|-------|
| `timeRange` | string | `7days` | Khoảng thời gian: `7days` \| `30days` \| `90days` \| `1year` |

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

### `summary` — Thống kê tổng quan

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

| Field | Mô tả |
|-------|-------|
| `totalUsers` | Tổng số người dùng hiện tại |
| `totalUsersChange` | % thay đổi so với kỳ trước |
| `totalAddresses` | Tổng số địa chỉ hiện tại |
| `totalAddressesChange` | % thay đổi so với kỳ trước |
| `verifiedToday` | Số địa chỉ được xác minh hôm nay |
| `verifiedTodayChange` | % thay đổi so với hôm qua |
| `activeUsers` | Số người dùng đã tạo địa chỉ trong kỳ |
| `activeUsersChange` | % thay đổi so với kỳ trước |

---

### `userGrowth` — Tăng trưởng người dùng theo ngày

```json
[
  { "date": "2024-03-18", "users": 1150, "active": 45, "new": 12 }
]
```

| Field | Mô tả |
|-------|-------|
| `date` | Ngày (yyyy-MM-dd) |
| `users` | Tổng tích lũy người dùng đến ngày đó |
| `active` | Số người dùng đã tạo địa chỉ trong ngày |
| `new` | Số người dùng mới đăng ký trong ngày |

---

### `addressGrowth` — Tăng trưởng địa chỉ theo ngày

```json
[
  { "date": "2024-03-18", "total": 5450, "verified": 4100, "pending": 180 }
]
```

| Field | Mô tả |
|-------|-------|
| `date` | Ngày (yyyy-MM-dd) |
| `total` | Tổng tích lũy địa chỉ đến ngày đó |
| `verified` | Tổng địa chỉ đã được duyệt (status = Reviewed) đến ngày đó |
| `pending` | Số địa chỉ đang chờ duyệt tạo trong ngày |

---

### `validationActivity` — Hoạt động xác minh theo ngày

```json
[
  { "date": "2024-03-18", "verified": 45, "rejected": 8, "pending": 180 }
]
```

| Field | Mô tả |
|-------|-------|
| `date` | Ngày (yyyy-MM-dd) |
| `verified` | Số yêu cầu được duyệt trong ngày (processedDate = ngày đó) |
| `rejected` | Số yêu cầu bị từ chối trong ngày (processedDate = ngày đó) |
| `pending` | Số yêu cầu đang chờ tạo trong ngày (createdAt <= ngày đó) |

---

### `userRoleDistribution` — Phân bổ người dùng theo role

```json
[
  { "name": "User", "value": 1050, "percentage": 85.1 },
  { "name": "Business", "value": 120, "percentage": 9.7 },
  { "name": "Validator", "value": 45, "percentage": 3.6 },
  { "name": "Admin", "value": 19, "percentage": 1.5 }
]
```

| Field | Mô tả |
|-------|-------|
| `name` | Tên role: `User` \| `Admin` \| `Validator` \| `Business` \| `SubAccount` |
| `value` | Số lượng người dùng |
| `percentage` | Tỷ lệ phần trăm |

---

### `topContributors` — Top người đóng góp nhiều nhất

```json
[
  { "rank": 1, "name": "Nguyen Van A", "addresses": 45, "verified": 42 }
]
```

| Field | Mô tả |
|-------|-------|
| `rank` | Thứ hạng (1–10) |
| `name` | Tên người dùng |
| `addresses` | Tổng số địa chỉ đã tạo |
| `verified` | Số địa chỉ được duyệt |

---

### `cityDistribution` — Phân bổ địa chỉ theo thành phố

```json
[
  { "city": "Hà Nội", "count": 3245, "percentage": 57.1 },
  { "city": "Others", "count": 173, "percentage": 3.0 }
]
```

Top 5 thành phố có nhiều địa chỉ nhất + nhóm "Others" cho phần còn lại.

---

### `activityByHour` — Hoạt động theo giờ trong ngày

```json
[
  { "hour": "00:00", "activity": 45 },
  { "hour": "18:00", "activity": 412 }
]
```

24 phần tử (00:00 → 23:00). `activity` là tổng số địa chỉ và yêu cầu xác minh được tạo trong giờ đó, tính trên toàn bộ `timeRange`.

---

### `keyMetrics` — Chỉ số quan trọng

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

| Field | Công thức | Mô tả |
|-------|-----------|-------|
| `avgResponseTimeHours` | avg(processedDate - submittedDate) | Thời gian phản hồi trung bình (giờ) cho các validation đã xử lý |
| `verificationRate` | reviewed / totalAddresses × 100 | % địa chỉ đã được duyệt trên tổng số |
| `userEngagement` | usersWithAddresses / totalUsers × 100 | % người dùng đã tạo ít nhất 1 địa chỉ |
| `avgAddressesPerUser` | totalAddresses / totalUsers | Số địa chỉ trung bình mỗi người dùng |
| `rejectionRate` | rejected / totalValidations × 100 | % yêu cầu xác minh bị từ chối |
| `peakActivityHour` | giờ có activity cao nhất | Khung giờ hoạt động nhiều nhất |
