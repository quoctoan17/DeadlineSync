import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/deadline.dart';

class ManualDeadlineFormSheet extends StatefulWidget {
  const ManualDeadlineFormSheet({this.initialDeadline, super.key});

  final Deadline? initialDeadline;

  @override
  State<ManualDeadlineFormSheet> createState() =>
      _ManualDeadlineFormSheetState();
}

class _ManualDeadlineFormSheetState extends State<ManualDeadlineFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late final TextEditingController _descriptionController;
  late DateTime _dueDate;
  late PriorityLevel _priority;

  bool get _isEditing => widget.initialDeadline != null;

  @override
  void initState() {
    super.initState();
    final initialDeadline = widget.initialDeadline;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    _titleController = TextEditingController(
      text: initialDeadline?.title ?? '',
    );
    _subjectController = TextEditingController(
      text: initialDeadline?.description ?? '',
    );
    _descriptionController = TextEditingController(
      text: '', // Ghi chú riêng nếu cần, hiện tại map vào description
    );
    _dueDate =
        initialDeadline?.dueDate ??
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59);
    _priority = initialDeadline?.priority ?? PriorityLevel.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Thêm deadline',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ],
                ),
                const Divider(height: 32),
                
                _buildLabel('Tiêu đề'),
                TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration('VD: Nộp báo cáo nhóm'),
                  validator: (value) =>
                      (value?.isEmpty ?? true) ? 'Vui lòng nhập tiêu đề' : null,
                ),
                
                const SizedBox(height: AppSpacing.md),
                _buildLabel('Môn học / Dự án'),
                TextFormField(
                  controller: _subjectController,
                  decoration: _buildInputDecoration('Mobile Development'),
                ),
                
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Ngày hết hạn'),
                          InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: _buildInputDecoration(''),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(_dueDate),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Giờ'),
                          InkWell(
                            onTap: _pickTime,
                            child: InputDecorator(
                              decoration: _buildInputDecoration(''),
                              child: Text(DateFormat('HH:mm').format(_dueDate)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.lg),
                _buildLabel('Ưu tiên'),
                _buildPrioritySelector(),
                
                const SizedBox(height: AppSpacing.md),
                _buildLabel('Ghi chú'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _buildInputDecoration(
                    'Thêm mô tả deadline hoặc link tài liệu...',
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.canvasOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Lưu deadline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFC1C1C1), fontSize: 15),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.canvasOrange),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    final (label, color) = switch (_priority) {
      PriorityLevel.low => ('Low - không vội', AppColors.success),
      PriorityLevel.medium => ('Medium - bình thường', AppColors.warning),
      PriorityLevel.high => ('High - cần nhắc nhiều lần', AppColors.canvasOrange),
    };

    return InkWell(
      onTap: _showPriorityPicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showPriorityPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: PriorityLevel.values.map((p) {
              return ListTile(
                title: Text(p.name.toUpperCase()),
                onTap: () {
                  setState(() => _priority = p);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (pickedDate == null) return;
    setState(() {
      _dueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _dueDate.hour,
        _dueDate.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );

    if (pickedTime == null) return;
    setState(() {
      _dueDate = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final initialDeadline = widget.initialDeadline;
    final now = DateTime.now();
    final description = _subjectController.text.trim();
    final notes = _descriptionController.text.trim();
    final fullDescription = notes.isEmpty ? description : '$description\n$notes';

    final result = initialDeadline == null
        ? Deadline(
            id: 'manual-${now.microsecondsSinceEpoch}',
            title: _titleController.text.trim(),
            dueDate: _dueDate,
            description: fullDescription,
            source: DeadlineSource.manual,
            priority: _priority,
            createdAt: now,
            updatedAt: now,
          )
        : initialDeadline.copyWith(
            title: _titleController.text.trim(),
            dueDate: _dueDate,
            description: fullDescription,
            priority: _priority,
            updatedAt: now,
          );

    Navigator.of(context).pop(result);
  }
}
