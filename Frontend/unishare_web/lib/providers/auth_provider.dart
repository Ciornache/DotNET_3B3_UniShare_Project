import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  static const _storage = FlutterSecureStorage();

  String? _token;
  String? _refreshToken;
  String? _currentUserEmail;

  String? get token => _token;
  String? get refreshToken => _refreshToken;
  String? get currentUserEmail => _currentUserEmail;

  bool get isAuthenticated => _token != null;

  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;

  // ---------------- LOGIN ----------------
  Future<bool> login(String email, String password) async {
    final response = await ApiService.login(email: email, password: password);

    if (response != null && response.containsKey('accessToken')) {
      _token = response['accessToken'];
      _refreshToken = response['refreshToken'];
      _currentUserEmail = email;

      await _saveCredentials();
      notifyListeners();
      return true;
    }
    return false;
  }

  // ---------------- REGISTER ----------------
  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final result = await ApiService.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    if (result['success'] == true) {
      _fieldErrors.clear();
      return result['entity']['id']; // return user ID
    } else {
      _fieldErrors = Map<String, String>.from(result['errors'] ?? {});
      return null;
    }
  }

  void clearFieldErrors() {
    _fieldErrors.clear();
    notifyListeners();
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _currentUserEmail = null;
    notifyListeners();

    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'userEmail');
  }

  // ---------------- AUTO LOGIN ----------------
  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'token');
    final storedRefresh = await _storage.read(key: 'refreshToken');
    final storedEmail = await _storage.read(key: 'userEmail');

    if (storedToken == null || storedRefresh == null || storedEmail == null) return;

    _token = storedToken;
    _refreshToken = storedRefresh;
    _currentUserEmail = storedEmail;
    notifyListeners();
  }

  // ---------------- SAVE TOKEN ----------------
  Future<void> _saveCredentials() async {
    if (_token != null && _refreshToken != null && _currentUserEmail != null) {
      await _storage.write(key: 'token', value: _token);
      await _storage.write(key: 'refreshToken', value: _refreshToken);
      await _storage.write(key: 'userEmail', value: _currentUserEmail);
    }
  }
}
