import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../deadline/domain/entities/deadline.dart';

enum DashboardSourceFilter { all, gmail, manual }

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

final manualDeadlinesProvider =
    StateNotifierProvider<ManualDeadlineNotifier, List<Deadline>>(
      (ref) => ManualDeadlineNotifier(),
    );

final mergedDeadlinesProvider = Provider<List<Deadline>>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final manualDeadlines = ref.watch(manualDeadlinesProvider);

  return [
    Deadline(
      id: 'gmail-mobile-ui',
      title: 'Nộp bài Mobile App UI',
      dueDate: today.add(const Duration(hours: 23, minutes: 59)),
      description: 'Mobile Development',
      source: DeadlineSource.gmail,
      priority: PriorityLevel.high,
      riskLevel: RiskLevel.high,
      aiSuggestion: 'Nên xử lý trước vì deadline trong hôm nay.',
      createdAt: today.subtract(const Duration(days: 4)),
    ),
    Deadline(
      id: 'manual-team-meeting',
      title: 'Họp nhóm DeadlineSync',
      dueDate: today.add(const Duration(days: 1, hours: 9)),
      description: 'Thống nhất demo và phân công fix bug',
      source: DeadlineSource.manual,
      priority: PriorityLevel.medium,
      riskLevel: RiskLevel.medium,
      createdAt: today.subtract(const Duration(days: 2)),
    ),
    Deadline(
      id: 'gmail-clean-architecture',
      title: 'Quiz Clean Architecture',
      dueDate: today.add(const Duration(days: 2, hours: 20)),
      description: 'Software Design',
      source: DeadlineSource.gmail,
      priority: PriorityLevel.medium,
      riskLevel: RiskLevel.medium,
      createdAt: today.subtract(const Duration(days: 3)),
    ),
    Deadline(
      id: 'gmail-project-demo',
      title: 'Demo tiến độ dự án',
      dueDate: today.add(const Duration(days: 4, hours: 14)),
      description: 'Email từ giảng viên Mobile App',
      source: DeadlineSource.gmail,
      priority: PriorityLevel.high,
      riskLevel: RiskLevel.high,
      aiSuggestion: 'Chuẩn bị bản demo trước ít nhất một ngày.',
      createdAt: today.subtract(const Duration(days: 1)),
    ),
    Deadline(
      id: 'gmail-final-report',
      title: 'Nộp báo cáo cuối kỳ',
      dueDate: today.add(const Duration(days: 7, hours: 22)),
      description: 'Project Management',
      source: DeadlineSource.gmail,
      priority: PriorityLevel.low,
      riskLevel: RiskLevel.low,
      createdAt: today,
    ),
    ...manualDeadlines,
  ];
});

final visibleDeadlinesProvider = Provider<List<Deadline>>((ref) {
  final filter = ref.watch(dashboardSourceFilterProvider);
  final dateFilter = ref.watch(dashboardDateFilterProvider);
  final priorityFilter = ref.watch(dashboardPriorityFilterProvider);
  final sortMode = ref.watch(dashboardSortModeProvider);
  final searchQuery = ref
      .watch(dashboardSearchQueryProvider)
      .trim()
      .toLowerCase();
  final deadlines = ref
      .watch(mergedDeadlinesProvider)
      .where((deadline) {
        final matchesSource = switch (filter) {
          DashboardSourceFilter.all => true,
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
    DeadlineSource.gmail => 'gmail google email',
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

class ManualDeadlineNotifier extends StateNotifier<List<Deadline>> {
  ManualDeadlineNotifier() : super(const []);

  void addDeadline({
    required String title,
    required DateTime dueDate,
    required String description,
    required PriorityLevel priority,
  }) {
    final now = DateTime.now();

    state = [
      ...state,
      Deadline(
        id: 'manual-${now.microsecondsSinceEpoch}',
        title: title.trim(),
        dueDate: dueDate,
        description: description.trim().isEmpty ? null : description.trim(),
        source: DeadlineSource.manual,
        priority: priority,
        createdAt: now,
      ),
    ];
  }

  void updateDeadline(Deadline updatedDeadline) {
    state = [
      for (final deadline in state)
        if (deadline.id == updatedDeadline.id) updatedDeadline else deadline,
    ];
  }

  void deleteDeadline(String id) {
    state = state
        .where((deadline) => deadline.id != id)
        .toList(growable: false);
  }
}
