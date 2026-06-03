import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bunnybank_child/models/models.dart';
import 'package:bunnybank_child/services/api_service.dart';

class BalanceService extends ChangeNotifier {
  final ApiService _api;
  double _balance = 0.0;
  double _previousBalance = 0.0;
  Timer? _timer;
  bool _initialized = false;

  final StreamController<Map<String, String>> _moneyController = StreamController.broadcast();
  Stream<Map<String, String>> get moneyStream => _moneyController.stream;

  double get balance => _balance;

  BalanceService(this._api);

  void startPolling() {
    _fetchBalance();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchBalance());
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _fetchBalance() async {
    try {
      final data = await _api.get('/child/balance');
      final newBalance = (data['balance'] as num).toDouble();
      if (_initialized && newBalance > _previousBalance) {
        final diff = newBalance - _previousBalance;
        _moneyController.add({
          'type': 'money_received',
          'amount': diff.toStringAsFixed(2),
          'new_balance': newBalance.toStringAsFixed(2),
        });
      }
      _previousBalance = newBalance;
      _balance = newBalance;
      _initialized = true;
      notifyListeners();
    } catch (_) {}
  }

  Future<List<Transaction>> getTransactions() async {
    final data = await _api.getList('/child/transactions');
    return data.map((j) => Transaction.fromJson(j as Map<String, dynamic>)).toList();
  }

  void applyMoneyReceived(double amount, double newBalance) {
    _balance = newBalance;
    _previousBalance = newBalance;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    _moneyController.close();
    super.dispose();
  }
}
