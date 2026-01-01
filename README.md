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
3. Tạo **API Key** → Giới hạn theo iOS Bundle ID:  `com.cameroon.localizy`
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

**Lưu ý**:  File `Secrets.plist` đã được thêm vào `.gitignore` và sẽ không được commit. 