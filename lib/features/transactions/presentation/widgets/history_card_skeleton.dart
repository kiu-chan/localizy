import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_loader.dart';

/// Placeholder skeleton mô phỏng bố cục của [HistoryCard] / [ValidationCard]
/// (hai card có cùng cấu trúc) trong lúc tải dữ liệu.
class HistoryCardSkeleton extends StatelessWidget {
  const HistoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonBox(
                  width: 44,
                  height: 44,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 130, height: 16),
                      SizedBox(height: 6),
                      SkeletonBox(width: 100, height: 13),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    SkeletonBox(width: 74, height: 16),
                    SizedBox(height: 6),
                    SkeletonBox(width: 58, height: 13),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonBox(width: 96, height: 12),
                SkeletonBox(width: 70, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
