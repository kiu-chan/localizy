# iOS Configuration

## Google Maps API Key Setup

### 1. Create the Secrets.plist file

Create `ios/Runner/Secrets.plist`:

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

### 2. Add it to Xcode

```bash
# Open Xcode
cd ios
open Runner.xcworkspace
```

1. Right-click the **Runner** folder → **"Add Files to Runner..."**
2. Select the `Secrets.plist` file
3. ✅ Check **"Copy items if needed"**
4. ✅ Check **"Add to targets: Runner"**
5. Click **"Add"**

### 3. Get an API Key

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **Maps SDK for iOS**
3. Create an **API Key** → restrict it to the iOS Bundle ID: `com.cameroon.citea`
4. Copy the API key and replace `YOUR_API_KEY_HERE`

### 4. Rebuild

```bash
flutter clean
cd ios
pod install
cd ..
flutter run
```

---

# Architecture

The app uses **feature-first + Riverpod** (slimmed-down Clean Architecture, no use-case layer).
All code lives under `lib/features/` and `lib/core/` — no more `screens/`, `api/`,
`services/`, `utils/`, `models/`.

## Directory structure

```
lib/
├── core/                      # Shared across all features
│   ├── network/               # ApiClient (apiClientProvider) + ApiException
│   ├── config/                # ConfigManager, currency, map config
│   ├── services/              # NotificationService (FCM)
│   ├── theme/                 # AppTheme
│   └── widgets/               # Reusable widgets (receipt, ...)
├── features/
│   ├── auth/                  # Login, session, role-based navigation
│   ├── home/                  # Home page + slides, MainPage (user role)
│   ├── map/                   # Map, address search, directions
│   ├── ocr/                   # License plate scanning (ML Kit)
│   ├── parking/               # Parking payment & ticket lookup
│   ├── transactions/          # Transaction & verification history
│   ├── verification/          # Address verification wizard
│   ├── validator/             # Validator role (dashboard, schedule, assignments)
│   ├── business/              # Business role (dashboard, sub-accounts, map)
│   └── settings/              # Settings, profile, change password, language
├── main.dart                  # ProviderContainer + MaterialApp
└── splash_screen.dart
```

Each feature is split into 3 layers:

- **`domain/`** — pure Dart models (`fromJson`), no Flutter/HTTP dependency.
- **`data/`** — repository (receives `ApiClient` via the constructor) + `xxxRepositoryProvider`.
- **`presentation/`** — `providers/` (Riverpod), `pages/`, `widgets/`.

## State conventions (Riverpod)

- Async reads: `FutureProvider`; refresh with `ref.invalidate(...)`.
- Behavioral state: `Notifier` / `AsyncNotifier` (e.g. `authProvider`, `languageProvider`).
- Widgets use `ConsumerWidget` / `ConsumerStatefulWidget`; read `AsyncValue` via `.when(...)`.
- Single source of truth for the session: `authProvider`; 401 is handled centrally in
  `features/auth/presentation/session_expiry.dart`.
- Services outside the widget tree (e.g. `NotificationService`) use `AuthRepository.instance` /
  `ApiClient.instance` — these are the **only two remaining singletons**; everywhere else goes through providers.

---

**Note**: `Secrets.plist` is listed in `.gitignore` and will not be committed.
