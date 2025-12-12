import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;

    // Clear previous success/error messages before starting
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final ok = await ApiService.requestPasswordResetByEmail(value);
      setState(() {
        // Mesaj neutru pentru securitate (nu confirmăm existența emailului)
        _message = ok
            ? 'If the email exists in our system, a password reset link has been sent.'
            : 'Request processed. Please check your inbox.';
      });
    } catch (e) {
      setState(() => _message = 'Error: Failed to communicate with the server.');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Funcție utilitară pentru a aplica stilul de input
  InputDecoration _getInputDecoration(String labelText, IconData icon) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxFormWidth = 450.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxFormWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon și Titlu
                const Icon(Icons.lock_reset, size: 60, color: Colors.deepPurple),
                const SizedBox(height: 20),
                const Text(
                  'Trouble Logging In?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the email address associated with your account to receive a password reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),

                const SizedBox(height: 30),

                // Câmp Email
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _getInputDecoration('Email', Icons.email_outlined),
                ),

                const SizedBox(height: 20),

                // Buton Submit
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
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
                        : const Text('Request Reset Link', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                // Mesaj
                if (_message != null) ...[
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _message!.contains('Error') ? Colors.red : Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}