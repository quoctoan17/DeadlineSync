import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class DeadlineFilterChip extends StatelessWidget {
  const DeadlineFilterChip({
    required this.label,
    required this.color,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? AppColors.textPrimary : Colors.white;
    final foregroundColor = isSelected ? Colors.white : color;

    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.textPrimary : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
