import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../deadline/domain/entities/deadline.dart';
import '../../../deadline/presentation/providers/import_provider.dart';

class AiImportReviewScreen extends ConsumerStatefulWidget {
  const AiImportReviewScreen({super.key});

  @override
  ConsumerState<AiImportReviewScreen> createState() =>
      _AiImportReviewScreenState();
}

class _AiImportReviewScreenState extends ConsumerState<AiImportReviewScreen> {
  int _days = 7;
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final pendingDeadlines = ref.watch(pendingDeadlinesProvider);
    final isImporting = ref.watch(isImportingProvider);

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
                _ImportHeader(hasResults: pendingDeadlines.isNotEmpty),
                const SizedBox(height: AppSpacing.lg),
                _IntegrationPanel(
                  days: _days,
                  isImporting: isImporting,
                  onDaysChanged: (value) => setState(() => _days = value),
                  onAnalyze: _runImportFlow,
                ),
                const SizedBox(height: AppSpacing.lg),
                _ReviewPanel(
                  deadlines: pendingDeadlines,
                  selectedIds: _selectedIds,
                  isImporting: isImporting,
                  onToggle: _toggleDeadline,
                  onConfirm: _confirmImport,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _runImportFlow() async {
    try {
      await ref.read(importControllerProvider).runImportFlow(_days);
      final pendingDeadlines = ref.read(pendingDeadlinesProvider);
      setState(() {
        _selectedIds
          ..clear()
          ..addAll(pendingDeadlines.map((deadline) => deadline.id));
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không quét được Gmail: $error')));
    }
  }

  void _toggleDeadline(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  Future<void> _confirmImport() async {
    final pendingDeadlines = ref.read(pendingDeadlinesProvider);
    final selectedDeadlines = pendingDeadlines
        .where((deadline) => _selectedIds.contains(deadline.id))
        .toList(growable: false);

    try {
      await ref.read(importControllerProvider).confirmImport(selectedDeadlines);
      setState(_selectedIds.clear);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã import ${selectedDeadlines.length} deadline từ AI'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không import được deadline: $error')),
      );
    }
  }
}

class _ImportHeader extends StatelessWidget {
  const _ImportHeader({required this.hasResults});

  final bool hasResults;

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
            hasResults ? 'AI đã tìm thấy deadline' : 'Quét email bằng AI',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasResults
                ? 'Kiểm tra kết quả Gemini trước khi import vào DeadlineSync.'
                : 'Chọn khoảng thời gian, quét Gmail và để Gemini trích xuất deadline thật.',
            style: const TextStyle(color: AppColors.border, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _IntegrationPanel extends StatelessWidget {
  const _IntegrationPanel({
    required this.days,
    required this.isImporting,
    required this.onDaysChanged,
    required this.onAnalyze,
  });

  final int days;
  final bool isImporting;
  final ValueChanged<int> onDaysChanged;
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
                  status: 'Dữ liệu thật',
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SourceCard(
                  icon: Icons.psychology_alt_outlined,
                  title: 'Gemini',
                  subtitle: 'Trích xuất deadline',
                  status: 'AI thật',
                  color: AppColors.manualPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<int>(
            initialValue: days,
            decoration: const InputDecoration(
              labelText: 'Khoảng thời gian quét',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 7, child: Text('7 ngày gần nhất')),
              DropdownMenuItem(value: 14, child: Text('14 ngày gần nhất')),
              DropdownMenuItem(value: 30, child: Text('30 ngày gần nhất')),
            ],
            onChanged: isImporting
                ? null
                : (value) {
                    if (value == null) return;
                    onDaysChanged(value);
                  },
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isImporting ? null : onAnalyze,
              icon: isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                isImporting ? 'Đang quét Gmail...' : 'Quét và phân tích',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewPanel extends StatelessWidget {
  const _ReviewPanel({
    required this.deadlines,
    required this.selectedIds,
    required this.isImporting,
    required this.onToggle,
    required this.onConfirm,
  });

  final List<Deadline> deadlines;
  final Set<String> selectedIds;
  final bool isImporting;
  final void Function(String id, bool selected) onToggle;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Xác nhận kết quả AI',
      trailing: Text(
        '${selectedIds.length}/${deadlines.length} đã chọn',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Column(
        children: [
          if (deadlines.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'Chưa có kết quả. Bấm "Quét và phân tích" để Gemini đọc Gmail.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            for (final deadline in deadlines) ...[
              _CandidateTile(
                deadline: deadline,
                selected: selectedIds.contains(deadline.id),
                onChanged: (selected) => onToggle(deadline.id, selected),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isImporting || selectedIds.isEmpty ? null : onConfirm,
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

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.deadline,
    required this.selected,
    required this.onChanged,
  });

  final Deadline deadline;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dueDate = deadline.dueDate;

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
                  deadline.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${dueDate == null ? 'Chưa có hạn' : DateFormat('dd/MM, HH:mm').format(dueDate)} • ${deadline.description ?? 'Gmail'}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (deadline.aiSuggestion?.isNotEmpty == true) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    deadline.aiSuggestion!,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _RiskBadge(riskLevel: deadline.riskLevel),
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.riskLevel});

  final RiskLevel riskLevel;

  @override
  Widget build(BuildContext context) {
    final color = switch (riskLevel) {
      RiskLevel.low => AppColors.success,
      RiskLevel.medium => AppColors.warning,
      RiskLevel.high => AppColors.danger,
      RiskLevel.extreme => AppColors.textPrimary,
    };

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        riskLevel.name,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
