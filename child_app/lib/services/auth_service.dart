import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bunnybank_child/services/api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService();
  String? _childId;
  String? _childName;
  bool _loading = false;

  String? get childId => _childId;
  String? get childName => _childName;
  bool get isAuthenticated => _childId != null;
  bool get loading => _loading;
  ApiService get api => _api;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final childId = prefs.getString('child_id');
    final token = prefs.getString('token');
    final childName = prefs.getString('child_name');
    if (childId != null && token != null && childName != null) {
      _childId = childId;
      _childName = childName;
      _api.setToken(token);
      notifyListeners();
    }
  }

  Future<void> login(String childId, String pin) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.post('/child/login', {
        'child_id': childId,
        'pin': pin,
      });
      _childId = childId;
      _childName = data['child_name'];
      _api.setToken(data['access_token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('child_id', childId);
      await prefs.setString('token', data['access_token']);
      await prefs.setString('child_name', data['child_name']);
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void logout() {
    _childId = null;
    _childName = null;
    _api.setToken(null);
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('child_id');
      prefs.remove('token');
      prefs.remove('child_name');
    });
    notifyListeners();
  }
}
