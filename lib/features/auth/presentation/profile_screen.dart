import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản của tôi'),
        centerTitle: true,
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Vui lòng đăng nhập"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Avatar lấy từ Google
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoUrl != null 
                      ? NetworkImage(user.photoUrl!) 
                      : null,
                  child: user.photoUrl == null 
                      ? const Icon(Icons.person, size: 50) 
                      : null,
                ),
                const SizedBox(height: 16),
                
                // Tên người dùng
                Text(
                  user.displayName ?? 'Người dùng',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey),
                ),
                
                const SizedBox(height: 32),
                const Divider(),
                
                // Các tùy chọn cài đặt
                _buildProfileOption(
                  icon: Icons.notifications_none_outlined,
                  title: 'Thông báo',
                  subtitle: 'Quản lý nhắc nhở deadline',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.security_outlined,
                  title: 'Quyền truy cập Gmail',
                  subtitle: 'Trạng thái: Đã kết nối',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.help_outline,
                  title: 'Trợ giúp & Phản hồi',
                  subtitle: 'Gửi thắc mắc cho nhóm phát triển',
                  onTap: () {},
                ),
                
                const SizedBox(height: 32),
                
                // Nút Đăng xuất - Gọi Controller của Toàn
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authControllerProvider).logout();
                      Navigator.of(context).pop(); // Quay về màn hình chính
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('ĐĂNG XUẤT', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi: $e")),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE64A19)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
