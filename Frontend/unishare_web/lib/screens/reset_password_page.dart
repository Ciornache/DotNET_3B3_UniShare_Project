import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? userId;
  final String? code;
  const ResetPasswordPage({super.key, this.userId, this.code});

  static Route routeFromUri(Uri uri) {
    // Accepts /reset-password?token=...&userId=...
    final token = uri.queryParameters['token'] ?? uri.queryParameters['code'];
    final userId = uri.queryParameters['userId'];
    return MaterialPageRoute(
      builder: (_) => ResetPasswordPage(userId: userId, code: token),
      settings: const RouteSettings(name: '/reset-password'),
    );
  }

  static void registerRoute(Map<String, WidgetBuilder> routes) {
    routes['/reset-password'] = (context) {
      // Always use the current browser URL (Uri.base) for web
      final uri = Uri.base;
      final token = uri.queryParameters['token'] ?? uri.queryParameters['code'];
      final userId = uri.queryParameters['userId'];
      return ResetPasswordPage(userId: userId, code: token);
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/reset-password') {
      // Try to extract token and userId from the current browser URL
      final uri = Uri.base;
      final token = uri.queryParameters['token'] ?? uri.queryParameters['code'];
      final userId = uri.queryParameters['userId'];
      return MaterialPageRoute(
        builder: (_) => ResetPasswordPage(userId: userId, code: token),
        settings: settings,
      );
    }
    return null;
  }

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String? _userId;
  String? _code;
  String? _temporaryToken;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _message;
  String? _passwordError; // Error message for password field

  @override
  void initState() {
    super.initState();
    final params = Uri.base.queryParameters;
    _userId = widget.userId ?? params['userId'];
    _code = widget.code ?? params['code'];
    _verifyToken();
  }

  Future<void> _verifyToken() async {
    if (_userId == null || _code == null) {
      setState(() => _message = 'Invalid or missing reset link.');
      return;
    }
    setState(() => _loading = true);
    try {
      final tempToken = await ApiService.verifyPasswordReset(_userId!, _code!);
      if (tempToken != null) {
        setState(() {
          _temporaryToken = tempToken;
          _message = 'Enter your new password below.';
        });
      } else {
        setState(() => _message = 'Invalid or expired reset link. Please request a new one.');
      }
    } catch (e) {
      setState(() => _message = 'Error verifying reset link.');
    } finally {
      setState(() => _loading = false);
    }
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required.';
    if (v.length < 6) return 'Minimum 6 characters.';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must contain at least 1 number.';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) return 'Must contain at least 1 special character.';
    return null;
  }

  Future<void> _submitNewPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final p = _passwordController.text.trim();

    // Clear previous non-validation messages
    setState(() {
      _message = null;
      _passwordError = null;
    });

    if (_temporaryToken == null || _userId == null) {
      setState(() => _message = 'Invalid or missing token/userId. Cannot proceed.');
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await ApiService.changePasswordWithTempToken(
        userId: _userId!,
        newPassword: p,
        temporaryToken: _temporaryToken!,
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
          // Navighează la login
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        // Handle validation errors from backend
        final errors = result['errors'] as Map<String, dynamic>?;
        String? passwordErrorMsg;

        if (errors != null) {
          // Tentativa de a găsi cea mai relevantă eroare
          final firstErrorList = errors.values.firstWhere((e) => e is List && e.isNotEmpty, orElse: () => null);
          if (firstErrorList != null) {
            passwordErrorMsg = firstErrorList.first.toString();
          }
        }

        setState(() => _passwordError = passwordErrorMsg ?? 'Failed to change password. Please verify requirements.');
      }
    } catch (e) {
      setState(() => _message = 'Error changing password: Failed to communicate with the server.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Funcție utilitară pentru a aplica stilul de input
  InputDecoration _getInputDecoration(String labelText, IconData icon, {String? errorText}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.deepPurple.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      errorText: errorText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxFormWidth = 450.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxFormWidth),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon și Titlu
                  const Icon(Icons.vpn_key_outlined, size: 60, color: Colors.deepPurple),
                  const SizedBox(height: 20),
                  const Text(
                    'Set New Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 20),

                  // Mesaj de Verificare/Eroare
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: (_message!.contains('Invalid') || _message!.contains('Error')) ? Colors.red : Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // Dacă token-ul a fost verificat, arată formularul
                  if (_temporaryToken != null) ...[
                    // Câmp Parolă Nouă
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _getInputDecoration('New Password', Icons.lock_outline, errorText: _passwordError),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 15),

                    // Câmp Confirmare Parolă
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: _getInputDecoration('Confirm Password', Icons.lock_reset),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirmation is required.';
                        if (v != _passwordController.text) return 'Passwords do not match.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Buton Submit
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submitNewPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                        ),
                        child: _loading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                            : const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  // Dacă se încarcă și nu există token (verificare în desfășurare)
                  if (_loading && _temporaryToken == null)
                    const Center(child: CircularProgressIndicator(color: Colors.deepPurple)),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}