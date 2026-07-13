import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/business_repository.dart';
import '../../domain/business_dashboard.dart';
import '../../domain/sub_account.dart';

/// Dữ liệu tổng quan cho tab Dashboard của Business.
final businessDashboardProvider = FutureProvider<BusinessDashboard>(
  (ref) => ref.watch(businessRepositoryProvider).getDashboard(),
);

/// Danh sách tài khoản con. Sau khi tạo/sửa, gọi
/// `ref.invalidate(subAccountsProvider)` (và dashboard vì subAccountCount đổi).
final subAccountsProvider = FutureProvider<List<SubAccount>>(
  (ref) => ref.watch(businessRepositoryProvider).getMySubAccounts(),
);
