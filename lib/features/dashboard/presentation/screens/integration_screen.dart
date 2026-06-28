import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../ai_import/presentation/screens/ai_import_review_screen.dart';
import '../providers/dashboard_providers.dart';

class IntegrationScreen extends ConsumerWidget {
  const IntegrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlinesAsync = ref.watch(mergedDeadlinesProvider);
    final deadlineCount = deadlinesAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Kết nối nguồn')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _SyncHeader(deadlineCount: deadlineCount),
                const SizedBox(height: AppSpacing.lg),
                _ConnectionCard(
                  icon: Icons.mail_outline,
                  title: 'Gmail',
                  subtitle: 'Quét email và dùng AI trích xuất deadline',
                  color: AppColors.gmailRed,
                  status: 'Sẵn sàng quét',
                  actionLabel: 'Import AI',
                  onAction: () => _openImport(context, ref),
                ),
                const SizedBox(height: AppSpacing.md),
                _ConnectionCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'Microsoft Outlook',
                  subtitle: 'Đồng bộ lịch họp và deadline từ calendar',
                  color: AppColors.outlookBlue,
                  status: 'Chờ tích hợp',
                  actionLabel: 'Xem trạng thái',
                  onAction: () => _showComingSoon(context),
                ),
                const SizedBox(height: AppSpacing.md),
                _ConnectionCard(
                  icon: Icons.school_outlined,
                  title: 'Canvas / Moodle',
                  subtitle: 'Kết nối LMS để gom bài tập theo môn học',
                  color: AppColors.canvasOrange,
                  status: 'Chờ API nhóm',
                  actionLabel: 'Xem trạng thái',
                  onAction: () => _showComingSoon(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                const _SyncNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openImport(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const AiImportReviewScreen(),
      ),
    );
    ref.invalidate(mergedDeadlinesProvider);
    ref.invalidate(visibleDeadlinesProvider);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phần này đang chờ API tích hợp của nhóm.')),
    );
  }
}

class _SyncHeader extends StatelessWidget {
  const _SyncHeader({required this.deadlineCount});

  final int deadlineCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sync, color: Colors.white, size: 30),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sync center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$deadlineCount deadline đang có trong máy',
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

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.status,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String status;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _SyncNote extends StatelessWidget {
  const _SyncNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.outlookSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Màn này gom phần Sync/Connect trong Figma: Gmail import dùng AI thật, các nguồn còn lại hiển thị trạng thái để nối API sau.',
        style: TextStyle(
          color: AppColors.outlookBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
