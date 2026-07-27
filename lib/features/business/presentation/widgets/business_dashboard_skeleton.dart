import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_loader.dart';

/// Placeholder skeleton mô phỏng bố cục của [BusinessDashboardPage] trong lúc tải dữ liệu.
class BusinessDashboardSkeleton extends StatelessWidget {
  const BusinessDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 120, height: 20),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SkeletonBox(width: 170, height: 20),
                  const SizedBox(height: 16),
                  ...List.generate(4, (_) => _buildActivityItem()),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final white = Colors.white.withValues(alpha: 0.4);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade700, Colors.blue.shade500],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 180, height: 24, color: white),
          const SizedBox(height: 8),
          SkeletonBox(width: 130, height: 16, color: white),
        ],
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          SizedBox(height: 12),
          SkeletonBox(width: 46, height: 24),
          SizedBox(height: 6),
          SkeletonBox(width: 80, height: 12),
        ],
      ),
    );
  }

  Widget _buildActivityItem() {
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
      child: Row(
        children: [
          const SkeletonBox(
            width: 44,
            height: 44,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 130, height: 14),
                SizedBox(height: 6),
                SkeletonBox(width: 180, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SkeletonBox(width: 44, height: 11),
        ],
      ),
    );
  }
}
