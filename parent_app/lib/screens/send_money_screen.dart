import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_parent/models/models.dart';
import 'package:bunnybank_parent/services/auth_service.dart';
import 'package:bunnybank_parent/services/children_service.dart';
import 'package:bunnybank_parent/services/money_service.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _amountCtrl = TextEditingController();
  List<Child> _children = [];
  List<Reason> _reasons = [];
  final Set<String> _selectedChildren = {};
  String? _selectedReasonId;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = context.read<AuthService>();
    try {
      final children = await ChildrenService(auth.api).getChildren();
      final reasons = await MoneyService(auth.api).getReasons();
      if (mounted) {
        setState(() {
          _children = children;
          _reasons = reasons;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _sendMoney() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid positive amount')),
      );
      return;
    }
    if (_selectedChildren.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one child')),
      );
      return;
    }
    if (_selectedReasonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a reason')),
      );
      return;
    }

    setState(() => _sending = true);
    final auth = context.read<AuthService>();
    try {
      await MoneyService(auth.api).sendMoney(
        childIds: _selectedChildren.toList(),
        amount: amount,
        reasonId: _selectedReasonId!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Money sent!'), backgroundColor: Colors.green),
        );
        _amountCtrl.clear();
        _selectedChildren.clear();
        setState(() => _sending = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    decoration: const InputDecoration(
                      labelText: 'Amount (\$)',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Select Children', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...(_children.isEmpty
                      ? [const Text('No children found. Add a child first.')]
                      : _children.map((child) => CheckboxListTile(
                            title: Text(child.name),
                            subtitle: Text('Balance: \$${child.balance.toStringAsFixed(2)}'),
                            value: _selectedChildren.contains(child.id),
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _selectedChildren.add(child.id);
                                } else {
                                  _selectedChildren.remove(child.id);
                                }
                              });
                            },
                          ))),
                  const SizedBox(height: 24),
                  Text('Reason', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedReasonId,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    hint: const Text('Choose a reason'),
                    items: _reasons.map((r) => DropdownMenuItem(value: r.id, child: Text(r.label))).toList(),
                    onChanged: (v) => setState(() => _selectedReasonId = v),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _sending ? null : _sendMoney,
                      child: _sending
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Send Money'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
