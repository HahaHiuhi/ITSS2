import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';

class AccountSection extends StatelessWidget {
  final AuthService service;

  const AccountSection({super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Reset password'),
            onTap: () async {
              final email = service.currentUser?.email;

              if (email == null) return;

              await service.sendPasswordReset(email);
            },
          ),
          ListTile(
            leading:
            const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: service.signOut,
          ),
        ],
      ),
    );
  }
}