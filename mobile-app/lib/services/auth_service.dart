import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.apiBase}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']['access_token'];
      final role = data['data']['role'];
      await saveSession(token, '', role, data['data']['name'] ?? '', email, data['data']['user_id'] ?? '');
      return data['data'];
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Login failed (${response.statusCode})');
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Login failed (${response.statusCode})');
      }
    }
  }

  static Future<void> signup(String email, String password, String fullName, String vendorCode) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.apiBase}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': fullName, 'vendor_code': vendorCode}),
    );
    if (response.statusCode != 201) throw Exception('Signup failed');
  }

  static Future<void> saveSession(String token, String refreshToken, String role, String name, String email, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('userId', userId);
  }

  static Future<Map<String, String?>> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'role': prefs.getString('role'),
    };
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
