import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'verify_email_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool? emailVerified;
  bool isLoading = false;

  Future<void> checkEmailVerified() async {
    setState(() => isLoading = true);
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    final result = await ApiService.getEmailVerifiedStatus(token!);
    setState(() {
      emailVerified = result;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkEmailVerified();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.currentUserEmail ?? "unknown@unishare.com";
    final token=auth.token;
    final userId=ApiService.getUserIdFromToken(token);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              "https://cdn-icons-png.flaticon.com/512/149/149071.png",
            ),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: 20),
          const Text(
            "UniShare User",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(email, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 20),

          // --- Email Verified Section ---
          isLoading
              ? const CircularProgressIndicator()
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emailVerified == true ? "Email Verified ✅" : "Email Not Verified ❌",
                style: TextStyle(
                  color: emailVerified == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (emailVerified != true)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VerifyEmailPage(email: email,userId: userId),
                      ),
                    ).then((_) => checkEmailVerified());
                  },
                  child: const Text("Verify"),
                ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(thickness: 1),
          const SizedBox(height: 10),

          // --- Rest of profile info ---
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text("Email"),
            subtitle: Text(email),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text("Account Type"),
            subtitle: const Text("Standard User"),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text("Member Since"),
            subtitle: const Text("November 2025"),
          ),
          const SizedBox(height: 30),

          // Edit profile button
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Edit profile coming soon!")),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text("Edit Profile"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
