import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../deadline/data/providers/deadline_database_providers.dart';
import '../../../deadline/domain/entities/deadline.dart';

enum DashboardSourceFilter { all, canvas, outlook, gmail, manual }

enum DashboardDateFilter { all, today, tomorrow, thisWeek }

enum DashboardPriorityFilter { all, high, medium, low }

enum DashboardSortMode { dueSoon, priorityHigh, source }

final dashboardSourceFilterProvider = StateProvider<DashboardSourceFilter>(
  (ref) => DashboardSourceFilter.all,
);

final dashboardDateFilterProvider = StateProvider<DashboardDateFilter>(
  (ref) => DashboardDateFilter.all,
);

final dashboardPriorityFilterProvider = StateProvider<DashboardPriorityFilter>(
  (ref) => DashboardPriorityFilter.all,
);

final dashboardSortModeProvider = StateProvider<DashboardSortMode>(
  (ref) => DashboardSortMode.dueSoon,
);

final dashboardSearchQueryProvider = StateProvider<String>((ref) => '');

final mergedDeadlinesProvider = FutureProvider<List<Deadline>>((ref) {
  return ref.watch(deadlineRepositoryProvider).getLocalDeadlines();
});

final visibleDeadlinesProvider = FutureProvider<List<Deadline>>((ref) async {
  final filter = ref.watch(dashboardSourceFilterProvider);
  final dateFilter = ref.watch(dashboardDateFilterProvider);
  final priorityFilter = ref.watch(dashboardPriorityFilterProvider);
  final sortMode = ref.watch(dashboardSortModeProvider);
  final searchQuery = ref
      .watch(dashboardSearchQueryProvider)
      .trim()
      .toLowerCase();
  final deadlines = (await ref.watch(mergedDeadlinesProvider.future))
      .where((deadline) {
        final matchesSource = switch (filter) {
          DashboardSourceFilter.all => true,
          DashboardSourceFilter.canvas =>
            deadline.source == DeadlineSource.canvas,
          DashboardSourceFilter.outlook =>
            deadline.source == DeadlineSource.outlook,
          DashboardSourceFilter.gmail =>
            deadline.source == DeadlineSource.gmail,
          DashboardSourceFilter.manual =>
            deadline.source == DeadlineSource.manual,
        };
        final matchesDate = _matchesDateFilter(deadline, dateFilter);
        final matchesPriority = switch (priorityFilter) {
          DashboardPriorityFilter.all => true,
          DashboardPriorityFilter.high =>
            deadline.priority == PriorityLevel.high,
          DashboardPriorityFilter.medium =>
            deadline.priority == PriorityLevel.medium,
          DashboardPriorityFilter.low => deadline.priority == PriorityLevel.low,
        };
        final matchesSearch =
            searchQuery.isEmpty || _searchText(deadline).contains(searchQuery);

        return matchesSource && matchesDate && matchesPriority && matchesSearch;
      })
      .toList(growable: false);

  deadlines.sort((left, right) {
    return switch (sortMode) {
      DashboardSortMode.dueSoon => _compareDueDate(left, right),
      DashboardSortMode.priorityHigh => _comparePriority(left, right),
      DashboardSortMode.source => _compareSource(left, right),
    };
  });

  return deadlines;
});

bool _matchesDateFilter(Deadline deadline, DashboardDateFilter filter) {
  if (filter == DashboardDateFilter.all) return true;

  final dueDate = deadline.dueDate;
  if (dueDate == null) return false;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final difference = dueDay.difference(today).inDays;

  return switch (filter) {
    DashboardDateFilter.all => true,
    DashboardDateFilter.today => difference == 0,
    DashboardDateFilter.tomorrow => difference == 1,
    DashboardDateFilter.thisWeek => difference >= 0 && difference <= 7,
  };
}

String _searchText(Deadline deadline) {
  final source = switch (deadline.source) {
    DeadlineSource.canvas => 'canvas',
    DeadlineSource.outlook => 'outlook',
    DeadlineSource.gmail => 'gmail google',
    DeadlineSource.manual => 'manual thủ công tự nhập',
  };

  return [
    deadline.title,
    deadline.description,
    source,
  ].whereType<String>().join(' ').toLowerCase();
}

int _compareDueDate(Deadline left, Deadline right) {
  final leftDate = left.dueDate ?? DateTime(9999);
  final rightDate = right.dueDate ?? DateTime(9999);
  return leftDate.compareTo(rightDate);
}

int _comparePriority(Deadline left, Deadline right) {
  final result = _priorityWeight(
    right.priority,
  ).compareTo(_priorityWeight(left.priority));

  if (result != 0) return result;
  return _compareDueDate(left, right);
}

int _compareSource(Deadline left, Deadline right) {
  final result = _sourceLabel(
    left.source,
  ).compareTo(_sourceLabel(right.source));
  if (result != 0) return result;
  return _compareDueDate(left, right);
}

int _priorityWeight(PriorityLevel priority) {
  return switch (priority) {
    PriorityLevel.high => 3,
    PriorityLevel.medium => 2,
    PriorityLevel.low => 1,
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
