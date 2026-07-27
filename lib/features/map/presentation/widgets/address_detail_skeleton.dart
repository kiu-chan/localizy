import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton_loader.dart';

/// Placeholder skeleton cho phần chi tiết địa chỉ (tiêu đề + badge + các dòng thông tin).
///
/// Dùng chung cho [AddressDetailBottomSheet] (có icon lớn bên trái, [showLeadingIcon]
/// = true) và trang chi tiết trong [AddressSearchPage].
class AddressDetailSkeleton extends StatelessWidget {
  const AddressDetailSkeleton({super.key, this.showLeadingIcon = false});

  final bool showLeadingIcon;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 14),
            Row(
              children: const [
                SkeletonBox(width: 84, height: 26),
                SizedBox(width: 8),
                SkeletonBox(width: 70, height: 26),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            for (var i = 0; i < 5; i++) ...[
              _buildInfoRow(valueFactor: i.isEven ? 0.8 : 0.55),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SkeletonBox(width: 180, height: 20),
        SizedBox(height: 8),
        SkeletonBox(width: 230, height: 14),
      ],
    );

    if (!showLeadingIcon) return texts;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(
          width: 60,
          height: 60,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        const SizedBox(width: 16),
        Expanded(child: texts),
      ],
    );
  }

  Widget _buildInfoRow({required double valueFactor}) {
    return Row(
      children: [
        const SkeletonBox(
          width: 20,
          height: 20,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        const SizedBox(width: 12),
        const SkeletonBox(width: 90, height: 13),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: valueFactor,
              child: const SkeletonBox(height: 13),
            ),
          ),
        ),
      ],
    );
  }
}
