import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_loader.dart';

/// Placeholder skeleton mô phỏng bố cục của [AccountSettingsPage] trong lúc tải hồ sơ.
class AccountSettingsSkeleton extends StatelessWidget {
  const AccountSettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(labelWidth: 70),
                  const SizedBox(height: 16),
                  _buildField(labelWidth: 50),
                  const SizedBox(height: 16),
                  _buildField(labelWidth: 60),
                  const SizedBox(height: 32),
                  SkeletonBox(
                    height: 48,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final white = Colors.white.withValues(alpha: 0.4);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, top: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF4285F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          SkeletonBox(
            width: 96,
            height: 96,
            borderRadius: BorderRadius.circular(48),
            color: white,
          ),
          const SizedBox(height: 12),
          SkeletonBox(width: 150, height: 20, color: white),
          const SizedBox(height: 8),
          SkeletonBox(width: 190, height: 14, color: white),
        ],
      ),
    );
  }

  Widget _buildField({required double labelWidth}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: labelWidth, height: 13),
        const SizedBox(height: 6),
        SkeletonBox(
          height: 52,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }
}
