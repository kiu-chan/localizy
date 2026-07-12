# Lộ trình chuyển đổi kiến trúc: Feature-first + Riverpod

> Mục tiêu: chuyển từ cấu trúc layer-by-type (`screens/`, `api/`, `services/`) + `setState`
> sang **feature-first + Riverpod**, migrate **dần từng feature**, app luôn chạy được ở mọi thời điểm.

## Nguyên tắc xuyên suốt

1. **Không viết lại từ đầu** — code cũ (`setState` + static API) chạy song song với code mới cho đến khi feature đó được migrate.
2. **Mỗi giai đoạn = 1 (hoặc vài) PR riêng** — không trộn refactor kiến trúc với tính năng mới trong cùng PR.
3. **Feature mới bắt buộc viết theo kiến trúc mới** kể từ khi hoàn thành Giai đoạn 2.
4. Sau mỗi giai đoạn: app build được, chạy được các flow chính (login → home → parking/verification).

## Cấu trúc đích

```
lib/
├── core/
│   ├── network/        # api_client.dart (từ main_api.dart), api_exception.dart
│   ├── config/         # config_manager, currency_config, map_config
│   ├── theme/          # app_theme.dart (tách từ main.dart)
│   ├── l10n/           # giữ nguyên l10n hiện tại
│   └── services/       # notification_service (cross-feature)
├── features/
│   ├── auth/
│   │   ├── data/           # auth_repository.dart, auth_api.dart
│   │   ├── domain/         # user.dart, auth_state.dart
│   │   └── presentation/
│   │       ├── providers/  # auth_provider.dart (AsyncNotifier)
│   │       ├── pages/      # login, register, forgot_password
│   │       └── widgets/
│   ├── transactions/
│   ├── parking/
│   ├── verification/
│   ├── map/
│   ├── ocr/
│   ├── validator/
│   ├── business/
│   └── settings/
└── main.dart
```

Quy ước mỗi feature:

| Tầng | Chứa gì | Quy tắc |
|---|---|---|
| `domain/` | Model thuần (fromJson/toJson), không import Flutter | Không phụ thuộc tầng nào |
| `data/` | Repository (instance, không static) + API call | Chỉ phụ thuộc `domain/` và `core/network` |
| `presentation/` | Provider (state) + Page + Widget | Widget chỉ render, logic nằm trong provider |

---

## Giai đoạn 0 — Chuẩn bị nền (½ ngày)

**Mục tiêu:** Riverpod chạy song song với Provider hiện tại, khung thư mục sẵn sàng.

- [x] Thêm `flutter_riverpod` vào `pubspec.yaml`
- [x] Bọc app trong `main.dart`: `ProviderScope(child: ChangeNotifierProvider(...))` — hai hệ cùng chạy, không đụng nhau
- [x] Tạo khung thư mục `lib/core/` và `lib/features/` (rỗng)
- [x] Thêm file này vào repo, thống nhất quy ước với team

**Kiểm tra hoàn thành:** app build & chạy y như cũ.

---

## Giai đoạn 1 — Core layer (1–2 ngày)

**Mục tiêu:** hạ tầng dùng chung nằm ở `core/`, sẵn sàng cho mọi feature phía sau.

- [x] `api/main_api.dart` → `core/network/api_client.dart`
  - Chuyển từ singleton static sang instance, expose qua `apiClientProvider`
  - Giữ alias/re-export tạm để code cũ (`MainApi.instance`) không vỡ
- [x] Tạo `core/network/api_exception.dart` — chuẩn hóa lỗi (timeout, 401, 4xx, 5xx) thay vì `throw Exception(string)` rải rác
- [x] `utils/config_manager.dart`, `configs/currency_config.dart`, `configs/map_config.dart` → `core/config/`
- [x] Tách toàn bộ `ThemeData` trong `main.dart` → `core/theme/app_theme.dart`
- [x] `services/notification_service.dart` → `core/services/`

**Kiểm tra hoàn thành:** app chạy như cũ; import cũ vẫn hoạt động qua re-export.

---

## Giai đoạn 2 — Feature mẫu: Transactions (2–3 ngày) ⭐

**Mục tiêu:** migrate 1 feature nhỏ, độc lập làm **khuôn mẫu** cho mọi feature sau.
Chọn transactions vì: model `Transaction` đã có sẵn, chỉ đọc dữ liệu (ít rủi ro), nhưng UI đủ phức tạp (3 tab, filter) để làm mẫu đại diện.

- [x] `domain/`: tách class `Transaction` ra khỏi `api/transaction_api.dart`
- [x] `data/`: `TransactionRepository` (instance) + `transactionRepositoryProvider`
- [x] `presentation/providers/`: `AsyncNotifier` cho danh sách giao dịch + filter theo loại
- [x] Refactor 4 file UI (hiện ~3.800 dòng, logic trộn UI):
  - `transaction_history_page.dart`
  - `tabs/all_transactions_tab.dart` (1.008 dòng)
  - `tabs/parking_transactions_tab.dart` (969 dòng)
  - `tabs/verification_transactions_tab.dart` (1.089 dòng)
  - 3 tab đang lặp logic gần giống nhau → gom về 1 provider + 1 widget list dùng chung, tab chỉ khác filter
- [x] Xóa `api/transaction_api.dart` cũ

**Kiểm tra hoàn thành:** màn lịch sử giao dịch chạy đúng (load, refresh, filter, error state); đây là **code mẫu chuẩn** — mọi feature sau copy theo cấu trúc này.

---

## Giai đoạn 3 — Auth & Session (3–4 ngày) 🔑

**Mục tiêu:** migrate auth trước các feature lớn, vì mọi feature khác phụ thuộc trạng thái đăng nhập/token/role.

- [x] `domain/`: `User`, `AuthState` (unauthenticated / authenticated / loading)
- [x] `data/`: gom `api/auth_api.dart` (257 dòng), `api/user_profile_service.dart`, `services/logout_service.dart` → `AuthRepository` (token qua `flutter_secure_storage`)
- [x] `presentation/providers/`: `authProvider` (`AsyncNotifier<AuthState>`) — nguồn sự thật duy nhất về user + role (user / validator / business)
- [x] Migrate 3 màn: `login_page.dart`, `register_page.dart`, `forgot_password_page.dart` (gồm cả Google Sign-In, Firebase Auth)
- [x] `splash_screen.dart` + điều hướng theo role (`main_page` / `validator_main_page` / `business_main_page`) đọc từ `authProvider` thay vì tự check
- [x] Xử lý 401 tập trung: `ApiClient` bắn sự kiện → `authProvider` logout + điều hướng về login

**Kiểm tra hoàn thành:** login/logout/register cả 3 role, token hết hạn tự về màn login.

---

## Giai đoạn 4 — Các feature người dùng chính (mỗi feature 2–4 ngày, làm tuần tự)

Thứ tự theo mức độ quan trọng với người dùng cuối. Mỗi feature là 1 PR, theo đúng khuôn của Giai đoạn 2.

### 4a. Parking (thanh toán đỗ xe)
- [x] `api/parking_api.dart` + màn `home/parking/*`, `parking_payment_page.dart`, `payment_check_page.dart` (1.085 dòng — tách logic thanh toán vào provider)

### 4b. Verification (xác minh địa chỉ)
- [x] `api/verification_api.dart` + flow `home/verification/*` (7 màn wizard)
- [x] State của wizard (bước hiện tại, dữ liệu đã nhập, ảnh upload) → 1 `Notifier` duy nhất thay vì truyền qua constructor từng màn

### 4c. Map & Address
- [ ] `api/address_api.dart` (437 dòng), `api/city_api.dart`, `services/directions_service.dart` + `screens/map/*`, `address_search_page.dart`
- [ ] `map_page.dart` (775 dòng): tách cluster manager, search, directions thành các provider riêng

### 4d. OCR (quét biển số)
- [ ] `services/plate_recognition_service.dart` (414 dòng), `models/plate_country.dart` + `screens/ocr/*`
- [ ] Camera lifecycle giữ trong `StatefulWidget`, kết quả nhận dạng đưa qua provider

### 4e. Home & Slides
- [ ] `api/slide_api.dart` + `home_page.dart`, `main_page.dart`

**Kiểm tra hoàn thành mỗi feature:** flow end-to-end chạy đúng trên cả Android & iOS trước khi merge.

---

## Giai đoạn 5 — Feature theo role: Validator & Business (3–5 ngày)

### 5a. Validator
- [ ] `api/validator_api.dart` (346 dòng) + `screens/validator/*` (dashboard, request list, schedule, assignment map)

### 5b. Business
- [ ] `api/sub_account_api.dart` + `screens/business/*` (dashboard, map, sub-account)
- [ ] `business_map_page.dart` + form snapshot: state form → provider

---

## Giai đoạn 6 — Settings, l10n & dọn dẹp (1–2 ngày)

- [ ] Migrate `screens/setting/*` + settings của validator/business → `features/settings/`
- [ ] `utils/language_manager.dart` (ChangeNotifier) → `languageProvider` (Riverpod `Notifier`)
- [ ] Gỡ package `provider` khỏi `pubspec.yaml`, bỏ `ChangeNotifierProvider` trong `main.dart`
- [ ] Xóa các thư mục rỗng: `lib/api/`, `lib/services/`, `lib/screens/`, `lib/utils/`, `lib/models/`, `lib/configs/`
- [ ] Xóa các re-export tạm tạo ở Giai đoạn 1
- [ ] Cập nhật `README.md` mô tả kiến trúc mới

---

## Giai đoạn 7 — Test & củng cố (song song từ Giai đoạn 2)

- [ ] Unit test cho repository (mock `ApiClient`) — bắt đầu ngay từ feature transactions
- [ ] Unit test cho provider/notifier (Riverpod có `ProviderContainer` test rất gọn)
- [ ] Widget test cho 2–3 flow quan trọng: login, parking payment
- [ ] (Tùy chọn) CI chạy `flutter analyze` + `flutter test` mỗi PR

---

## Tổng quan tiến độ

| Giai đoạn | Nội dung | Ước lượng | Trạng thái |
|---|---|---|---|
| 0 | Chuẩn bị nền | ½ ngày | ✅ |
| 1 | Core layer | 1–2 ngày | ✅ |
| 2 | Feature mẫu: Transactions | 2–3 ngày | ✅ |
| 3 | Auth & Session | 3–4 ngày | ✅ |
| 4a–4e | Parking, Verification, Map, OCR, Home | 10–15 ngày | ⬜ |
| 5 | Validator & Business | 3–5 ngày | ⬜ |
| 6 | Settings & dọn dẹp | 1–2 ngày | ⬜ |
| 7 | Test (chạy song song) | — | ⬜ |

**Tổng: khoảng 4–6 tuần** nếu làm toàn thời gian, hoặc rải 2–3 tháng nếu làm xen kẽ với tính năng mới. Giai đoạn 0→3 nên làm liền mạch; từ Giai đoạn 4 có thể giãn ra, migrate feature nào khi có dịp chạm vào feature đó.
