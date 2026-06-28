import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _deadlineReminder = true;
  bool _aiReview = true;
  bool _autoSync = true;
  double _reminderHours = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const _SettingsHeader(),
                const SizedBox(height: AppSpacing.lg),
                _SwitchTile(
                  icon: Icons.notifications_none_outlined,
                  title: 'Nhắc deadline',
                  subtitle: 'Bật thông báo trước hạn nộp',
                  value: _deadlineReminder,
                  onChanged: (value) =>
                      setState(() => _deadlineReminder = value),
                ),
                _SwitchTile(
                  icon: Icons.auto_awesome,
                  title: 'AI review',
                  subtitle: 'Phân tích rủi ro sau khi import deadline',
                  value: _aiReview,
                  onChanged: (value) => setState(() => _aiReview = value),
                ),
                _SwitchTile(
                  icon: Icons.sync,
                  title: 'Tự đồng bộ',
                  subtitle: 'Đồng bộ dữ liệu khi có mạng',
                  value: _autoSync,
                  onChanged: (value) => setState(() => _autoSync = value),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhắc trước ${_reminderHours.round()} giờ',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Slider(
                        value: _reminderHours,
                        min: 1,
                        max: 24,
                        divisions: 23,
                        label: '${_reminderHours.round()} giờ',
                        onChanged: (value) =>
                            setState(() => _reminderHours = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

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
          Icon(Icons.tune, color: Colors.white, size: 30),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Tùy chỉnh cách DeadlineSync nhắc việc và đồng bộ',
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

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: SwitchListTile(
          secondary: Icon(icon, color: AppColors.outlookBlue),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(subtitle),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
