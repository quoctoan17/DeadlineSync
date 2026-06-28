import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/deadline_card.dart';
import '../../../../shared/widgets/deadline_empty_state.dart';
import '../../../../shared/widgets/deadline_filter_chip.dart';
import '../../../../shared/widgets/deadline_search_bar.dart';
import '../../../../shared/widgets/deadline_summary_card.dart';
import '../../../auth/presentation/profile_screen.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../ai_import/presentation/screens/ai_import_review_screen.dart';
import '../../../ai_suggestion/presentation/screens/ai_suggestion_screen.dart';
import '../../../deadline/data/providers/deadline_database_providers.dart';
import '../../../deadline/domain/entities/deadline.dart';
import '../../../deadline/presentation/screens/deadline_detail_screen.dart';
import '../../../deadline/presentation/widgets/manual_deadline_form_sheet.dart';
import 'calendar_screen.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDeadlinesAsync = ref.watch(mergedDeadlinesProvider);
    final visibleDeadlinesAsync = ref.watch(visibleDeadlinesProvider);
    final allDeadlines = allDeadlinesAsync.value ?? const <Deadline>[];
    final visibleDeadlines = visibleDeadlinesAsync.value ?? const <Deadline>[];
    final selectedFilter = ref.watch(dashboardSourceFilterProvider);
    final selectedDateFilter = ref.watch(dashboardDateFilterProvider);
    final selectedPriorityFilter = ref.watch(dashboardPriorityFilterProvider);
    final selectedSortMode = ref.watch(dashboardSortModeProvider);
    final searchQuery = ref.watch(dashboardSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DeadlineSync'),
        actions: [
          IconButton(
            tooltip: 'Gợi ý AI',
            onPressed: () => _openAiSuggestion(context),
            icon: const Icon(Icons.auto_awesome),
          ),
          IconButton(
            tooltip: 'Đồng bộ deadline',
            onPressed: () => _refreshDeadlines(ref),
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              await ref.read(authControllerProvider).logout();
            },
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshDeadlines(ref),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  DeadlineSearchBar(
                    value: searchQuery,
                    onChanged: (value) =>
                        ref.read(dashboardSearchQueryProvider.notifier).state =
                            value,
                    onClear: () =>
                        ref.read(dashboardSearchQueryProvider.notifier).state =
                            '',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        DeadlineFilterChip(
                          label: 'Tất cả',
                          color: AppColors.textPrimary,
                          isSelected:
                              selectedFilter == DashboardSourceFilter.all,
                          onTap: () =>
                              _selectFilter(ref, DashboardSourceFilter.all),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DeadlineFilterChip(
                          label: 'Canvas',
                          color: AppColors.canvasOrange,
                          isSelected:
                              selectedFilter == DashboardSourceFilter.canvas,
                          onTap: () =>
                              _selectFilter(ref, DashboardSourceFilter.canvas),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DeadlineFilterChip(
                          label: 'Outlook',
                          color: AppColors.outlookBlue,
                          isSelected:
                              selectedFilter == DashboardSourceFilter.outlook,
                          onTap: () =>
                              _selectFilter(ref, DashboardSourceFilter.outlook),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DeadlineFilterChip(
                          label: 'Gmail',
                          color: AppColors.gmailRed,
                          isSelected:
                              selectedFilter == DashboardSourceFilter.gmail,
                          onTap: () =>
                              _selectFilter(ref, DashboardSourceFilter.gmail),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DeadlineFilterChip(
                          label: 'Manual',
                          color: AppColors.manualPurple,
                          isSelected:
                              selectedFilter == DashboardSourceFilter.manual,
                          onTap: () =>
                              _selectFilter(ref, DashboardSourceFilter.manual),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        DeadlineFilterChip(
                          label: 'Mọi hạn',
                          color: AppColors.textPrimary,
                          isSelected:
                              selectedDateFilter == DashboardDateFilter.all,
                          onTap: () =>
                              _selectDateFilter(ref, DashboardDateFilter.all),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DeadlineFilterChip(
                          label: 'Hôm nay',
                          color: AppColors.danger,
                          isSelected:
                              selectedDateFilter == DashboardDateFilter.today,
                          onTap: () =>
                              _selectDateFilter(ref, DashboardDateFilter.today),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DeadlineFilterChip(
                          label: 'Ngày mai',
                          color: AppColors.warning,
                          isSelected:
                              selectedDateFilter ==
                              DashboardDateFilter.tomorrow,
                          onTap: () => _selectDateFilter(
                            ref,
                            DashboardDateFilter.tomorrow,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DeadlineFilterChip(
                          label: 'Tuần này',
                          color: AppColors.success,
                          isSelected:
                              selectedDateFilter ==
                              DashboardDateFilter.thisWeek,
                          onTap: () => _selectDateFilter(
                            ref,
                            DashboardDateFilter.thisWeek,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        DeadlineFilterChip(
                          label: 'Mọi ưu tiên',
                          color: AppColors.textPrimary,
                          isSelected:
                              selectedPriorityFilter ==
                              DashboardPriorityFilter.all,
                          onTap: () => _selectPriorityFilter(
                            ref,
                            DashboardPriorityFilter.all,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DeadlineFilterChip(
                          label: 'Cao',
                          color: AppColors.danger,
                          isSelected:
                              selectedPriorityFilter ==
                              DashboardPriorityFilter.high,
                          onTap: () => _selectPriorityFilter(
                            ref,
                            DashboardPriorityFilter.high,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DeadlineFilterChip(
                          label: 'Vừa',
                          color: AppColors.warning,
                          isSelected:
                              selectedPriorityFilter ==
                              DashboardPriorityFilter.medium,
                          onTap: () => _selectPriorityFilter(
                            ref,
                            DashboardPriorityFilter.medium,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DeadlineFilterChip(
                          label: 'Thấp',
                          color: AppColors.success,
                          isSelected:
                              selectedPriorityFilter ==
                              DashboardPriorityFilter.low,
                          onTap: () => _selectPriorityFilter(
                            ref,
                            DashboardPriorityFilter.low,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DeadlineSummaryCard(
                    totalCount: allDeadlines.length,
                    urgentCount: allDeadlines
                        .where((item) => item.priority == PriorityLevel.high)
                        .length,
                    canvasCount: allDeadlines
                        .where((item) => item.source == DeadlineSource.canvas)
                        .length,
                    outlookCount: allDeadlines
                        .where((item) => item.source == DeadlineSource.outlook)
                        .length,
                    gmailCount: allDeadlines
                        .where((item) => item.source == DeadlineSource.gmail)
                        .length,
                    manualCount: allDeadlines
                        .where((item) => item.source == DeadlineSource.manual)
                        .length,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Deadline đã đồng bộ',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${visibleDeadlines.length} mục',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      PopupMenuButton<DashboardSortMode>(
                        tooltip: 'Sắp xếp deadline',
                        initialValue: selectedSortMode,
                        onSelected: (mode) =>
                            ref.read(dashboardSortModeProvider.notifier).state =
                                mode,
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: DashboardSortMode.dueSoon,
                            child: Text('Hạn gần nhất'),
                          ),
                          const PopupMenuItem(
                            value: DashboardSortMode.priorityHigh,
                            child: Text('Ưu tiên cao'),
                          ),
                          const PopupMenuItem(
                            value: DashboardSortMode.source,
                            child: Text('Nguồn'),
                          ),
                        ],
                        child: _SortButton(
                          label: _sortModeLabel(selectedSortMode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ..._buildDeadlineContent(
                    context,
                    ref,
                    visibleDeadlinesAsync,
                    visibleDeadlines,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              _openCalendar(context);
            case 2:
              _openManualDeadlineSheet(context, ref);
            case 3:
              _openAiImportReview(context, ref);
            case 4:
              _openProfile(context);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          NavigationDestination(icon: Icon(Icons.sync), label: 'Sync'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openManualDeadlineSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Thêm deadline'),
      ),
    );
  }

  void _selectFilter(WidgetRef ref, DashboardSourceFilter filter) {
    ref.read(dashboardSourceFilterProvider.notifier).state = filter;
  }

  void _selectDateFilter(WidgetRef ref, DashboardDateFilter filter) {
    ref.read(dashboardDateFilterProvider.notifier).state = filter;
  }

  void _selectPriorityFilter(WidgetRef ref, DashboardPriorityFilter filter) {
    ref.read(dashboardPriorityFilterProvider.notifier).state = filter;
  }

  String _sortModeLabel(DashboardSortMode sortMode) {
    return switch (sortMode) {
      DashboardSortMode.dueSoon => 'Hạn gần nhất',
      DashboardSortMode.priorityHigh => 'Ưu tiên cao',
      DashboardSortMode.source => 'Nguồn',
    };
  }

  Future<void> _refreshDeadlines(WidgetRef ref) async {
    ref.invalidate(mergedDeadlinesProvider);
    ref.invalidate(visibleDeadlinesProvider);
    await ref.read(mergedDeadlinesProvider.future);
  }

  List<Widget> _buildDeadlineContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Deadline>> visibleDeadlinesAsync,
    List<Deadline> visibleDeadlines,
  ) {
    return visibleDeadlinesAsync.when(
      loading: () => [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (error, _) => [
        DeadlineEmptyState(
          icon: Icons.error_outline,
          title: 'Không tải được deadline',
          message: '$error',
        ),
      ],
      data: (_) {
        if (visibleDeadlines.isEmpty) {
          return const [
            DeadlineEmptyState(
              icon: Icons.event_available_outlined,
              title: 'Không có deadline',
              message: 'Nguồn đã chọn chưa có deadline sắp tới.',
            ),
          ];
        }

        return _buildDeadlineGroups(context, ref, visibleDeadlines);
      },
    );
  }

  List<Widget> _buildDeadlineGroups(
    BuildContext context,
    WidgetRef ref,
    List<Deadline> deadlines,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final groups = <String, List<Deadline>>{};

    for (final deadline in deadlines) {
      final dueDate = deadline.dueDate;
      final label = dueDate == null
          ? 'Chưa có hạn'
          : _sectionLabel(today, dueDate);
      groups.putIfAbsent(label, () => []).add(deadline);
    }

    return [
      for (final entry in groups.entries) ...[
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            entry.key,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final deadline in entry.value) ...[
          _DeadlineListItem(
            deadline: deadline,
            onOpen: () => _openDeadlineDetail(context, deadline),
            onEdit: deadline.source == DeadlineSource.manual
                ? () => _openManualDeadlineSheet(context, ref, deadline)
                : null,
            onDelete: deadline.source == DeadlineSource.manual
                ? () => _confirmDeleteManualDeadline(context, ref, deadline)
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    ];
  }

  String _sectionLabel(DateTime today, DateTime dueDate) {
    final date = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = date.difference(today).inDays;

    if (difference == 0) return 'Hôm nay';
    if (difference == 1) return 'Ngày mai';
    if (difference <= 7) return 'Tuần này';
    return 'Sắp tới';
  }

  Future<void> _openManualDeadlineSheet(
    BuildContext context,
    WidgetRef ref, [
    Deadline? initialDeadline,
  ]) async {
    final result = await showModalBottomSheet<Deadline>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return ManualDeadlineFormSheet(initialDeadline: initialDeadline);
      },
    );

    if (result == null) return;

    try {
      await ref.read(deadlineRepositoryProvider).saveDeadline(result);
      ref.invalidate(mergedDeadlinesProvider);
      ref.invalidate(visibleDeadlinesProvider);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không lưu được deadline: $error')),
      );
    }
  }

  Future<void> _confirmDeleteManualDeadline(
    BuildContext context,
    WidgetRef ref,
    Deadline deadline,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa deadline?'),
          content: Text(
            'Deadline "${deadline.title}" sẽ bị xóa khỏi danh sách.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    try {
      await ref.read(deadlineRepositoryProvider).deleteDeadline(deadline.id);
      ref.invalidate(mergedDeadlinesProvider);
      ref.invalidate(visibleDeadlinesProvider);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không xóa được deadline: $error')),
      );
    }
  }

  void _openDeadlineDetail(BuildContext context, Deadline deadline) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DeadlineDetailScreen(deadline: deadline),
      ),
    );
  }

  Future<void> _openAiImportReview(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const AiImportReviewScreen(),
      ),
    );
    if (!context.mounted) return;
    ref.invalidate(mergedDeadlinesProvider);
    ref.invalidate(visibleDeadlinesProvider);
  }

  void _openCalendar(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const CalendarScreen()),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const ProfileScreen()),
    );
  }

  void _openAiSuggestion(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const AiSuggestionScreen()),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swap_vert, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _DeadlineListItem extends StatelessWidget {
  const _DeadlineListItem({
    required this.deadline,
    this.onOpen,
    this.onEdit,
    this.onDelete,
  });

  final Deadline deadline;
  final VoidCallback? onOpen;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor(deadline.source);
    final backgroundColor = _backgroundColor(deadline.source);
    final dueDate = deadline.dueDate;
    final dateLabel = dueDate == null
        ? 'Chưa có hạn'
        : DateFormat('dd/MM, HH:mm').format(dueDate);

    return DeadlineCard(
      title: deadline.title,
      meta: '$dateLabel • ${deadline.description ?? 'Không có mô tả'}',
      source: _sourceLabel(deadline.source),
      accentColor: accentColor,
      sourceBackground: backgroundColor,
      isUrgent: deadline.priority == PriorityLevel.high,
      riskLabel: _riskLabel(deadline.riskLevel),
      riskColor: _riskColor(deadline.riskLevel),
      aiSuggestion: deadline.aiSuggestion,
      onTap: onOpen,
      trailing: onEdit == null || onDelete == null
          ? null
          : PopupMenuButton<_ManualDeadlineAction>(
              tooltip: 'Tùy chọn deadline',
              onSelected: (action) {
                switch (action) {
                  case _ManualDeadlineAction.edit:
                    onEdit?.call();
                  case _ManualDeadlineAction.delete:
                    onDelete?.call();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _ManualDeadlineAction.edit,
                  child: Text('Sửa'),
                ),
                PopupMenuItem(
                  value: _ManualDeadlineAction.delete,
                  child: Text('Xóa'),
                ),
              ],
            ),
    );
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

  String _riskLabel(RiskLevel riskLevel) {
    return switch (riskLevel) {
      RiskLevel.low => 'Thấp',
      RiskLevel.medium => 'Vừa',
      RiskLevel.high => 'Cao',
      RiskLevel.extreme => 'Rất cao',
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
}

enum _ManualDeadlineAction { edit, delete }
