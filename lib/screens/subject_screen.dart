import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/subject.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  // Predefined harmonious color palette matching premium dark/light themes
  final List<String> _colors = [
    '#3525CD', // Indigo / Primary
    '#10B981', // Emerald
    '#EF4444', // Red
    '#F59E0B', // Amber / Orange
    '#3B82F6', // Blue
    '#8B5CF6', // Purple
    '#EC4899', // Pink
    '#06B6D4', // Cyan
  ];

  void _showAddSubjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddSubjectDialog(colors: _colors),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabaseService = Provider.of<SupabaseService>(context);
    final subjects = supabaseService.subjects;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Subjects',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddSubjectDialog(context),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: theme.colorScheme.primary,
          ),
        ],
      ),
      body: supabaseService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
              ? _buildEmptyState(theme)
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final subjectColor = _parseColor(subject.color);

                    return Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onLongPress: () => _deleteSubject(context, subject),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Colored Dot
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: subjectColor,
                              ),
                              // Title and details
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subject.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Count associated tasks
                                  Text(
                                    '${supabaseService.tasks.where((t) => t.subjectId == subject.id && !t.isCompleted).length} tasks active',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.secondary,
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
    );
  }

  void _deleteSubject(BuildContext context, Subject subject) async {
    final service = Provider.of<SupabaseService>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${subject.name}"? Tasks associated with this subject will be set to general.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await service.deleteSubject(subject.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subject "${subject.name}" deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete subject: $e')),
          );
        }
      }
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 64,
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Subjects Added',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create subjects to categorize your schedule & tasks.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorHex) {
    final buffer = StringBuffer();
    if (colorHex.length == 6 || colorHex.length == 7) buffer.write('ff');
    buffer.write(colorHex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

// Dialog to add a subject
class _AddSubjectDialog extends StatefulWidget {
  final List<String> colors;
  const _AddSubjectDialog({required this.colors});

  @override
  State<_AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<_AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.colors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final service = Provider.of<SupabaseService>(context, listen: false);

    try {
      await service.createSubject(
        _nameController.text.trim(),
        _selectedColor,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subject created successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating subject: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('New Subject', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter subject name' : null,
              decoration: InputDecoration(
                labelText: 'Subject Name (e.g. Physics)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            
            // Color picking title
            Text(
              'Select Color Tag',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Color circles grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.colors.map((colorHex) {
                final colorVal = _parseColor(colorHex);
                final isSelected = _selectedColor == colorHex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorHex;
                    });
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colorVal,
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }

  Color _parseColor(String colorHex) {
    final buffer = StringBuffer();
    if (colorHex.length == 6 || colorHex.length == 7) buffer.write('ff');
    buffer.write(colorHex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
