import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bunnybank_parent/models/models.dart';
import 'package:bunnybank_parent/services/api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService();
  Parent? _parent;
  bool _loading = false;

  Parent? get parent => _parent;
  bool get isAuthenticated => _parent != null;
  bool get loading => _loading;
  ApiService get api => _api;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final parentJson = prefs.getString('parent');
    if (token != null && parentJson != null) {
      _api.setToken(token);
      _parent = Parent.fromJson(jsonDecode(parentJson));
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      });
      _parent = Parent.fromJson(data['parent']);
      _api.setToken(data['access_token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      await prefs.setString('parent', jsonEncode(data['parent']));
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });
      _parent = Parent.fromJson(data['parent']);
      _api.setToken(data['access_token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      await prefs.setString('parent', jsonEncode(data['parent']));
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _parent = null;
    _api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('parent');
    notifyListeners();
  }
}
