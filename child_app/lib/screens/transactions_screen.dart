import 'package:flutter/material.dart';
import 'package:bunnybank_child/models/models.dart';
import 'package:bunnybank_child/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Transaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthService>();
    try {
      final response = await auth.api.getList('/child/transactions');
      final transactions = response
          .map((j) => Transaction.fromJson(j as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() { _transactions = transactions; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recent Transactions')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('No transactions yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final t = _transactions[index];
                    final date = DateTime.tryParse(t.createdAt);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(Icons.payments, color: Theme.of(context).colorScheme.primary),
                      ),
                      title: Text(
                        '+\$${t.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        date != null ? DateFormat('MMM d').format(date) : '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
    );
  }
}
