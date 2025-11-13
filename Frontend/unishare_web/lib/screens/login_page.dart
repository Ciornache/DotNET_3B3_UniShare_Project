import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unishare_web/screens/main_page.dart';
import '../providers/auth_provider.dart';
import 'home_page.dart'; // Păstrat de dragul structurii, deși nu este folosit
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
    setState(() => _loading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definirea lățimii maxime a formularului pentru ecrane mari (Web/Desktop)
    final double maxFormWidth = 400.0;

    return Scaffold(
      // Am eliminat AppBar-ul pentru un design mai curat,
      // dar poți să-l adaugi înapoi dacă vrei titlul 'Login'.

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxFormWidth, // Limitează lățimea pe ecrane mari
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Face elementele să ocupe lățimea completă
              children: [
                // 1. Titlu Proeminent
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple, // Culoare de accent
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 2. Câmp Email cu design îmbunătățit
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Câmp Parolă cu design îmbunătățit
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Poți adăuga un sufix pentru 'show/hide password'
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                // 4. Buton Login (ElevatedButton) cu dimensiuni și stil îmbunătățite
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple, // Culoarea principală
                      foregroundColor: Colors.white, // Culoarea textului
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5, // Adaugă o mică umbră
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
                      'Login',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Acțiunea Secundară (Înregistrare)
                TextButton(
                  onPressed: () {
                    // Logica de navigare PĂSTRATĂ
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text(
                    'No account yet? Register now!',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}