import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AiImportReviewScreen extends StatefulWidget {
  const AiImportReviewScreen({super.key});

  @override
  State<AiImportReviewScreen> createState() => _AiImportReviewScreenState();
}

class _AiImportReviewScreenState extends State<AiImportReviewScreen> {
  bool _hasAnalyzed = false;
  final Set<String> _selectedIds = {'ai-midterm', 'ai-report'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import bằng AI')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _ImportHeader(hasAnalyzed: _hasAnalyzed),
                const SizedBox(height: AppSpacing.lg),
                _IntegrationPanel(
                  hasAnalyzed: _hasAnalyzed,
                  onAnalyze: () => setState(() => _hasAnalyzed = true),
                ),
                if (_hasAnalyzed) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _ReviewPanel(
                    selectedIds: _selectedIds,
                    onToggle: _toggleCandidate,
                    onConfirm: _confirmImport,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleCandidate(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _confirmImport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xác nhận ${_selectedIds.length} deadline từ AI'),
      ),
    );
  }
}

class _ImportHeader extends StatelessWidget {
  const _ImportHeader({required this.hasAnalyzed});

  final bool hasAnalyzed;

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
          Text(
            hasAnalyzed ? 'AI đã tìm thấy deadline' : 'Quét email bằng AI',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasAnalyzed
                ? 'Kiểm tra lại kết quả trước khi import vào DeadlineSync.'
                : 'Kết nối nguồn email, chọn khoảng thời gian và để AI trích xuất deadline cần theo dõi.',
            style: const TextStyle(color: AppColors.border, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _IntegrationPanel extends StatelessWidget {
  const _IntegrationPanel({required this.hasAnalyzed, required this.onAnalyze});

  final bool hasAnalyzed;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Thiết lập import',
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: _SourceCard(
                  icon: Icons.mail_outline,
                  title: 'Gmail',
                  subtitle: 'Read-only email scopes',
                  status: 'Đã kết nối',
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SourceCard(
                  icon: Icons.psychology_alt_outlined,
                  title: 'AI Review',
                  subtitle: 'Lọc email học tập',
                  status: 'Sẵn sàng',
                  color: AppColors.manualPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Expanded(
                child: _ConfigTile(
                  icon: Icons.date_range_outlined,
                  label: 'Khoảng thời gian',
                  value: '7 ngày gần nhất',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ConfigTile(
                  icon: Icons.filter_alt_outlined,
                  label: 'Bộ lọc',
                  value: 'Email có deadline',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAnalyze,
              icon: Icon(
                hasAnalyzed ? Icons.refresh_outlined : Icons.auto_awesome,
              ),
              label: Text(hasAnalyzed ? 'Quét lại email' : 'Quét và phân tích'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewPanel extends StatelessWidget {
  const _ReviewPanel({
    required this.selectedIds,
    required this.onToggle,
    required this.onConfirm,
  });

  final Set<String> selectedIds;
  final void Function(String id, bool selected) onToggle;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Xác nhận kết quả AI',
      trailing: Text(
        '${selectedIds.length}/${_candidates.length} đã chọn',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Column(
        children: [
          for (final candidate in _candidates) ...[
            _CandidateTile(
              candidate: candidate,
              selected: selectedIds.contains(candidate.id),
              onChanged: (selected) => onToggle(candidate.id, selected),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: selectedIds.isEmpty ? null : onConfirm,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Import deadline đã chọn'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigTile extends StatelessWidget {
  const _ConfigTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.candidate,
    required this.selected,
    required this.onChanged,
  });

  final _AiDeadlineCandidate candidate;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: selected ? AppColors.outlookSoft : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? AppColors.outlookBlue : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: selected,
            onChanged: (value) => onChanged(value ?? false),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${DateFormat('dd/MM, HH:mm').format(candidate.dueDate)} • ${candidate.subject}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  candidate.reason,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ConfidenceBadge(confidence: candidate.confidence),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence});

  final int confidence;

  @override
  Widget build(BuildContext context) {
    final color = confidence >= 90 ? AppColors.success : AppColors.warning;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        '$confidence%',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AiDeadlineCandidate {
  const _AiDeadlineCandidate({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.reason,
    required this.confidence,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final String reason;
  final int confidence;
}

final _candidates = [
  _AiDeadlineCandidate(
    id: 'ai-midterm',
    title: 'Nộp đề cương giữa kỳ',
    subject: 'Project Management',
    dueDate: DateTime.now().add(const Duration(days: 2, hours: 23)),
    reason: 'AI phát hiện cụm "deadline nộp đề cương" trong email giảng viên.',
    confidence: 94,
  ),
  _AiDeadlineCandidate(
    id: 'ai-report',
    title: 'Báo cáo tiến độ UI',
    subject: 'Mobile Development',
    dueDate: DateTime.now().add(const Duration(days: 5, hours: 18)),
    reason: 'Email nhóm có yêu cầu gửi file báo cáo trước buổi demo.',
    confidence: 89,
  ),
  _AiDeadlineCandidate(
    id: 'ai-optional',
    title: 'Đọc tài liệu Firebase',
    subject: 'Cloud Sync',
    dueDate: DateTime.now().add(const Duration(days: 7, hours: 9)),
    reason: 'AI đánh dấu là việc nên làm, cần xác nhận trước khi import.',
    confidence: 76,
  ),
];
