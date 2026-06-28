import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../deadline/domain/entities/deadline.dart';
import '../providers/dashboard_providers.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlinesAsync = ref.watch(mergedDeadlinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nhiệm vụ')),
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
                final openDeadlines = deadlines
                    .where((deadline) => !deadline.isCompleted)
                    .toList(growable: false);
                final urgentCount = openDeadlines
                    .where(
                      (deadline) => deadline.priority == PriorityLevel.high,
                    )
                    .length;

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _TaskHero(
                      total: openDeadlines.length,
                      urgent: urgentCount,
                      completed: deadlines.length - openDeadlines.length,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Danh sách cần xử lý',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (openDeadlines.isEmpty)
                      const _EmptyTasks()
                    else
                      for (final deadline in openDeadlines) ...[
                        _TaskTile(deadline: deadline),
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

class _TaskHero extends StatelessWidget {
  const _TaskHero({
    required this.total,
    required this.urgent,
    required this.completed,
  });

  final int total;
  final int urgent;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiến độ hôm nay',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$total nhiệm vụ mở',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$urgent ưu tiên cao • $completed đã hoàn thành',
            style: const TextStyle(color: AppColors.border),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.deadline});

  final Deadline deadline;

  @override
  Widget build(BuildContext context) {
    final dueDate = deadline.dueDate;
    final dueLabel = dueDate == null
        ? 'Chưa có hạn'
        : DateFormat('dd/MM/yyyy HH:mm').format(dueDate);
    final color = _riskColor(deadline.riskLevel);

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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.checklist, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadline.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  dueLabel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _priorityLabel(deadline.priority),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(RiskLevel riskLevel) {
    return switch (riskLevel) {
      RiskLevel.low => AppColors.success,
      RiskLevel.medium => AppColors.warning,
      RiskLevel.high => AppColors.danger,
      RiskLevel.extreme => AppColors.textPrimary,
    };
  }

  String _priorityLabel(PriorityLevel priority) {
    return switch (priority) {
      PriorityLevel.low => 'Thấp',
      PriorityLevel.medium => 'Vừa',
      PriorityLevel.high => 'Cao',
    };
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.task_alt, color: AppColors.success, size: 34),
          SizedBox(height: AppSpacing.sm),
          Text('Chưa có nhiệm vụ cần xử lý'),
        ],
      ),
    );
  }
}
