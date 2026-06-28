import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../deadline/domain/entities/deadline.dart';
import '../providers/dashboard_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final deadlinesAsync = ref.watch(mergedDeadlinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch deadline')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: deadlinesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text('Không tải được lịch: $error'),
                ),
              ),
              data: (deadlines) {
                final deadlinesByDay = _groupByDay(deadlines);
                final selectedMonthDeadlines = deadlines
                    .where((deadline) {
                      final dueDate = deadline.dueDate;
                      return dueDate != null &&
                          dueDate.year == _visibleMonth.year &&
                          dueDate.month == _visibleMonth.month;
                    })
                    .toList(growable: false);

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _CalendarHeader(
                      month: _visibleMonth,
                      onPrevious: () => setState(() {
                        _visibleMonth = DateTime(
                          _visibleMonth.year,
                          _visibleMonth.month - 1,
                        );
                      }),
                      onNext: () => setState(() {
                        _visibleMonth = DateTime(
                          _visibleMonth.year,
                          _visibleMonth.month + 1,
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _MonthGrid(
                      month: _visibleMonth,
                      deadlinesByDay: deadlinesByDay,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _RiskLegend(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Deadline trong tháng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (selectedMonthDeadlines.isEmpty)
                      const Text('Tháng này chưa có deadline.')
                    else
                      for (final deadline in selectedMonthDeadlines) ...[
                        _CalendarDeadlineTile(deadline: deadline),
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

  Map<DateTime, List<Deadline>> _groupByDay(List<Deadline> deadlines) {
    final result = <DateTime, List<Deadline>>{};
    for (final deadline in deadlines) {
      final dueDate = deadline.dueDate;
      if (dueDate == null) continue;

      final day = DateTime(dueDate.year, dueDate.month, dueDate.day);
      result.putIfAbsent(day, () => []).add(deadline);
    }
    return result;
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Tháng trước',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            'Tháng ${month.month}/${month.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Tháng sau',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.deadlinesByDay});

  final DateTime month;
  final Map<DateTime, List<Deadline>> deadlinesByDay;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmptyDays = firstDay.weekday - 1;
    final totalCells = leadingEmptyDays + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              _WeekdayLabel('T2'),
              _WeekdayLabel('T3'),
              _WeekdayLabel('T4'),
              _WeekdayLabel('T5'),
              _WeekdayLabel('T6'),
              _WeekdayLabel('T7'),
              _WeekdayLabel('CN'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var row = 0; row < rowCount; row++)
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  _buildDayCell(row * 7 + col, leadingEmptyDays),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int cellIndex, int leadingEmptyDays) {
    final dayNumber = cellIndex - leadingEmptyDays + 1;
    if (dayNumber < 1 ||
        dayNumber > DateTime(month.year, month.month + 1, 0).day) {
      return const Expanded(child: SizedBox(height: 58));
    }

    final day = DateTime(month.year, month.month, dayNumber);
    final dayDeadlines = deadlinesByDay[day] ?? const [];
    final strongestRisk = _strongestRisk(dayDeadlines);

    return Expanded(
      child: Container(
        height: 58,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _isToday(day) ? AppColors.outlookSoft : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isToday(day) ? AppColors.outlookBlue : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNumber',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (strongestRisk == null)
              const SizedBox(height: 7)
            else
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _riskColor(strongestRisk),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  RiskLevel? _strongestRisk(List<Deadline> deadlines) {
    if (deadlines.isEmpty) return null;
    return deadlines
        .map((deadline) => deadline.riskLevel)
        .reduce(
          (left, right) =>
              _riskWeight(left) >= _riskWeight(right) ? left : right,
        );
  }

  int _riskWeight(RiskLevel riskLevel) {
    return switch (riskLevel) {
      RiskLevel.low => 1,
      RiskLevel.medium => 2,
      RiskLevel.high => 3,
      RiskLevel.extreme => 4,
    };
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RiskLegend extends StatelessWidget {
  const _RiskLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _LegendItem(color: AppColors.success, label: 'Rủi ro thấp'),
        _LegendItem(color: AppColors.warning, label: 'Rủi ro vừa'),
        _LegendItem(color: AppColors.danger, label: 'Rủi ro cao'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _CalendarDeadlineTile extends StatelessWidget {
  const _CalendarDeadlineTile({required this.deadline});

  final Deadline deadline;

  @override
  Widget build(BuildContext context) {
    final dueDate = deadline.dueDate;

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
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _riskColor(deadline.riskLevel),
              shape: BoxShape.circle,
            ),
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  dueDate == null
                      ? 'Chưa có hạn'
                      : DateFormat('dd/MM/yyyy, HH:mm').format(dueDate),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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

Color _riskColor(RiskLevel riskLevel) {
  return switch (riskLevel) {
    RiskLevel.low => AppColors.success,
    RiskLevel.medium => AppColors.warning,
    RiskLevel.high => AppColors.danger,
    RiskLevel.extreme => AppColors.textPrimary,
  };
}
