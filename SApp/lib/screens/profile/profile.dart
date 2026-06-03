// profile.dart
// Refactored ProfileScreen compatible with your SupabaseService.
// Replace/import paths as needed.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/supabase_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SupabaseService>();
    final completedTasks =
        service.tasks.where((t) => t.isComplete).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => _EditProfileSheet(service: service),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: service.fetchInitialData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProfileHeader(service: service),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('${service.tasks.length}',
                            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
                        Text('Tasks'),
                      ],
                    ),
                    Column(
                      children: [
                        Text('$completedTasks',
                            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
                        Text('Done'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Deadline reminders'),
              subtitle: const Text('Notify before important tasks are due'),
              value: service.emailRemindersEnabled,
              onChanged: service.setEmailRemindersEnabled,
            ),
            SwitchListTile(
              title: const Text('Weekly summary'),
              subtitle: const Text('Receive a weekly recap'),
              value: service.weeklySummaryEnabled,
              onChanged: service.setWeeklySummaryEnabled,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Reset password'),
              onTap: () async {
                await service.sendPasswordReset();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: service.signOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final SupabaseService service;

  const _ProfileHeader({required this.service});

  @override
  Widget build(BuildContext context) {
    final name = service.profileName ?? '';
    final workplace = service.workplace ?? '';

    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    final initials = parts.isEmpty
        ? 'U'
        : parts.length == 1
        ? parts.first[0].toUpperCase()
        : '${parts.first[0]}${parts.last[0]}'.toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Text(initials),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'Unknown User' : name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(service.profileEmail),
                  if (workplace.isNotEmpty) Text(workplace),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final SupabaseService service;

  const _EditProfileSheet({required this.service});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _workplaceController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.service.profileName ?? '');
    _workplaceController =
        TextEditingController(text: widget.service.workplace ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _workplaceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await widget.service.updateProfile(
      fullName: _nameController.text.trim(),
      workplace: _workplaceController.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
              ),
              validator: (v) =>
              (v == null || v.trim().length < 2)
                  ? 'Enter your name'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _workplaceController,
              decoration: const InputDecoration(
                labelText: 'Workplace',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
