import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bunnybank_parent/config/api_config.dart';

class ApiService {
  final http.Client _client = http.Client();
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw ApiException(response.statusCode, response.body);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<void> delete(String path) async {
    final response = await _client.delete(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
    );
    if (response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(response.statusCode, response.body);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
