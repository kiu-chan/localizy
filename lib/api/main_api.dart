// Tương thích ngược: MainApi đã chuyển thành ApiClient tại core/network/.
// File này chỉ re-export và sẽ bị xóa ở Giai đoạn 6 của lộ trình migrate
// (docs/ARCHITECTURE_MIGRATION.md). Code mới import trực tiếp:
//   package:localizy/core/network/api_client.dart
import 'package:localizy/core/network/api_client.dart';

export 'package:localizy/core/network/api_client.dart';
export 'package:localizy/core/network/api_exception.dart';

typedef MainApi = ApiClient;
