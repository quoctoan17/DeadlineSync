import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class DeadlineSearchBar extends StatefulWidget {
  const DeadlineSearchBar({
    required this.value,
    required this.onChanged,
    this.onClear,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  State<DeadlineSearchBar> createState() => _DeadlineSearchBarState();
}

class _DeadlineSearchBarState extends State<DeadlineSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant DeadlineSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Tìm deadline, môn học, task...',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.textSecondary,
          ),
          suffixIcon: widget.value.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Xóa tìm kiếm',
                  onPressed: () {
                    _controller.clear();
                    widget.onClear?.call();
                    widget.onChanged('');
                  },
                  icon: const Icon(Icons.close, size: 18),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
