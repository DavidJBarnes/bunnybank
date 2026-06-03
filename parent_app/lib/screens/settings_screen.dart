import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_parent/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final parent = auth.parent;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Name', value: parent?.name ?? ''),
                  _InfoRow(label: 'Email', value: parent?.email ?? ''),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(
                    'BunnyBank helps parents teach children the value of '
                    'money using a virtual currency system. Send Bunny Bucks '
                    'to your children for chores, good behavior, or just because!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
