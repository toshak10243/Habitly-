import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';

class AddEditHabitScreen extends StatefulWidget {
  final HabitProvider habitProvider;
  final Habit? habitToEdit;

  const AddEditHabitScreen({
    super.key,
    required this.habitProvider,
    this.habitToEdit,
  });

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late String _selectedCategory;
  late String _selectedIconKey;
  late int _selectedColorValue;
  late String _selectedFrequency;
  late List<int> _selectedWeekdays;
  late String _reminderTime;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final h = widget.habitToEdit;
    _isEditing = h != null;

    _nameController = TextEditingController(text: h?.name ?? '');
    _descController = TextEditingController(text: h?.description ?? '');
    _selectedCategory = h?.category ?? AppConstants.categories.first;
    _selectedIconKey = h?.iconKey ?? AppConstants.habitIcons.keys.first;
    _selectedColorValue = h?.colorValue ?? AppConstants.colorOptions.first;
    _selectedFrequency = h?.frequency ?? AppConstants.freqEveryday;
    _selectedWeekdays = h != null ? List.from(h.selectedWeekdays) : [1, 2, 3, 4, 5, 6, 7];
    _reminderTime = h?.reminderTime ?? '08:00 AM';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFrequency == AppConstants.freqWeekdays && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one active weekday.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (_isEditing) {
      final updated = widget.habitToEdit!.copyWith(
        name: name,
        description: desc,
        category: _selectedCategory,
        iconKey: _selectedIconKey,
        colorValue: _selectedColorValue,
        frequency: _selectedFrequency,
        selectedWeekdays: _selectedWeekdays,
        reminderTime: _reminderTime,
      );
      await widget.habitProvider.updateHabit(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit updated successfully!'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      final newHabit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: desc,
        category: _selectedCategory,
        iconKey: _selectedIconKey,
        colorValue: _selectedColorValue,
        createdAt: DateTime.now(),
        startDate: DateTime.now(),
        frequency: _selectedFrequency,
        selectedWeekdays: _selectedWeekdays,
        reminderTime: _reminderTime,
      );
      final success = await widget.habitProvider.addHabit(newHabit);
      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A habit with this name already exists!'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit created successfully!'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _pickReminderTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderTime = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'New Habit'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Habit Name Field
              const Text(
                'Habit Name *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Morning Meditation, Read Book',
                  prefixIcon: Icon(Icons.edit_outlined, color: AppTheme.textSecondary),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Habit name is required';
                  }
                  if (val.trim().length < 3) {
                    return 'Habit name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              const Text(
                'Description & Purpose (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Why is this habit important to your growth?',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Category Selector
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Icon & Color Selection Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon picker
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Icon',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.habitIcons.entries.take(8).map((entry) {
                            final isSel = _selectedIconKey == entry.key;
                            return InkWell(
                              onTap: () => setState(() => _selectedIconKey = entry.key),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isSel ? AppTheme.primaryLight : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSel ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                                    width: isSel ? 2 : 1,
                                  ),
                                ),
                                child: Icon(
                                  entry.value,
                                  size: 22,
                                  color: isSel ? AppTheme.primaryColor : const Color(0xFF64748B),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Color Picker
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Theme Color',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.colorOptions.take(8).map((colorVal) {
                            final isSel = _selectedColorValue == colorVal;
                            return InkWell(
                              onTap: () => setState(() => _selectedColorValue = colorVal),
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Color(colorVal),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel ? AppTheme.textPrimary : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: isSel
                                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Frequency
              const Text(
                'Target Frequency',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFrequency = AppConstants.freqEveryday;
                          _selectedWeekdays = [1, 2, 3, 4, 5, 6, 7];
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _selectedFrequency == AppConstants.freqEveryday ? AppTheme.primaryLight : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedFrequency == AppConstants.freqEveryday ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                            width: _selectedFrequency == AppConstants.freqEveryday ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedFrequency == AppConstants.freqEveryday ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: _selectedFrequency == AppConstants.freqEveryday ? AppTheme.primaryColor : const Color(0xFF94A3B8),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text('Every Day', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFrequency = AppConstants.freqWeekdays;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _selectedFrequency == AppConstants.freqWeekdays ? AppTheme.primaryLight : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedFrequency == AppConstants.freqWeekdays ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                            width: _selectedFrequency == AppConstants.freqWeekdays ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedFrequency == AppConstants.freqWeekdays ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: _selectedFrequency == AppConstants.freqWeekdays ? AppTheme.primaryColor : const Color(0xFF94A3B8),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text('Specific Days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_selectedFrequency == AppConstants.freqWeekdays) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final dayNum = i + 1; // 1 = Monday
                    final dayLabel = AppConstants.weekDayShort[i];
                    final isSel = _selectedWeekdays.contains(dayNum);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSel) {
                            _selectedWeekdays.remove(dayNum);
                          } else {
                            _selectedWeekdays.add(dayNum);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel ? AppTheme.primaryColor : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            dayLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSel ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],

              const SizedBox(height: 24),

              // Reminder Time
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                tileColor: Colors.white,
                leading: const Icon(Icons.notifications_active_outlined, color: AppTheme.primaryColor),
                title: const Text(
                  'Daily Reminder',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                trailing: Text(
                  _reminderTime,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
                onTap: _pickReminderTime,
              ),

              const SizedBox(height: 36),

              // Save Button
              ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Save Changes' : 'Create Habit',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
