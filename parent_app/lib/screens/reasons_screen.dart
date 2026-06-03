import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_parent/models/models.dart';
import 'package:bunnybank_parent/services/auth_service.dart';
import 'package:bunnybank_parent/services/money_service.dart';

class ReasonsScreen extends StatefulWidget {
  const ReasonsScreen({super.key});

  @override
  State<ReasonsScreen> createState() => _ReasonsScreenState();
}

class _ReasonsScreenState extends State<ReasonsScreen> {
  List<Reason> _reasons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthService>();
    try {
      final reasons = await MoneyService(auth.api).getReasons();
      if (mounted) setState(() { _reasons = reasons; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _addReason() async {
    final ctrl = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Payment Reason'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Label', hintText: 'chores')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    if (label != null && label.isNotEmpty) {
      final auth = context.read<AuthService>();
      await MoneyService(auth.api).createReason(label);
      _load();
    }
  }

  Future<void> _deleteReason(Reason reason) async {
    final auth = context.read<AuthService>();
    await MoneyService(auth.api).deleteReason(reason.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Reasons')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReason,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reasons.isEmpty
              ? const Center(child: Text('No reasons yet. Add some!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reasons.length,
                  itemBuilder: (context, index) {
                    final reason = _reasons[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.label),
                        title: Text(reason.label),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReason(reason),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
