import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unishare_web/screens/main_page.dart';
import 'providers/auth_provider.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';

Future<void> main() async {
  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin(); // încearcă să încarce token-ul

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: const UniShareApp(),
    ),
  );
}

class UniShareApp extends StatelessWidget {
  const UniShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniShare',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: auth.isAuthenticated ? const MainPage() : const LoginPage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}
