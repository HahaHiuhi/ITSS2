import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';

class ProfileHeader extends StatelessWidget {
  final AuthService service;

  const ProfileHeader({super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final profile = service.profile;

    final name = profile?.fullName ?? '';
    final workplace = profile?.workplace ?? '';

    final initials = name.isEmpty
        ? 'U'
        : name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              child: Text(initials),
            ),

            const SizedBox(height: 12),

            Text(
              name.isEmpty
                  ? 'Unknown User'
                  : name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),

            Text(
              service.currentUser?.email ?? '',
            ),

            if (workplace.isNotEmpty)
              Text(workplace),
          ],
        ),
      ),
    );
  }
}