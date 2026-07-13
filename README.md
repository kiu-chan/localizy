# iOS Configuration

## Google Maps API Key Setup

### 1. Tạo file Secrets.plist

Tạo file `ios/Runner/Secrets.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>GOOGLE_MAPS_API_KEY</key>
    <string>YOUR_API_KEY_HERE</string>
</dict>
</plist>
```

### 2. Thêm vào Xcode

```bash
# Mở Xcode
cd ios
open Runner.xcworkspace
```

1. Click chuột phải vào folder **Runner** → **"Add Files to Runner..."**
2. Chọn file `Secrets.plist`
3. ✅ Check **"Copy items if needed"**
4. ✅ Check **"Add to targets: Runner"**
5. Click **"Add"**

### 3. Lấy API Key

1. Truy cập [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **Maps SDK for iOS**
3. Tạo **API Key** → Giới hạn theo iOS Bundle ID:  `com.cameroon.citea`
4. Copy API key và thay vào `YOUR_API_KEY_HERE`

### 4. Rebuild

```bash
flutter clean
cd ios
pod install
cd ..
flutter run
```

---

# Kiến trúc

App dùng **feature-first + Riverpod** (Clean Architecture rút gọn, không có lớp use-case).
Toàn bộ mã nằm trong `lib/features/` và `lib/core/` — không còn `screens/`, `api/`,
`services/`, `utils/`, `models/`.

## Cấu trúc thư mục

```
lib/
├── core/                      # Dùng chung mọi feature
│   ├── network/               # ApiClient (apiClientProvider) + ApiException
│   ├── config/                # ConfigManager, currency, map config
│   ├── services/              # NotificationService (FCM)
│   ├── theme/                 # AppTheme
│   └── widgets/               # Widget tái sử dụng (receipt, ...)
├── features/
│   ├── auth/                  # Đăng nhập, phiên, điều hướng theo role
│   ├── home/                  # Trang chủ + slides, MainPage (role user)
│   ├── map/                   # Bản đồ, tìm địa chỉ, chỉ đường
│   ├── ocr/                   # Quét biển số (ML Kit)
│   ├── parking/               # Thanh toán & tra cứu vé đỗ xe
│   ├── transactions/          # Lịch sử giao dịch & xác minh
│   ├── verification/          # Wizard xác minh địa chỉ
│   ├── validator/             # Role Validator (dashboard, lịch, phân công)
│   ├── business/              # Role Business (dashboard, sub-account, bản đồ)
│   └── settings/              # Cài đặt, hồ sơ, đổi mật khẩu, ngôn ngữ
├── main.dart                  # ProviderContainer + MaterialApp
└── splash_screen.dart
```

Mỗi feature chia 3 lớp:

- **`domain/`** — model thuần Dart (`fromJson`), không phụ thuộc Flutter/HTTP.
- **`data/`** — repository (nhận `ApiClient` qua constructor) + `xxxRepositoryProvider`.
- **`presentation/`** — `providers/` (Riverpod), `pages/`, `widgets/`.

## Quy ước state (Riverpod)

- Đọc dữ liệu async: `FutureProvider`; làm mới bằng `ref.invalidate(...)`.
- State có hành vi: `Notifier` / `AsyncNotifier` (vd `authProvider`, `languageProvider`).
- Widget dùng `ConsumerWidget` / `ConsumerStatefulWidget`; đọc `AsyncValue` qua `.when(...)`.
- Nguồn sự thật phiên đăng nhập: `authProvider`; 401 xử lý tập trung ở
  `features/auth/presentation/session_expiry.dart`.
- Service ngoài cây widget (vd `NotificationService`) dùng `AuthRepository.instance` /
  `ApiClient.instance` — đây là **hai singleton duy nhất còn lại**, mọi nơi khác đi qua provider.

Chi tiết lộ trình migrate: xem [docs/ARCHITECTURE_MIGRATION.md](docs/ARCHITECTURE_MIGRATION.md).

---

**Lưu ý**:  File `Secrets.plist` đã được thêm vào `.gitignore` và sẽ không được commit. 