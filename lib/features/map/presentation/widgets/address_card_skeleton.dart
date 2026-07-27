import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_loader.dart';

/// Placeholder skeleton mô phỏng card địa chỉ trong [AddressSearchPage].
class AddressCardSkeleton extends StatelessWidget {
  const AddressCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 190, height: 15),
                  SizedBox(height: 8),
                  SkeletonBox(width: 140, height: 13),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SkeletonBox(width: 78, height: 22),
                      SizedBox(width: 8),
                      SkeletonBox(width: 62, height: 22),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Danh sách skeleton dùng cho trạng thái đang tải của [AddressSearchPage].
class AddressCardSkeletonList extends StatelessWidget {
  const AddressCardSkeletonList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AddressCardSkeleton(),
        ),
      ),
    );
  }
}
