import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5083';
  static final _storage = const FlutterSecureStorage();

  // ----------------- Get Items -----------------
  static Future<List<Map<String, dynamic>>> getItems() async {
    final token = await _storage.read(key: 'token'); // citește token-ul securizat
    final url = Uri.parse('$baseUrl/items');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('API get-items status: ${response.statusCode}');
    print('API get-items body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return List<Map<String, dynamic>>.from(data);
    }

    return [];
  }

  // ----------------- Confirm Email -----------------
  static Future<bool> confirmEmail(String userId, String code) async {
    final url = Uri.parse('$baseUrl/auth/confirm-email');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'code': code}),
    );

    print('API confirm-email status: ${response.statusCode}');
    print('API confirm-email body: ${response.body}');

    return response.statusCode == 200;
  }

  // ----------------- Register -----------------
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );

    print('API register status: ${response.statusCode}');
    print('API register body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      var rep = json.decode(response.body);
      rep['success'] = true;
      return rep;
    } else {
      final data = jsonDecode(response.body);
      Map<String, String> errors = {};

      if (data is List) {
        for (var e in data) {
          if (e['code'] == 'DuplicateEmail' || e['code'] == 'DuplicateUserName') {
            errors['email'] = e['description'];
          }
        }
      }

      return {'success': false, 'errors': errors};
    }
  }

  // ----------------- Login -----------------
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('API login status: ${response.statusCode}');
    print('API login body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Salvează token-urile automat în secure storage
      final storage = const FlutterSecureStorage();
      await storage.write(key: 'token', value: data['accessToken']);
      await storage.write(key: 'refreshToken', value: data['refreshToken']);
      await storage.write(key: 'userEmail', value: email);
      return data;
    }

    return null;
  }
}
