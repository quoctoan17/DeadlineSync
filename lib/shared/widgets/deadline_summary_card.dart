import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class DeadlineSummaryCard extends StatelessWidget {
  const DeadlineSummaryCard({
    required this.totalCount,
    required this.urgentCount,
    required this.gmailCount,
    required this.manualCount,
    super.key,
  });

  final int totalCount;
  final int urgentCount;
  final int gmailCount;
  final int manualCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hôm nay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$totalCount deadline sắp tới',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$urgentCount deadline rủi ro cao • '
            '$gmailCount Gmail • $manualCount thủ công',
            style: const TextStyle(color: AppColors.border, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
