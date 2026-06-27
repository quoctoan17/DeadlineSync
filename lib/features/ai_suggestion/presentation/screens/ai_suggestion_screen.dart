import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AiSuggestionScreen extends StatefulWidget {
  const AiSuggestionScreen({super.key});

  @override
  State<AiSuggestionScreen> createState() => _AiSuggestionScreenState();
}

class _AiSuggestionScreenState extends State<AiSuggestionScreen> {
  final Set<String> _appliedSuggestionIds = {};
  final Set<String> _hiddenSuggestionIds = {};

  List<_AiSuggestion> get _visibleSuggestions {
    return _suggestions
        .where((suggestion) => !_hiddenSuggestionIds.contains(suggestion.id))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visibleSuggestions = _visibleSuggestions;

    return Scaffold(
      appBar: AppBar(title: const Text('Gợi ý AI')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const _SuggestionHeader(),
                const SizedBox(height: AppSpacing.lg),
                const _FocusPlanPanel(),
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
                      '${visibleSuggestions.length} gợi ý',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (visibleSuggestions.isEmpty)
                  const _EmptySuggestionState()
                else
                  for (final suggestion in visibleSuggestions) ...[
                    _SuggestionCard(
                      suggestion: suggestion,
                      applied: _appliedSuggestionIds.contains(suggestion.id),
                      onApply: () => _applySuggestion(suggestion),
                      onHide: () => _hideSuggestion(suggestion),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _applySuggestion(_AiSuggestion suggestion) {
    setState(() => _appliedSuggestionIds.add(suggestion.id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã áp dụng: ${suggestion.title}')));
  }

  void _hideSuggestion(_AiSuggestion suggestion) {
    setState(() => _hiddenSuggestionIds.add(suggestion.id));
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
            'AI gợi ý thứ tự làm việc dựa trên hạn nộp, độ ưu tiên và mức rủi ro của từng deadline.',
            style: TextStyle(color: AppColors.border, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _FocusPlanPanel extends StatelessWidget {
  const _FocusPlanPanel();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kế hoạch tập trung',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _FocusSlot(
                  time: '08:00',
                  title: 'Xử lý deadline gấp',
                  color: AppColors.danger,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FocusSlot(
                  time: '14:00',
                  title: 'Ôn phần quiz',
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FocusSlot(
                  time: '20:00',
                  title: 'Hoàn thiện báo cáo',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
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
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.applied,
    required this.onApply,
    required this.onHide,
  });

  final _AiSuggestion suggestion;
  final bool applied;
  final VoidCallback onApply;
  final VoidCallback onHide;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: suggestion.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(suggestion.icon, color: suggestion.color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      suggestion.reason,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _ImpactBadge(label: suggestion.impact, color: suggestion.color),
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

class _AiSuggestion {
  const _AiSuggestion({
    required this.id,
    required this.title,
    required this.reason,
    required this.impact,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String reason;
  final String impact;
  final IconData icon;
  final Color color;
}

const _suggestions = [
  _AiSuggestion(
    id: 'prioritize-mobile-ui',
    title: 'Làm Mobile App UI trước',
    reason:
        'Deadline gần nhất và đang có mức ưu tiên cao, nên xử lý trước các việc ít rủi ro hơn.',
    impact: 'Cao',
    icon: Icons.priority_high,
    color: AppColors.danger,
  ),
  _AiSuggestion(
    id: 'split-report',
    title: 'Chia báo cáo cuối kỳ thành 3 phần',
    reason:
        'AI thấy deadline còn xa nhưng khối lượng lớn, nên chia nhỏ để tránh dồn việc cuối tuần.',
    impact: 'Vừa',
    icon: Icons.account_tree_outlined,
    color: AppColors.warning,
  ),
  _AiSuggestion(
    id: 'prepare-demo',
    title: 'Chuẩn bị checklist demo',
    reason:
        'Buổi demo có liên quan nhiều task, thêm checklist sẽ giảm rủi ro quên bước khi trình bày.',
    impact: 'Ổn định',
    icon: Icons.fact_check_outlined,
    color: AppColors.success,
  ),
];
