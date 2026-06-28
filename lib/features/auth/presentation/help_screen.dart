import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trợ giúp')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const [
                _HelpHeader(),
                SizedBox(height: AppSpacing.lg),
                _HelpItem(
                  icon: Icons.login,
                  title: 'Đăng nhập Google',
                  body:
                      'Dùng tài khoản Google để cấp quyền đọc Gmail phục vụ import deadline.',
                ),
                _HelpItem(
                  icon: Icons.sync,
                  title: 'Import deadline',
                  body:
                      'Vào Sync, chọn Import AI để quét email trong khoảng thời gian đã chọn.',
                ),
                _HelpItem(
                  icon: Icons.warning_amber_rounded,
                  title: 'Rủi ro AI',
                  body:
                      'AI đánh dấu rủi ro dựa trên hạn nộp, độ ưu tiên và mật độ deadline.',
                ),
                _HelpItem(
                  icon: Icons.edit_calendar_outlined,
                  title: 'Deadline thủ công',
                  body:
                      'Bấm Add ở thanh dưới để thêm deadline không đến từ email hay lịch.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpHeader extends StatelessWidget {
  const _HelpHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.support_agent, color: Colors.white, size: 30),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Hướng dẫn nhanh để dùng DeadlineSync',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.outlookBlue),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    body,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
