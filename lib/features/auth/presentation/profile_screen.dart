import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'help_screen.dart';
import 'providers/auth_provider.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: authState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Lỗi: $error')),
              data: (user) {
                if (user == null) {
                  return const Center(child: Text('Vui lòng đăng nhập Google'));
                }

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.white,
                            backgroundImage: user.photoUrl == null
                                ? null
                                : NetworkImage(user.photoUrl!),
                            child: user.photoUrl == null
                                ? const Icon(
                                    Icons.person,
                                    color: AppColors.textPrimary,
                                    size: 42,
                                  )
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            user.displayName ?? 'Người dùng DeadlineSync',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            user.email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.border,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _ProfileOption(
                      icon: Icons.settings_outlined,
                      title: 'Cài đặt',
                      subtitle: 'Tùy chỉnh giao diện và đồng bộ',
                      onTap: () => _openSettings(context),
                    ),
                    _ProfileOption(
                      icon: Icons.notifications_none_outlined,
                      title: 'Thông báo',
                      subtitle: 'Quản lý nhắc nhở deadline',
                      onTap: () => _openSettings(context),
                    ),
                    _ProfileOption(
                      icon: Icons.security_outlined,
                      title: 'Quyền truy cập Gmail',
                      subtitle: 'Đã kết nối Google read-only',
                      onTap: () {},
                    ),
                    _ProfileOption(
                      icon: Icons.help_outline,
                      title: 'Trợ giúp',
                      subtitle: 'Hướng dẫn sử dụng và phản hồi',
                      onTap: () => _openHelp(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authControllerProvider).logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.logout, color: AppColors.danger),
                      label: const Text('Đăng xuất'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const SettingsScreen()),
    );
  }

  void _openHelp(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => const HelpScreen()));
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.outlookBlue),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
