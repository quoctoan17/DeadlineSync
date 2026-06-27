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
    _descriptionController = TextEditingController(
      text: initialDeadline?.description ?? '',
    );
    _dueDate =
        initialDeadline?.dueDate ??
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59);
    _priority = initialDeadline?.priority ?? PriorityLevel.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'Sửa deadline thủ công' : 'Thêm deadline',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Đóng',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _titleController,
                  autofocus: !_isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Tên deadline',
                    hintText: 'VD: Nộp bài tập lớn',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nhập tên deadline';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Môn học / ghi chú',
                    hintText: 'VD: Mobile Development',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(DateFormat('dd/MM/yyyy').format(_dueDate)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.schedule_outlined),
                        label: Text(DateFormat('HH:mm').format(_dueDate)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<PriorityLevel>(
                  initialValue: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Độ ưu tiên',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PriorityLevel.high,
                      child: Text('Cao'),
                    ),
                    DropdownMenuItem(
                      value: PriorityLevel.medium,
                      child: Text('Vừa'),
                    ),
                    DropdownMenuItem(
                      value: PriorityLevel.low,
                      child: Text('Thấp'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _priority = value);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: Icon(_isEditing ? Icons.save_outlined : Icons.add),
                    label: Text(_isEditing ? 'Lưu thay đổi' : 'Thêm deadline'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
    final result = initialDeadline == null
        ? Deadline(
            id: '',
            title: _titleController.text.trim(),
            dueDate: _dueDate,
            description: _descriptionController.text.trim(),
            source: DeadlineSource.manual,
            priority: _priority,
            createdAt: DateTime.now(),
          )
        : initialDeadline.copyWith(
            title: _titleController.text.trim(),
            dueDate: _dueDate,
            description: _descriptionController.text.trim(),
            priority: _priority,
          );

    Navigator.of(context).pop(result);
  }
}
