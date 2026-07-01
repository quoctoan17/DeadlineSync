import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../deadline/data/providers/deadline_database_providers.dart';
import '../../../deadline/domain/entities/deadline.dart';
import '../../../deadline/presentation/providers/ai_provider.dart';

class AiSuggestionScreen extends ConsumerStatefulWidget {
  const AiSuggestionScreen({super.key});

  @override
  ConsumerState<AiSuggestionScreen> createState() => _AiSuggestionScreenState();
}

class _AiSuggestionScreenState extends ConsumerState<AiSuggestionScreen> {
  late Future<List<Deadline>> _analysisFuture;
  final Set<String> _appliedDeadlineIds = {};
  final Set<String> _hiddenDeadlineIds = {};

  @override
  void initState() {
    super.initState();
    _analysisFuture = _loadSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gợi ý AI'),
        actions: [
          IconButton(
            tooltip: 'Phân tích lại',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: FutureBuilder<List<Deadline>>(
              future: _analysisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text('Không phân tích được AI: ${snapshot.error}'),
                    ),
                  );
                }

                final analyzedDeadlines = snapshot.data ?? const <Deadline>[];
                final visibleDeadlines = analyzedDeadlines
                    .where(
                      (deadline) => !_hiddenDeadlineIds.contains(deadline.id),
                    )
                    .toList(growable: false);

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    const _SuggestionHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    _FocusPlanPanel(deadlines: analyzedDeadlines),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Đề xuất hôm nay',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${visibleDeadlines.length} gợi ý',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (visibleDeadlines.isEmpty)
                      const _EmptySuggestionState()
                    else
                      for (final deadline in visibleDeadlines) ...[
                        _SuggestionCard(
                          deadline: deadline,
                          applied: _appliedDeadlineIds.contains(deadline.id),
                          onApply: () => _applySuggestion(deadline),
                          onHide: () => _hideSuggestion(deadline),
                        ),
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

  Future<List<Deadline>> _loadSuggestions() async {
    final deadlines = await ref
        .read(deadlineRepositoryProvider)
        .getLocalDeadlines();
    return ref.read(aiServiceProvider).analyzeOverallRisk(deadlines);
  }

  void _reload() {
    setState(() {
      _hiddenDeadlineIds.clear();
      _appliedDeadlineIds.clear();
      _analysisFuture = _loadSuggestions();
    });
  }

  void _applySuggestion(Deadline deadline) {
    setState(() => _appliedDeadlineIds.add(deadline.id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã áp dụng: ${deadline.title}')));
  }

  void _hideSuggestion(Deadline deadline) {
    setState(() => _hiddenDeadlineIds.add(deadline.id));
  }
}

class _SuggestionHeader extends StatelessWidget {
  const _SuggestionHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Text(
                'AI Suggestion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Gemini phân tích deadline thật trong database để gợi ý thứ tự làm việc và mức rủi ro.',
            style: TextStyle(color: AppColors.border, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _FocusPlanPanel extends StatelessWidget {
  const _FocusPlanPanel({required this.deadlines});

  final List<Deadline> deadlines;

  @override
  Widget build(BuildContext context) {
    final focusItems = [...deadlines]
      ..sort((left, right) {
        final riskResult = _riskWeight(
          right.riskLevel,
        ).compareTo(_riskWeight(left.riskLevel));
        if (riskResult != 0) return riskResult;
        final leftDue = left.dueDate ?? DateTime(9999);
        final rightDue = right.dueDate ?? DateTime(9999);
        return leftDue.compareTo(rightDue);
      });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kế hoạch tập trung',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (focusItems.isEmpty)
            const Text('Chưa có deadline để AI lập kế hoạch.')
          else
            for (final entry in focusItems.take(3).indexed) ...[
              _FocusSlot(
                time: ['08:00', '14:00', '20:00'][entry.$1],
                title: entry.$2.title,
                color: _riskColor(entry.$2.riskLevel),
              ),
              if (entry.$1 < 2) const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _FocusSlot extends StatelessWidget {
  const _FocusSlot({
    required this.time,
    required this.title,
    required this.color,
  });

  final String time;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Text(
            time,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.deadline,
    required this.applied,
    required this.onApply,
    required this.onHide,
  });

  final Deadline deadline;
  final bool applied;
  final VoidCallback onApply;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(deadline.riskLevel);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.auto_awesome, color: riskColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deadline.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      deadline.aiSuggestion?.isNotEmpty == true
                          ? deadline.aiSuggestion!
                          : 'AI chưa có lời khuyên riêng, hãy kiểm tra deadline và chia nhỏ công việc.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _ImpactBadge(
                label: _riskLabel(deadline.riskLevel),
                color: riskColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: applied ? null : onApply,
                  icon: Icon(
                    applied
                        ? Icons.check_circle_outline
                        : Icons.playlist_add_check,
                  ),
                  label: Text(applied ? 'Đã áp dụng' : 'Áp dụng'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onHide,
                icon: const Icon(Icons.visibility_off_outlined),
                label: const Text('Ẩn'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactBadge extends StatelessWidget {
  const _ImpactBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
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

class _EmptySuggestionState extends StatelessWidget {
  const _EmptySuggestionState();

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
          Icon(Icons.task_alt, color: AppColors.success, size: 32),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Không còn gợi ý mới',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

int _riskWeight(RiskLevel riskLevel) {
  return switch (riskLevel) {
    RiskLevel.low => 1,
    RiskLevel.medium => 2,
    RiskLevel.high => 3,
    RiskLevel.extreme => 4,
  };
}

Color _riskColor(RiskLevel riskLevel) {
  return switch (riskLevel) {
    RiskLevel.low => AppColors.success,
    RiskLevel.medium => AppColors.warning,
    RiskLevel.high => AppColors.danger,
    RiskLevel.extreme => AppColors.textPrimary,
  };
}

String _riskLabel(RiskLevel riskLevel) {
  return switch (riskLevel) {
    RiskLevel.low => 'Thấp',
    RiskLevel.medium => 'Vừa',
    RiskLevel.high => 'Cao',
    RiskLevel.extreme => 'Rất cao',
  };
}
