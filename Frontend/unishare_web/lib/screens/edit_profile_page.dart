import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final String currentFirstName;
  final String currentLastName;
  final String currentEmail;
  final String? currentUniversity;

  const EditProfilePage({
    super.key,
    required this.userId,
    required this.currentFirstName,
    required this.currentLastName,
    required this.currentEmail,
    this.currentUniversity,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  String? _selectedUniversityId;
  bool _loading = false;
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _generalError;

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
      filled: true,
      fillColor: Colors.white,
      errorText: errorText,
      errorMaxLines: 2,
    );
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.currentFirstName);
    _lastNameController = TextEditingController(text: widget.currentLastName);
    _emailController = TextEditingController(text: widget.currentEmail);

    // Fetch universities for dropdown
    final auth = context.read<AuthProvider>();

    print('EditProfilePage initState - currentUniversity: "${widget.currentUniversity}"');
    print('Auth universities count: ${auth.universities.length}');

    // Check if universities are already loaded
    if (auth.universities.isNotEmpty && widget.currentUniversity != null) {
      // Universities already loaded, set the value immediately
      try {
        print('Looking for match among ${auth.universities.length} universities');
        for (var u in auth.universities) {
          print('  - University: "${u.name}" (ID: ${u.id})');
        }

        final matchingUniversity = auth.universities.firstWhere(
              (u) => u.name == widget.currentUniversity,
          orElse: () => auth.universities.first,
        );
        _selectedUniversityId = matchingUniversity.id;
        print('✓ Set initial university ID: $_selectedUniversityId for name: ${widget.currentUniversity}');
      } catch (e) {
        print('✗ Error setting initial university: $e');
      }
    } else {
      // Need to fetch universities first
      print('Fetching universities...');
      auth.fetchUniversities().then((_) {
        print('Universities fetched, count: ${auth.universities.length}');
        if (widget.currentUniversity != null && mounted) {
          try {
            final universities = context.read<AuthProvider>().universities;
            if (universities.isNotEmpty) {
              print('Looking for match (after fetch) among ${universities.length} universities');
              for (var u in universities) {
                print('  - University: "${u.name}" (ID: ${u.id})');
              }

              final matchingUniversity = universities.firstWhere(
                    (u) => u.name == widget.currentUniversity,
                orElse: () => universities.first,
              );
              if (mounted) {
                setState(() {
                  _selectedUniversityId = matchingUniversity.id;
                  print('✓ Set university ID after fetch: $_selectedUniversityId for name: ${widget.currentUniversity}');
                });
              }
            }
          } catch (e) {
            print('✗ Error setting initial university after fetch: $e');
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Clear previous errors
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _generalError = null;
      _loading = true;
    });

    try {
      // Convert university ID to name for backend
      // Note: We need to determine if university was changed from the initial value
      String? universityName;
      bool universityChanged = false;

      // Get initial university ID for comparison
      String? initialUniversityId;
      if (widget.currentUniversity != null) {
        final auth = context.read<AuthProvider>();
        try {
          final initialUniversity = auth.universities.firstWhere(
                (u) => u.name == widget.currentUniversity,
            orElse: () => auth.universities.first,
          );
          initialUniversityId = initialUniversity.id;
        } catch (e) {
          // Couldn't find initial university, treat as changed
          initialUniversityId = null;
        }
      }

      // Check if university selection changed
      if (_selectedUniversityId != initialUniversityId) {
        universityChanged = true;

        if (_selectedUniversityId != null) {
          // Convert selected ID to name
          final auth = context.read<AuthProvider>();
          try {
            final university = auth.universities.firstWhere(
                  (u) => u.id == _selectedUniversityId,
            );
            universityName = university.name;
          } catch (e) {
            setState(() {
              _generalError = 'Selected university not found. Please try again.';
              _loading = false;
            });
            return;
          }
        } else {
          // User selected "(No university)" - send null to clear
          universityName = null;
        }
      }

      final result = await ApiService.updateUser(
        userId: widget.userId,
        firstName: _firstNameController.text.trim().isNotEmpty
            ? _firstNameController.text.trim()
            : null,
        lastName: _lastNameController.text.trim().isNotEmpty
            ? _lastNameController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        universityName: universityChanged ? universityName : null,
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        // Handle validation errors
        print('Update failed with result: $result');
        final errors = result['errors'] as Map<String, dynamic>?;
        print('Parsed errors: $errors');
        if (errors != null) {
          setState(() {
            // Check for field-specific errors
            if (errors.containsKey('FirstName')) {
              final fnErrors = errors['FirstName'];
              if (fnErrors is List && fnErrors.isNotEmpty) {
                _firstNameError = fnErrors.first.toString();
              }
            }
            if (errors.containsKey('LastName')) {
              final lnErrors = errors['LastName'];
              if (lnErrors is List && lnErrors.isNotEmpty) {
                _lastNameError = lnErrors.first.toString();
              }
            }
            if (errors.containsKey('Email')) {
              final emailErrors = errors['Email'];
              if (emailErrors is List && emailErrors.isNotEmpty) {
                _emailError = emailErrors.first.toString();
              }
            }
            if (errors.containsKey('general')) {
              final generalErrors = errors['general'];
              if (generalErrors is List && generalErrors.isNotEmpty) {
                _generalError = generalErrors.first.toString();
              }
            }

            // If no specific error found, show first error as general
            if (_firstNameError == null &&
                _lastNameError == null &&
                _emailError == null &&
                _generalError == null) {
              final firstKey = errors.keys.first;
              final firstError = errors[firstKey];
              if (firstError is List && firstError.isNotEmpty) {
                _generalError = firstError.first.toString();
              } else {
                _generalError = firstError.toString();
              }
            }
          });
        } else {
          setState(() => _generalError = 'Failed to update profile');
        }
      }
    } catch (e) {
      setState(() => _generalError = 'Error updating profile: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center( // NOU: Centram conținutul SingleChildScrollView
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Limită lățimea pe desktop
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // General Error Box
                if (_generalError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _generalError!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Loading indicator at the top
                if (_loading) const LinearProgressIndicator(color: Colors.deepPurple),
                const SizedBox(height: 16),

                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 16),

                // --- First Name ---
                TextField(
                  controller: _firstNameController,
                  decoration: _getInputDecoration(
                    'First Name',
                    Icons.person_outline,
                    errorText: _firstNameError,
                  ),
                ),
                const SizedBox(height: 16),

                // --- Last Name ---
                TextField(
                  controller: _lastNameController,
                  decoration: _getInputDecoration(
                    'Last Name',
                    Icons.person_outline,
                    errorText: _lastNameError,
                  ),
                ),
                const SizedBox(height: 16),

                // --- Email ---
                TextField(
                  controller: _emailController,
                  decoration: _getInputDecoration(
                    'Email',
                    Icons.email_outlined,
                    errorText: _emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // --- University Dropdown ---
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedUniversityId,
                      decoration: _getInputDecoration('University', Icons.school_outlined),
                      items: auth.isUniversitiesLoading
                          ? [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Loading universities...'),
                        )
                      ]
                          : auth.universities.isEmpty
                          ? [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('No universities available'),
                        )
                      ]
                          : [
                        // Add null option to allow clearing university
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('(No university)'),
                        ),
                        ...auth.universities
                            .map<DropdownMenuItem<String>>(
                              (u) => DropdownMenuItem<String>(
                            value: u.id,
                            child: Text("${u.name} (${u.shortCode})"),
                          ),
                        )
                            .toList(),
                      ],
                      onChanged: auth.isUniversitiesLoading || auth.universities.isEmpty
                          ? null
                          : (value) {
                        setState(() => _selectedUniversityId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),

                // --- Save Changes Button ---
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: _loading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                        : const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- Cancel Button ---
                TextButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.deepPurple.shade700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}