import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unishare_web/screens/verify_email_page.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // ---------------- LISTENERS FOR CLEARING ERRORS ----------------
    _emailCtrl.addListener(() => _clearFieldError('email'));
    _userNameCtrl.addListener(() => _clearFieldError('userName'));
  }

  void _clearFieldError(String field) {
    final auth = context.read<AuthProvider>();
    if (auth.fieldErrors.containsKey(field)) {
      auth.fieldErrors.remove(field);
      // Force form revalidation to clear the error message
      if (_formKey.currentState != null) _formKey.currentState!.validate();
      // Notify widget to re-render
      setState(() {});
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      userName: _userNameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );
    setState(() => _loading = false);

    _formKey.currentState!.validate(); // revalidate to show backend errors

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Check your email for verification code.')),
      );

      // Navigate to VerifyEmailPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailPage(email: _emailCtrl.text.trim()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final double maxFormWidth = 450.0; // Slightly wider for more fields

    return Scaffold(
      // Removed AppBar for a cleaner look, kept title here for context
      // If you prefer the AppBar, uncomment:
      // appBar: AppBar(title: const Text('Register')),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxFormWidth,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Prominent Title
                  const Text(
                    'Create Your Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // 2. First Name
                  TextFormField(
                    controller: _firstNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter your first name' : null,
                  ),
                  const SizedBox(height: 15),

                  // 3. Last Name
                  TextFormField(
                    controller: _lastNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter your last name' : null,
                  ),
                  const SizedBox(height: 15),

                  // 4. Email
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) {
                      if (!v!.contains('@')) return 'Enter a valid email';
                      if (auth.fieldErrors.containsKey('email')) return auth.fieldErrors['email'];
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // 5. Username
                  TextFormField(
                    controller: _userNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.alternate_email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) {
                      if (v!.isEmpty) return 'Enter a username';
                      if (auth.fieldErrors.containsKey('userName')) return auth.fieldErrors['userName'];
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // 6. Password
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter a password';
                      if (v.length < 6) return 'Minimum 6 characters';
                      if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must contain at least 1 number';
                      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) return 'Must contain at least 1 special character';
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // 7. Register Button (ElevatedButton)
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: _loading
                          ? const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                          : const Text(
                        'Register',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 8. Secondary Action (Login)
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _userNameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}