// Tương thích ngược: logic địa chỉ đã chuyển về features/map/.
// Facade này sẽ bị xóa ở Giai đoạn 6 của lộ trình migrate
// (docs/ARCHITECTURE_MIGRATION.md). Code mới dùng addressRepositoryProvider.
import 'package:localizy/features/map/data/address_repository.dart';
import 'package:localizy/features/map/domain/address_models.dart';

export 'package:localizy/features/map/domain/address_models.dart';

class AddressApi {
  static AddressRepository get _repo => AddressRepository.instance;

  static Future<List<AddressCoordinate>> fetchCoordinates() =>
      _repo.fetchCoordinates();

  static Future<List<AddressSearchResult>> search(String searchTerm) =>
      _repo.search(searchTerm);

  static Future<List<MyAddress>> getMyAddresses() => _repo.getMyAddresses();

  static Future<List<MyAddress>> getBusinessAddresses() =>
      _repo.getBusinessAddresses();

  static Future<List<MyAddress>> getBusinessMineAddresses() =>
      _repo.getBusinessMineAddresses();

  static Future<MyAddress> addAddress({
    required String name,
    required String fullAddress,
    required double latitude,
    required double longitude,
    required String cityId,
  }) =>
      _repo.addAddress(
        name: name,
        fullAddress: fullAddress,
        latitude: latitude,
        longitude: longitude,
        cityId: cityId,
      );

  static Future<List<AddressItem>> fetchAll() => _repo.fetchAll();

  static Future<List<AddressItem>> searchItems(String searchTerm) =>
      _repo.searchItems(searchTerm);

  static Future<AddressDetail> getDetail(String id) => _repo.getDetail(id);
}
