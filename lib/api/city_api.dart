// Tương thích ngược: logic thành phố đã chuyển về features/map/.
// Facade này sẽ bị xóa ở Giai đoạn 6 của lộ trình migrate.
// Code mới dùng cityRepositoryProvider / activeCitiesProvider.
import 'package:localizy/features/map/data/city_repository.dart';
import 'package:localizy/features/map/domain/city.dart';

export 'package:localizy/features/map/domain/city.dart';

class CityApi {
  static Future<List<CityItem>> getActiveCities() =>
      CityRepository.instance.getActiveCities();
}
