import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_parent/models/models.dart';
import 'package:bunnybank_parent/services/auth_service.dart';
import 'package:bunnybank_parent/services/children_service.dart';
import 'package:bunnybank_parent/screens/add_child_screen.dart';
import 'package:bunnybank_parent/screens/edit_child_screen.dart';
import 'package:intl/intl.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  List<Child> _children = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthService>();
    final service = ChildrenService(auth.api);
    try {
      final children = await service.getChildren();
      if (mounted) setState(() { _children = children; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load children: $e')),
        );
      }
    }
  }

  Future<void> _editChild(Child child) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditChildScreen(child: child)),
    );
    if (changed == true) _load();
  }

  Future<void> _deleteChild(Child child) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Child'),
        content: Text('Delete ${child.name}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final auth = context.read<AuthService>();
      await ChildrenService(auth.api).deleteChild(child.id);
      _load();
    }
  }

  Widget _buildAvatar(Child child) {
    if (child.imageUrl != null && child.imageUrl!.startsWith('data:image')) {
      try {
        final base64 = child.imageUrl!.split(',').last;
        final bytes = base64Decode(base64);
        return CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {}
    }
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        child.name[0].toUpperCase(),
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Children')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddChildScreen()));
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _children.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.child_care, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No children yet', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Tap + to add your first child', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _children.length,
                    itemBuilder: (context, index) {
                      final child = _children[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _editChild(child),
                          onLongPress: () => _deleteChild(child),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                _buildAvatar(child),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(child.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${child.age} yrs • ${DateFormat.yMMMd().format(DateTime.parse(child.birthday))}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.fingerprint, size: 12, color: Colors.grey[500]),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              child.id.substring(0, 8),
                                              style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey[500]),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: child.id));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${child.name}\'s ID copied'),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                            child: Icon(Icons.copy, size: 14, color: Colors.grey[400]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${child.balance.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text('balance', style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right, color: Colors.grey[400]),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
