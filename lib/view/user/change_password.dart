import 'package:flutter/material.dart';
import 'package:humble/provider/user_providers.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _reEnterPasswordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureReEnterPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Debug print to help identify issues
        print("Attempting to change password");
        print("Current password: ${_currentPasswordController.text.trim()}");
        print("New password: ${_newPasswordController.text.trim()}");

        await Provider.of<UserProvider>(context, listen: false)
            .changePasswordProvider(
          currentPassword: _currentPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
        );

        if (mounted) {
          print("Password change successful");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Provider.of<UserProvider>(context, listen: false).message ??
                    'Password changed successfully!',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Go back on success
        }
      } catch (e) {
        // Print error for debugging
        print("Password change error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Provider.of<UserProvider>(context, listen: false).message ??
                    'Failed to change password.',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Password',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.security,
                                color: const Color(0xFF2196F3),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Security Information',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Please enter your current password and set a new password to update your account security.',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Current Password
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    "Current Password",
                    style: GoogleFonts.montserrat(),
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _currentPasswordController,
                  // obscureText: _obscureCurrentPassword,
                  style: GoogleFonts.montserrat(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232),
                        width: 1.5,
                      ),
                    ),
                    // suffixIcon: IconButton(
                    //   icon: Icon(
                    //     _obscureCurrentPassword
                    //         ? Icons.visibility_off
                    //         : Icons.visibility,
                    //     color: Colors.grey[300],
                    //   ),
                    //   onPressed: () {
                    //     setState(() {
                    //       _obscureCurrentPassword = !_obscureCurrentPassword;
                    //     });
                    //   },
                    // ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    "New Password",
                    style: GoogleFonts.montserrat(),
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _newPasswordController,
                  // obscureText: _obscureNewPassword,
                  style: GoogleFonts.montserrat(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232),
                        width: 1.5,
                      ),
                    ),
                    // suffixIcon: IconButton(
                    //   icon: Icon(
                    //     _obscureNewPassword
                    //         ? Icons.visibility_off
                    //         : Icons.visibility,
                    //     color: Colors.grey[300],
                    //   ),
                    //   onPressed: () {
                    //     setState(() {
                    //       _obscureNewPassword = !_obscureNewPassword;
                    //     });
                    //   },
                    // ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Re-enter New Password
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    "Re-enter New Password",
                    style: GoogleFonts.montserrat(),
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _reEnterPasswordController,
                  obscureText: _obscureReEnterPassword,
                  style: GoogleFonts.montserrat(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232),
                        width: 1.5,
                      ),
                    ),
                    // suffixIcon: IconButton(
                    //   icon: Icon(
                    //     _obscureReEnterPassword
                    //         ? Icons.visibility_off
                    //         : Icons.visibility,
                    //     color: Colors.grey[300],
                    //   ),
                    //   onPressed: () {
                    //     setState(() {
                    //       _obscureReEnterPassword = !_obscureReEnterPassword;
                    //     });
                    //   },
                    // ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please re-enter your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          'Change Password',
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 16),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(color: Colors.black),
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
