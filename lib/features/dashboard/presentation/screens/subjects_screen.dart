import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../deadline/domain/entities/deadline.dart';
import '../providers/dashboard_providers.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlinesAsync = ref.watch(mergedDeadlinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Môn học')),
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
                final subjects = _buildSubjects(deadlines);
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    const _SubjectsHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    if (subjects.isEmpty)
                      const _EmptySubjects()
                    else
                      for (final subject in subjects) ...[
                        _SubjectCard(subject: subject),
                        const SizedBox(height: AppSpacing.md),
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

  List<_SubjectSummary> _buildSubjects(List<Deadline> deadlines) {
    final buckets = <String, List<Deadline>>{};
    for (final deadline in deadlines) {
      final key = deadline.description?.trim().isNotEmpty == true
          ? deadline.description!.trim()
          : _sourceLabel(deadline.source);
      buckets.putIfAbsent(key, () => []).add(deadline);
    }

    return buckets.entries
        .map(
          (entry) => _SubjectSummary(
            name: entry.key,
            count: entry.value.length,
            highRisk: entry.value
                .where(
                  (deadline) =>
                      deadline.riskLevel == RiskLevel.high ||
                      deadline.riskLevel == RiskLevel.extreme,
                )
                .length,
            sources: entry.value.map((deadline) => deadline.source).toSet(),
          ),
        )
        .toList(growable: false)
      ..sort((left, right) => right.count.compareTo(left.count));
  }

  String _sourceLabel(DeadlineSource source) {
    return switch (source) {
      DeadlineSource.canvas => 'Canvas',
      DeadlineSource.outlook => 'Outlook',
      DeadlineSource.gmail => 'Gmail',
      DeadlineSource.manual => 'Manual',
    };
  }
}

class _SubjectSummary {
  const _SubjectSummary({
    required this.name,
    required this.count,
    required this.highRisk,
    required this.sources,
  });

  final String name;
  final int count;
  final int highRisk;
  final Set<DeadlineSource> sources;
}

class _SubjectsHeader extends StatelessWidget {
  const _SubjectsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.school_outlined, color: Colors.white, size: 30),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Theo dõi deadline theo môn học và nguồn đồng bộ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});

  final _SubjectSummary subject;

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
                  subject.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _CountBadge('${subject.count} deadline'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                  value: subject.count == 0
                      ? 0
                      : (subject.highRisk / subject.count).clamp(0, 1),
                  color: AppColors.danger,
                  backgroundColor: AppColors.border,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${subject.highRisk} rủi ro cao',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final source in subject.sources)
                _SourceChip(
                  label: _sourceLabel(source),
                  color: _sourceColor(source),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _sourceLabel(DeadlineSource source) {
    return switch (source) {
      DeadlineSource.canvas => 'Canvas',
      DeadlineSource.outlook => 'Outlook',
      DeadlineSource.gmail => 'Gmail',
      DeadlineSource.manual => 'Manual',
    };
  }

  Color _sourceColor(DeadlineSource source) {
    return switch (source) {
      DeadlineSource.canvas => AppColors.canvasOrange,
      DeadlineSource.outlook => AppColors.outlookBlue,
      DeadlineSource.gmail => AppColors.gmailRed,
      DeadlineSource.manual => AppColors.manualPurple,
    };
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.outlookSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.outlookBlue,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptySubjects extends StatelessWidget {
  const _EmptySubjects();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text('Chưa có dữ liệu môn học từ deadline.'),
    );
  }
}
