import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5083';
  static Future<List<Map<String, dynamic>>> getItems() async {
    final url = Uri.parse('$baseUrl/items');
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    print('API get-items status: ${response.statusCode}');
    print('API get-items body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    }
    return [];
  }
  //confirm email
  // ----------------- Confirm Email -----------------
  static Future<bool> confirmEmail(String email, String code) async {
    final url = Uri.parse('$baseUrl/auth/confirm-email');

    print('Sending confirm email request to: $url');
    print('Email: $email, Code: $code');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
      }),
    );

    print('API confirm-email status: ${response.statusCode}');
    print('API confirm-email body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // ----------------- Register -----------------
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String userName,
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
        'userName': userName,
        'password': password,
      }),
    );

    print('API register status: ${response.statusCode}');
    print('API register body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true};
    } else {
      final data = jsonDecode(response.body);
      Map<String, String> errors = {};

      if (data is List) {
        for (var e in data) {
          if (e['code'] == 'DuplicateUserName')
            errors['userName'] = e['description'];
          if (e['code'] == 'DuplicateEmail') errors['email'] = e['description'];
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
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('API login status: ${response.statusCode}');
    print('API login body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // 🔥 trimitem tot (accessToken, refreshToken etc.)
    }

    print('Login failed: ${response.body}');
    return null;
  }

}
