import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/schedule.dart';
import '../models/subject.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDayOfWeek = DateTime.now().weekday; // 1 = Mon, 7 = Sun

  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  void _showAddScheduleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddScheduleForm(selectedDay: _selectedDayOfWeek),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabaseService = Provider.of<SupabaseService>(context);

    // Filter schedules for the selected day of week
    final filteredSchedules = supabaseService.schedules
        .where((s) => s.dayOfWeek == _selectedDayOfWeek)
        .toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Schedule',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddScheduleBottomSheet(context),
            icon: const Icon(Icons.add_box_outlined),
            color: theme.colorScheme.primary,
          ),
        ],
      ),
      body: Column(
        children: [
          // Days slider
          Container(
            height: 56,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final dayNum = index + 1;
                final isSelected = _selectedDayOfWeek == dayNum;
                final dayName = _days[index];
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(dayName.substring(0, 3)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDayOfWeek = dayNum;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    ),
                    backgroundColor: theme.colorScheme.surfaceContainer,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          
          // Schedule list
          Expanded(
            child: supabaseService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSchedules.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: filteredSchedules.length,
                        itemBuilder: (context, index) {
                          final schedule = filteredSchedules[index];
                          final subjectColor = _parseColor(schedule.subject?.color);
                          
                          return Dismissible(
                            key: Key(schedule.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: theme.colorScheme.error,
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              supabaseService.deleteSchedule(schedule.id);
                            },
                            child: Card(
                              elevation: 0,
                              color: theme.colorScheme.surfaceContainerLowest,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Left Colored Indicator
                                    Container(
                                      width: 4,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: subjectColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            schedule.title,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 14,
                                                color: theme.colorScheme.secondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${DateFormat('HH:mm').format(schedule.startTime)} - ${DateFormat('HH:mm').format(schedule.endTime)}',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Location
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (schedule.subject != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: subjectColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              schedule.subject!.name,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: subjectColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 6),
                                        Text(
                                          schedule.location ?? 'Online',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.secondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nothing Scheduled',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'There are no classes scheduled for this day.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null) return const Color(0xFF3525CD);
    final buffer = StringBuffer();
    if (colorHex.length == 6 || colorHex.length == 7) buffer.write('ff');
    buffer.write(colorHex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

// Bottom sheet form widget to add a schedule
class _AddScheduleForm extends StatefulWidget {
  final int selectedDay;
  const _AddScheduleForm({required this.selectedDay});

  @override
  State<_AddScheduleForm> createState() => _AddScheduleFormState();
}

class _AddScheduleFormState extends State<_AddScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locController = TextEditingController();
  late int _dayOfWeek;
  String? _selectedSubjectId;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);

  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _dayOfWeek = widget.selectedDay;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final service = Provider.of<SupabaseService>(context, listen: false);

    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year, now.month, now.day, _startTime.hour, _startTime.minute
    );
    final endDateTime = DateTime(
      now.year, now.month, now.day, _endTime.hour, _endTime.minute
    );

    try {
      await service.createSchedule(
        title: _titleController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        dayOfWeek: _dayOfWeek,
        location: _locController.text.trim().isEmpty ? null : _locController.text.trim(),
        subjectId: _selectedSubjectId,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class schedule added successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding schedule: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = Provider.of<SupabaseService>(context).subjects;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Class Schedule',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Title field
              TextFormField(
                controller: _titleController,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a title' : null,
                decoration: InputDecoration(
                  labelText: 'Class Title (e.g. Advanced Calculus)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Location field
              TextFormField(
                controller: _locController,
                decoration: InputDecoration(
                  labelText: 'Location / Room (e.g. Room 402B)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Subject selection
              DropdownButtonFormField<String>(
                initialValue: _selectedSubjectId,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None / General')),
                  ...subjects.map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedSubjectId = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Day of the week dropdown
              DropdownButtonFormField<int>(
                initialValue: _dayOfWeek,
                decoration: InputDecoration(
                  labelText: 'Day of Week',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: List.generate(
                  7,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(_days[index]),
                  ),
                ),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _dayOfWeek = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Start & End Time picker buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTime(context, true),
                      icon: const Icon(Icons.access_time_rounded),
                      label: Text('Starts: ${_startTime.format(context)}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTime(context, false),
                      icon: const Icon(Icons.access_time_rounded),
                      label: Text('Ends: ${_endTime.format(context)}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add to Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
