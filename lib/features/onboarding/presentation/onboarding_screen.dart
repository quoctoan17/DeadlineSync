import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({required this.onStart, super.key});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const _OnboardingHero(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quản lý deadline\nkhông còn rối',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              height: 1.12,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Đồng bộ, lọc, nhắc nhở và xem chi tiết deadline '
                        'Gmail trong một giao diện gọn gàng.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton.icon(
                        onPressed: onStart,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Bắt đầu'),
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

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 292,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _HeroShapePainter()),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DeadlineSync',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Một app cho tất cả deadline từ Gmail và cuộc sống.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 42,
            right: 38,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FloatingDeadlineCard(
                  title: 'Mobile App UI',
                  meta: 'Hôm nay, 23:59 • Gmail',
                  alignment: Alignment.centerLeft,
                ),
                SizedBox(height: AppSpacing.sm),
                _FloatingDeadlineCard(
                  title: 'Họp nhóm',
                  meta: 'Ngày mai, 09:00 • Thủ công',
                  alignment: Alignment.centerRight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingDeadlineCard extends StatelessWidget {
  const _FloatingDeadlineCard({
    required this.title,
    required this.meta,
    required this.alignment,
  });

  final String title;
  final String meta;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.gmailRed,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroShapePainter extends CustomPainter {
  const _HeroShapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()..color = AppColors.outlookBlue;
    final orangePaint = Paint()..color = AppColors.gmailRed;
    final palePaint = Paint()..color = const Color(0xFFEAF7F8);

    canvas.drawRect(Offset.zero & size, bluePaint);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.32),
      58,
      orangePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.28),
      56,
      palePaint,
    );

    final wavePath = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.68,
        size.width * 0.62,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.87,
        size.width,
        size.height * 0.72,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wavePath, Paint()..color = AppColors.background);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
