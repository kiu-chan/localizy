import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_loader.dart';

/// Placeholder skeleton mô phỏng bố cục của [SubAccountCard] trong lúc tải dữ liệu.
class SubAccountCardSkeleton extends StatelessWidget {
  const SubAccountCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          const SkeletonBox(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 140, height: 15),
                SizedBox(height: 7),
                SkeletonBox(width: 180, height: 12),
                SizedBox(height: 6),
                SkeletonBox(width: 110, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Chevron + date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              SkeletonBox(width: 20, height: 20),
              SizedBox(height: 6),
              SkeletonBox(width: 56, height: 11),
            ],
          ),
        ],
      ),
    );
  }
}
