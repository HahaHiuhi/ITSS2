// profile.dart
// Refactored ProfileScreen compatible with your SupabaseService.
// Replace/import paths as needed.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sapp/screens/profile/widgets/widgets.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileHeader(service: service),

            const SizedBox(height: 24),

            const ProfileForm(),

            const SizedBox(height: 24),

            const StatisticsCard(),

            const SizedBox(height: 24),

            SettingsSection(),

            const SizedBox(height: 24),

            AccountSection(service: service),
          ],
        ),
    );
  }
}

