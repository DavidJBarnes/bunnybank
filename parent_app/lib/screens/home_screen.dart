import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_parent/models/models.dart';
import 'package:bunnybank_parent/services/auth_service.dart';
import 'package:bunnybank_parent/services/children_service.dart';
import 'package:bunnybank_parent/screens/children_screen.dart';
import 'package:bunnybank_parent/screens/send_money_screen.dart';
import 'package:bunnybank_parent/screens/reasons_screen.dart';
import 'package:bunnybank_parent/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Child> _children = [];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final auth = context.read<AuthService>();
    try {
      final children = await ChildrenService(auth.api).getChildren();
      if (mounted) setState(() => _children = children);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: colorScheme.primaryContainer,
              child: Row(
                children: [
                  Icon(Icons.savings, color: colorScheme.primary, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BunnyBank',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Welcome, ${auth.parent?.name ?? ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => auth.logout(),
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ChildrenSummary(
                    children: _children,
                    onRefresh: _loadChildren,
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _DashboardCard(
                        icon: Icons.people,
                        label: 'My Children',
                        color: colorScheme.primary,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChildrenScreen()),
                          );
                          _loadChildren();
                        },
                      ),
                      _DashboardCard(
                        icon: Icons.send,
                        label: 'Send Money',
                        color: colorScheme.secondary,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
                          );
                          _loadChildren();
                        },
                      ),
                      _DashboardCard(
                        icon: Icons.list_alt,
                        label: 'Payment Reasons',
                        color: colorScheme.tertiary,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReasonsScreen()),
                          );
                        },
                      ),
                      _DashboardCard(
                        icon: Icons.settings,
                        label: 'Settings',
                        color: colorScheme.surfaceVariant,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildrenSummary extends StatelessWidget {
  final List<Child> children;
  final VoidCallback onRefresh;

  const _ChildrenSummary({required this.children, required this.onRefresh});

  Widget _buildAvatar(Child child, BuildContext context) {
    if (child.imageUrl != null && child.imageUrl!.startsWith('data:image')) {
      try {
        final base64 = child.imageUrl!.split(',').last;
        final bytes = base64Decode(base64);
        return CircleAvatar(
          radius: 16,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {}
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        child.name[0].toUpperCase(),
        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.child_care, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text('No children yet', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Add a child to get started', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Your Children', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('${children.length}', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            ...children.take(3).map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      _buildAvatar(child, context),
                      const SizedBox(width: 12),
                      Expanded(child: Text(child.name)),
                      Text(
                        '\$${child.balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
            if (children.length > 3)
              Text('+${children.length - 3} more', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
