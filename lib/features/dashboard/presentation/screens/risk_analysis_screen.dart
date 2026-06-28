import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../deadline/domain/entities/deadline.dart';
import '../providers/dashboard_providers.dart';

class RiskAnalysisScreen extends ConsumerWidget {
  const RiskAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlinesAsync = ref.watch(mergedDeadlinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Phân tích rủi ro')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: deadlinesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Không tải được: $error')),
              data: (deadlines) {
                final highRisk = deadlines
                    .where(
                      (deadline) =>
                          deadline.riskLevel == RiskLevel.high ||
                          deadline.riskLevel == RiskLevel.extreme,
                    )
                    .toList(growable: false);
                final mediumRisk = deadlines
                    .where((deadline) => deadline.riskLevel == RiskLevel.medium)
                    .toList(growable: false);
                final lowRisk = deadlines
                    .where((deadline) => deadline.riskLevel == RiskLevel.low)
                    .toList(growable: false);

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _RiskHero(
                      total: deadlines.length,
                      high: highRisk.length,
                      medium: mediumRisk.length,
                      low: lowRisk.length,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _RiskBar(
                      label: 'Rủi ro cao',
                      value: deadlines.isEmpty
                          ? 0
                          : highRisk.length / deadlines.length,
                      count: highRisk.length,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _RiskBar(
                      label: 'Rủi ro vừa',
                      value: deadlines.isEmpty
                          ? 0
                          : mediumRisk.length / deadlines.length,
                      count: mediumRisk.length,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _RiskBar(
                      label: 'Rủi ro thấp',
                      value: deadlines.isEmpty
                          ? 0
                          : lowRisk.length / deadlines.length,
                      count: lowRisk.length,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Cần ưu tiên',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (highRisk.isEmpty)
                      const _NoRiskState()
                    else
                      for (final deadline in highRisk) ...[
                        _RiskDeadlineTile(deadline: deadline),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RiskHero extends StatelessWidget {
  const _RiskHero({
    required this.total,
    required this.high,
    required this.medium,
    required this.low,
  });

  final int total;
  final int high;
  final int medium;
  final int low;

  @override
  Widget build(BuildContext context) {
    final score = total == 0
        ? 0
        : ((high * 100 + medium * 55 + low * 20) / total).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: CircularProgressIndicator(
              strokeWidth: 9,
              value: (score / 100).clamp(0, 1),
              color: score >= 70 ? AppColors.danger : AppColors.warning,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Điểm rủi ro tổng',
                  style: TextStyle(color: AppColors.border),
                ),
                Text(
                  '$score%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$total deadline • $high cao • $medium vừa',
                  style: const TextStyle(color: AppColors.border),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskBar extends StatelessWidget {
  const _RiskBar({
    required this.label,
    required this.value,
    required this.count,
    required this.color,
  });

  final String label;
  final double value;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '$count deadline',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: color,
            backgroundColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}

class _RiskDeadlineTile extends StatelessWidget {
  const _RiskDeadlineTile({required this.deadline});

  final Deadline deadline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gmailSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gmailRed.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.gmailRed),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadline.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (deadline.aiSuggestion?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    deadline.aiSuggestion!,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoRiskState extends StatelessWidget {
  const _NoRiskState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text('Không có deadline rủi ro cao.'),
    );
  }
}
