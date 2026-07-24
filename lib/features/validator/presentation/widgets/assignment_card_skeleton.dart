import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_loader.dart';

/// Placeholder skeleton mô phỏng bố cục của [AssignmentCard] trong lúc tải dữ liệu.
class AssignmentCardSkeleton extends StatelessWidget {
  const AssignmentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonBox(width: 80, height: 20),
              SkeletonBox(width: 70, height: 14),
            ],
          ),
          const SizedBox(height: 10),
          const SkeletonBox(width: 140, height: 18),
          const SizedBox(height: 8),
          const SkeletonBox(width: 200, height: 13),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  SkeletonBox(width: 60, height: 20),
                  SizedBox(width: 8),
                  SkeletonBox(width: 50, height: 20),
                ],
              ),
              const SkeletonBox(width: 14, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}
