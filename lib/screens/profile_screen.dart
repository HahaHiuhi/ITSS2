import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/supabase_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = context.watch<SupabaseService>();
    final completedTasks =
        service.tasks.where((task) => task.isCompleted).length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => _showEditProfileSheet(context, service),
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: service.fetchInitialData,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _ProfileHeader(service: service),
            const SizedBox(height: 20),
            _StatsGrid(
              totalTasks: service.tasks.length,
              completedTasks: completedTasks,
              subjects: service.subjects.length,
              schedules: service.schedules.length,
            ),
            const SizedBox(height: 20),
            _InfoSection(service: service),
            const SizedBox(height: 20),
            _SettingsSection(service: service),
            const SizedBox(height: 20),
            _AccountSection(service: service),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, SupabaseService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(service: service),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.service});

  final SupabaseService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = service.profileName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(theme),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              initials.isEmpty ? 'S' : initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.profileName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.profileEmail,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.isDemoSession ? 'Demo profile' : 'Verified account',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.totalTasks,
    required this.completedTasks,
    required this.subjects,
    required this.schedules,
  });

  final int totalTasks;
  final int completedTasks;
  final int subjects;
  final int schedules;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: [
        _StatTile(
            icon: Icons.task_alt_rounded,
            label: 'Done',
            value: '$completedTasks'),
        _StatTile(
            icon: Icons.list_alt_rounded, label: 'Tasks', value: '$totalTasks'),
        _StatTile(
            icon: Icons.menu_book_rounded,
            label: 'Subjects',
            value: '$subjects'),
        _StatTile(
            icon: Icons.event_note_rounded,
            label: 'Classes',
            value: '$schedules'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.service});

  final SupabaseService service;

  @override
  Widget build(BuildContext context) {
    return _SectionPanel(
      title: 'Student information',
      children: [
        _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Student ID',
            value: service.profileStudentId),
        _InfoRow(
            icon: Icons.apartment_rounded,
            label: 'School',
            value: service.profileSchool),
        _InfoRow(
            icon: Icons.school_outlined,
            label: 'Major',
            value: service.profileMajor),
        _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: service.profilePhone),
        _InfoRow(
            icon: Icons.notes_rounded, label: 'Bio', value: service.profileBio),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.service});

  final SupabaseService service;

  @override
  Widget build(BuildContext context) {
    return _SectionPanel(
      title: 'Preferences',
      children: [
        _SwitchRow(
          icon: Icons.notifications_active_outlined,
          title: 'Deadline reminders',
          subtitle: 'Notify before important tasks are due',
          value: service.emailRemindersEnabled,
          onChanged: service.setEmailRemindersEnabled,
        ),
        const Divider(height: 24),
        _SwitchRow(
          icon: Icons.summarize_outlined,
          title: 'Weekly summary',
          subtitle: 'Receive a study progress recap each week',
          value: service.weeklySummaryEnabled,
          onChanged: service.setWeeklySummaryEnabled,
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.service});

  final SupabaseService service;

  @override
  Widget build(BuildContext context) {
    return _SectionPanel(
      title: 'Account',
      children: [
        _ActionRow(
          icon: Icons.lock_reset_rounded,
          title: 'Reset password',
          subtitle: service.isConfigured
              ? 'Send a password reset email'
              : 'Available after Supabase is configured',
          onTap: service.isConfigured
              ? () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await service.sendPasswordReset();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent'),
                    ),
                  );
                }
              : null,
        ),
        const Divider(height: 24),
        _ActionRow(
          icon: Icons.logout_rounded,
          title: 'Sign out',
          subtitle: 'Return to the login screen',
          onTap: service.signOut,
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: onTap == null
                  ? theme.disabledColor
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: onTap == null
                          ? theme.disabledColor
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: onTap == null
                  ? theme.disabledColor
                  : theme.colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue = value.trim().isEmpty ? 'Not set' : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: displayValue == 'Not set'
                    ? FontWeight.w400
                    : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.service});

  final SupabaseService service;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _studentIdController;
  late final TextEditingController _schoolController;
  late final TextEditingController _majorController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.profileName);
    _studentIdController =
        TextEditingController(text: widget.service.profileStudentId);
    _schoolController =
        TextEditingController(text: widget.service.profileSchool);
    _majorController = TextEditingController(text: widget.service.profileMajor);
    _phoneController = TextEditingController(text: widget.service.profilePhone);
    _bioController = TextEditingController(text: widget.service.profileBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _schoolController.dispose();
    _majorController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      await widget.service.updateProfile(
        name: _nameController.text.trim(),
        studentId: _studentIdController.text.trim(),
        school: _schoolController.text.trim(),
        major: _majorController.text.trim(),
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 16),
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit profile',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ProfileField(
                controller: _nameController,
                label: 'Full name',
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if ((value ?? '').trim().length < 2) {
                    return 'Enter your full name';
                  }
                  return null;
                },
              ),
              _ProfileField(
                controller: _studentIdController,
                label: 'Student ID',
                icon: Icons.badge_outlined,
              ),
              _ProfileField(
                controller: _schoolController,
                label: 'School',
                icon: Icons.apartment_rounded,
              ),
              _ProfileField(
                controller: _majorController,
                label: 'Major',
                icon: Icons.school_outlined,
              ),
              _ProfileField(
                controller: _phoneController,
                label: 'Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _ProfileField(
                controller: _bioController,
                label: 'Bio',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: widget.service.isLoading ? null : _save,
                icon: widget.service.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Save profile'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration(ThemeData theme) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: theme.colorScheme.surfaceContainer),
    boxShadow: [
      BoxShadow(
        color: theme.colorScheme.primary.withValues(alpha: 0.04),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
