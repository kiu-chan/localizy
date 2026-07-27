import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_loader.dart';

/// Placeholder skeleton dùng chung cho [TermsOfServicePage] và [PrivacyPolicyPage]:
/// header gradient + card nội dung dạng nhiều dòng chữ.
class LegalDocumentSkeleton extends StatelessWidget {
  const LegalDocumentSkeleton({super.key});

  /// Tỉ lệ bề rộng của từng dòng text giả, lặp lại để trông tự nhiên hơn.
  static const _lineFactors = <double>[
    1, 0.95, 0.88, 0.97, 0.6,
    1, 0.92, 0.85, 0.99, 0.72,
    1, 0.9, 0.64,
  ];

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildContentCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final white = Colors.white.withValues(alpha: 0.4);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4285F4), Color(0xFF6BA4F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          SkeletonBox(
            width: 72,
            height: 72,
            borderRadius: BorderRadius.circular(36),
            color: white,
          ),
          const SizedBox(height: 16),
          SkeletonBox(width: 220, height: 15, color: white),
          const SizedBox(height: 8),
          SkeletonBox(width: 150, height: 15, color: white),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
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
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final factor in _lineFactors) ...[
              SkeletonBox(width: constraints.maxWidth * factor, height: 12),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
