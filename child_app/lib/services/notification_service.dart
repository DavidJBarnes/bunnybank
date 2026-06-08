import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bunnybank_child/services/balance_service.dart';

class NotificationService {
  BalanceService? _balanceService;
  bool _initialized = false;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Called whenever an FCM token is obtained or refreshed, so the app can
  /// register it with the API (which needs it to push the cha-ching).
  void Function(String token)? onToken;

  final StreamController<Map<String, String>> _moneyController = StreamController.broadcast();
  Stream<Map<String, String>> get moneyStream => _moneyController.stream;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await messaging.getToken();
      if (token != null) {
        _fcmToken = token;
        debugPrint('FCM Token: $token');
        onToken?.call(token);
      }
      messaging.onTokenRefresh.listen((t) {
        _fcmToken = t;
        onToken?.call(t);
      });

      FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      _initialized = true;
    } catch (e) {
      debugPrint('Firebase not available (expected in local dev / web): $e');
      _initialized = false;
    }
  }

  void attachBalanceService(BalanceService service) {
    _balanceService = service;
  }

  void _handleMessage(RemoteMessage message) {
    final rawData = message.data;
    final data = rawData.map((k, v) => MapEntry(k, v.toString()));
    if (data['type'] == 'money_received') {
      final amount = double.tryParse(data['amount'] ?? '0') ?? 0;
      final newBalance = double.tryParse(data['new_balance'] ?? '0') ?? 0;

      _balanceService?.applyMoneyReceived(amount, newBalance);
      _moneyController.add(data);
    }
  }

  void simulateMoneyReceived(double amount, String reason, double newBalance) {
    _balanceService?.applyMoneyReceived(amount, newBalance);
    _moneyController.add({
      'type': 'money_received',
      'amount': amount.toString(),
      'reason': reason,
      'new_balance': newBalance.toString(),
    });
  }

  void dispose() {
    _moneyController.close();
  }
}
