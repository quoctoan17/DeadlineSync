import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deadline_sync/main.dart';

void main() {
  testWidgets('merged dashboard renders Canvas and Outlook deadlines', (
    tester,
  ) async {
    await tester.pumpWidget(const DeadlineSyncApp());

    expect(find.text('DeadlineSync'), findsOneWidget);
    expect(find.text('5 deadline sắp tới'), findsOneWidget);
    expect(find.text('Nộp bài Mobile App UI'), findsOneWidget);
    expect(find.text('Họp nhóm DeadlineSync'), findsOneWidget);
    expect(find.text('Deadline đã đồng bộ'), findsOneWidget);
  });

  testWidgets('source chips filter the merged deadline list', (tester) async {
    await tester.pumpWidget(const DeadlineSyncApp());

    await tester.tap(find.text('Canvas').first);
    await tester.pump();

    expect(find.text('Nộp bài Mobile App UI'), findsOneWidget);
    expect(find.text('Họp nhóm DeadlineSync'), findsNothing);
    expect(find.text('3 mục'), findsOneWidget);

    await tester.tap(find.text('Outlook').first);
    await tester.pump();

    expect(find.text('Nộp bài Mobile App UI'), findsNothing);
    expect(find.text('Họp nhóm DeadlineSync'), findsOneWidget);
    expect(find.text('2 mục'), findsOneWidget);
  });

  testWidgets('search input filters deadlines by title or subject', (
    tester,
  ) async {
    await tester.pumpWidget(const DeadlineSyncApp());

    await tester.enterText(find.byType(TextField), 'quiz');
    await tester.pump();

    expect(find.text('Quiz Clean Architecture'), findsOneWidget);
    expect(find.text('Nộp bài Mobile App UI'), findsNothing);
    expect(find.text('1 mục'), findsOneWidget);
  });

  testWidgets('date and priority chips narrow the dashboard results', (
    tester,
  ) async {
    await tester.pumpWidget(const DeadlineSyncApp());

    await tester.tap(find.text('Hôm nay'));
    await tester.pump();

    expect(find.text('Nộp bài Mobile App UI'), findsOneWidget);
    expect(find.text('Họp nhóm DeadlineSync'), findsNothing);
    expect(find.text('1 mục'), findsOneWidget);

    await tester.tap(find.text('Mọi hạn'));
    await tester.pump();
    await tester.tap(find.text('Cao'));
    await tester.pump();

    expect(find.text('Nộp bài Mobile App UI'), findsOneWidget);
    expect(find.text('Demo tiến độ dự án'), findsOneWidget);
    expect(find.text('Quiz Clean Architecture'), findsNothing);
    expect(find.text('2 mục'), findsOneWidget);
  });

  testWidgets('manual deadlines can be created edited and deleted', (
    tester,
  ) async {
    await tester.pumpWidget(const DeadlineSyncApp());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Bài tập thủ công',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Cơ sở dữ liệu');
    await tester.tap(find.widgetWithText(FilledButton, 'Thêm deadline'));
    await tester.pumpAndSettle();

    expect(find.text('Bài tập thủ công'), findsOneWidget);
    expect(find.text('Manual'), findsOneWidget);
    expect(find.text('6 deadline sắp tới'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sửa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Bài tập SQLite');
    await tester.tap(find.widgetWithText(FilledButton, 'Lưu thay đổi'));
    await tester.pumpAndSettle();

    expect(find.text('Bài tập SQLite'), findsOneWidget);
    expect(find.text('Bài tập thủ công'), findsNothing);

    await tester.tap(find.byIcon(Icons.more_vert).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await tester.pumpAndSettle();

    expect(find.text('Bài tập SQLite'), findsNothing);
    expect(find.text('5 deadline sắp tới'), findsOneWidget);
  });

  testWidgets('deadline detail view shows metadata and saves notes', (
    tester,
  ) async {
    await tester.pumpWidget(const DeadlineSyncApp());

    await tester.tap(find.text('Nộp bài Mobile App UI'));
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết deadline'), findsOneWidget);
    expect(find.text('Hạn nộp'), findsOneWidget);
    expect(find.text('Ưu tiên'), findsOneWidget);
    expect(find.text('Ghi chú'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Nhớ kiểm tra rubric');
    await tester.tap(find.widgetWithText(FilledButton, 'Lưu ghi chú'));
    await tester.pumpAndSettle();

    expect(find.text('Đã lưu ghi chú'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nộp bài Mobile App UI'));
    await tester.pumpAndSettle();

    expect(find.text('Nhớ kiểm tra rubric'), findsOneWidget);
  });

  testWidgets('AI import review opens from sync tab and confirms candidates', (
    tester,
  ) async {
    await tester.pumpWidget(const DeadlineSyncApp());

    await tester.tap(find.text('Sync'));
    await tester.pumpAndSettle();

    expect(find.text('Import bằng AI'), findsOneWidget);
    expect(find.text('Thiết lập import'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Quét và phân tích'));
    await tester.pumpAndSettle();

    expect(find.text('Xác nhận kết quả AI'), findsOneWidget);
    expect(find.text('Nộp đề cương giữa kỳ'), findsOneWidget);
    expect(find.text('2/3 đã chọn'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(FilledButton, 'Import deadline đã chọn'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đã xác nhận 2 deadline từ AI'), findsOneWidget);
  });

  testWidgets('AI suggestion screen applies and hides suggestions', (
    tester,
  ) async {
    await tester.pumpWidget(const DeadlineSyncApp());

    await tester.tap(find.byIcon(Icons.auto_awesome));
    await tester.pumpAndSettle();

    expect(find.text('Gợi ý AI'), findsOneWidget);
    expect(find.text('AI Suggestion'), findsOneWidget);
    expect(find.text('Làm Mobile App UI trước'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Áp dụng').first);
    await tester.pumpAndSettle();

    expect(find.text('Đã áp dụng: Làm Mobile App UI trước'), findsOneWidget);
    expect(find.text('Đã áp dụng'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Ẩn').first);
    await tester.pumpAndSettle();

    expect(find.text('2 gợi ý'), findsOneWidget);
  });
}
