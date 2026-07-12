import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/parking_repository.dart';
import '../../domain/parking_zone.dart';

/// Danh sách bãi đậu xe cho màn chọn bãi. autoDispose để mỗi lần mở
/// màn chọn bãi đều tải lại số chỗ trống mới nhất.
final parkingZonesProvider = FutureProvider.autoDispose<List<ParkingZone>>(
  (ref) => ref.watch(parkingRepositoryProvider).getParkingZones(),
);
