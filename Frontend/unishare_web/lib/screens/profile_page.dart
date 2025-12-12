import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';
import 'verify_email_page.dart';
import 'edit_profile_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool? emailVerified;
  bool isLoading = false;
  bool isLoadingUserData = true;
  String? firstName;
  String? lastName;
  String? universityName;

  Future<void> loadUserData() async {
    setState(() => isLoadingUserData = true);
    final auth = context.read<AuthProvider>();

    // Make sure we have a valid token - try to refresh if needed
    String? token = auth.token;
    if (token == null) {
      print('No token in AuthProvider, checking secure storage...');
      token = await SecureStorageService.getAccessToken();
      if (token == null) {
        print('No token found in secure storage either');
        if (mounted) {
          setState(() => isLoadingUserData = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in again'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    final userId = ApiService.getUserIdFromToken(token);
    print('Loading user data for userId: $userId');

    if (userId != null) {
      try {
        final userData = await ApiService.getUser(userId).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Timeout while loading user data');
            return null;
          },
        );

        print('User data loaded: $userData');

        if (userData != null && mounted) {
          print('University name directly: ${userData['universityName']}');
          print('University object: ${userData['university']}');

          setState(() {
            firstName = userData['firstName'];
            lastName = userData['lastName'];
            // Backend returns universityName directly, not in a nested object
            universityName = userData['universityName'];
            isLoadingUserData = false;
          });
          print('User data set: firstName=$firstName, lastName=$lastName, university=$universityName');
        } else if (mounted) {
          print('User data is null - possibly 401 unauthorized');
          setState(() => isLoadingUserData = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        print('Failed to load user data: $e');
        if (mounted) {
          setState(() => isLoadingUserData = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('UserId is null, cannot load user data');
      if (mounted) {
        setState(() => isLoadingUserData = false);
      }
    }
  }

  Future<void> checkEmailVerified() async {
    setState(() => isLoading = true);
    final auth = context.read<AuthProvider>();
    String? token = auth.token;

    // If provider token is null, try reading from secure storage (fallback)
    if (token == null) {
      token = await SecureStorageService.getAccessToken();
    }

    bool? result;

    // Prefer value already decoded and stored in AuthProvider (set on login/auto-login)
    result = auth.emailVerified;
    print('AuthProvider.emailVerified: $result');

    // Prefer decoding the claim from the token (no backend call)
    if (result == null) {
      try {
        result = ApiService.getEmailVerifiedFromToken(token);
        print('Decoded email_verified from token: $result');
      } catch (e) {
        print('Error decoding token in profile: $e');
        result = null;
      }
    }

    // If token didn't include the claim, fallback to the (deprecated) endpoint
    if (result == null) {
      if (token != null && token.isNotEmpty) {
        try {
          result = await ApiService.getEmailVerifiedStatus(token);
          print('Fetched email_verified from endpoint: $result');
        } catch (e) {
          print('Failed to fetch email_verified endpoint: $e');
          result = null;
        }
      }
    }

    setState(() {
      emailVerified = result;
      isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    checkEmailVerified();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.currentUserEmail ?? "unknown@unishare.com";
    final token=auth.token;
    final userId = token != null ? ApiService.getUserIdFromToken(token) : null;

    // Compute displayed verification status synchronously: prefer local state, then provider, then decode token
    bool? displayedVerified = emailVerified ?? auth.emailVerified;
    if (displayedVerified == null && token != null && token.isNotEmpty) {
      try {
        displayedVerified = ApiService.getEmailVerifiedFromToken(token);
      } catch (e) {
        // ignore
      }
    }

    // Show loading screen while user data is being fetched
    if (isLoadingUserData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profile...'),
          ],
        ),
      );
    }

    // Show error message if we couldn't load user data
    if (firstName == null || lastName == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Unable to load profile data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your session may have expired. Please log in again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  // Try to reload data
                  await loadUserData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      );
    }

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
          Text(
            firstName != null && lastName != null
                ? "$firstName $lastName"
                : "UniShare User",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                displayedVerified == true ? "Email Verified ✅" : "Email Not Verified ❌",
                style: TextStyle(
                  color: displayedVerified == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (displayedVerified != true)
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
          if (universityName != null)
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text("University"),
              subtitle: Text(universityName!),
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

          // Butoane: Edit Profile și Reset Password
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: (userId != null && !isLoadingUserData && firstName != null && lastName != null)
                    ? () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfilePage(
                              userId: userId,
                              currentFirstName: firstName!,
                              currentLastName: lastName!,
                              currentEmail: email,
                              currentUniversity: universityName,
                            ),
                          ),
                        );
                        // Reload data if profile was updated successfully
                        if (result == true) {
                          await loadUserData();
                        }
                      }
                    : null,
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Navighează la pagina forgot-password cu userId prefilled (dacă vrei)
                  Navigator.pushNamed(context, '/forgot-password');
                },
                icon: const Icon(Icons.lock_reset),
                label: const Text("Reset Password"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
