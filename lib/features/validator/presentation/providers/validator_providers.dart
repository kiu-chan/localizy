import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/validator_repository.dart';
import '../../domain/validation_assignment.dart';

/// Dữ liệu tổng quan cho tab Dashboard.
final validatorDashboardProvider = FutureProvider<ValidatorDashboard>(
  (ref) => ref.watch(validatorRepositoryProvider).getDashboard(),
);

/// Danh sách yêu cầu được phân công — dùng chung cho tab Requests và Schedule.
/// Sau khi confirm/verify/reject, gọi `ref.invalidate(myAssignmentsProvider)`
/// để cả hai tab cùng thấy dữ liệu mới.
final myAssignmentsProvider = FutureProvider<List<ValidationAssignment>>(
  (ref) => ref.watch(validatorRepositoryProvider).getMyAssignments(),
);
