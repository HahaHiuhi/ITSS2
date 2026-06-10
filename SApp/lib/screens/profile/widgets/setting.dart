import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/setting_provider.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settings =
    context.watch<SettingsService>();

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Deadline reminders',
            ),
            value:
            settings.deadlineReminders,
            onChanged:
            settings.setDeadlineReminders,
          ),
          SwitchListTile(
            title: const Text(
              'Daily reminders',
            ),
            value:
            settings.dailyReminders,
            onChanged:
            settings.setDailyReminders,
          ),
        ],
      ),
    );
  }
}