import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/deadline.dart';
import '../providers/deadline_notes_provider.dart';

class DeadlineDetailScreen extends ConsumerStatefulWidget {
  const DeadlineDetailScreen({required this.deadline, super.key});

  final Deadline deadline;

  @override
  ConsumerState<DeadlineDetailScreen> createState() =>
      _DeadlineDetailScreenState();
}

class _DeadlineDetailScreenState extends ConsumerState<DeadlineDetailScreen> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final savedNote = ref.read(deadlineNotesProvider)[widget.deadline.id] ?? '';
    if (_noteController.text != savedNote) {
      _noteController.text = savedNote;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deadline = widget.deadline;
    final accentColor = _accentColor(deadline.source);

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết deadline')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Container(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              deadline.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _SourceBadge(
                            label: _sourceLabel(deadline.source),
                            color: accentColor,
                            backgroundColor: _backgroundColor(deadline.source),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        deadline.description?.isNotEmpty == true
                            ? deadline.description!
                            : 'Không có mô tả',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _DetailInfoGrid(deadline: deadline),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _noteController,
                  minLines: 5,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    hintText: 'Thêm ghi chú cho deadline này...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Lưu ghi chú'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveNote() {
    ref
        .read(deadlineNotesProvider.notifier)
        .saveNote(widget.deadline.id, _noteController.text);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu ghi chú')));
  }
}

class _DetailInfoGrid extends StatelessWidget {
  const _DetailInfoGrid({required this.deadline});

  final Deadline deadline;

  @override
  Widget build(BuildContext context) {
    final dueDate = deadline.dueDate;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _InfoTile(
          icon: Icons.schedule_outlined,
          label: 'Hạn nộp',
          value: dueDate == null
              ? 'Chưa có hạn'
              : DateFormat('dd/MM/yyyy, HH:mm').format(dueDate),
        ),
        _InfoTile(
          icon: Icons.flag_outlined,
          label: 'Ưu tiên',
          value: _priorityLabel(deadline.priority),
        ),
        _InfoTile(
          icon: Icons.layers_outlined,
          label: 'Nguồn',
          value: _sourceLabel(deadline.source),
        ),
        _InfoTile(
          icon: Icons.event_available_outlined,
          label: 'Ngày tạo',
          value: DateFormat('dd/MM/yyyy').format(deadline.createdAt),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Color _accentColor(DeadlineSource source) {
  return switch (source) {
    DeadlineSource.canvas => AppColors.canvasOrange,
    DeadlineSource.outlook => AppColors.outlookBlue,
    DeadlineSource.gmail => AppColors.gmailRed,
    DeadlineSource.manual => AppColors.manualPurple,
  };
}

Color _backgroundColor(DeadlineSource source) {
  return switch (source) {
    DeadlineSource.canvas => AppColors.canvasSoft,
    DeadlineSource.outlook => AppColors.outlookSoft,
    DeadlineSource.gmail => AppColors.gmailSoft,
    DeadlineSource.manual => AppColors.manualSoft,
  };
}

String _sourceLabel(DeadlineSource source) {
  return switch (source) {
    DeadlineSource.canvas => 'Canvas',
    DeadlineSource.outlook => 'Outlook',
    DeadlineSource.gmail => 'Gmail',
    DeadlineSource.manual => 'Manual',
  };
}

String _priorityLabel(PriorityLevel priority) {
  return switch (priority) {
    PriorityLevel.high => 'Cao',
    PriorityLevel.medium => 'Vừa',
    PriorityLevel.low => 'Thấp',
  };
}
