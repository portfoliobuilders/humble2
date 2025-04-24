import 'package:flutter/material.dart';
import 'package:humble/provider/user_providers.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _emailSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Access your provider and call the method
        await Provider.of<UserProvider>(context, listen: false)
            .sendForgotPasswordEmailProvider(_emailController.text.trim());

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  Provider.of<UserProvider>(context, listen: false).message ??
                      'Password reset email sent successfully!',
                  style: GoogleFonts.montserrat()),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _emailSubmitted = true;
          });
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  Provider.of<UserProvider>(context, listen: false).message ??
                      'Failed to send password reset email. Please try again.',
                  style: GoogleFonts.montserrat()),
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

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Pass OTP directly as a string instead of parsing to int
        await Provider.of<UserProvider>(context, listen: false)
            .ForgotPasswordProvider(
          otp: _otpController.text.trim(),
          password: _passwordController.text,
        );

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  Provider.of<UserProvider>(context, listen: false).message ??
                      'Password reset successfully!',
                  style: GoogleFonts.montserrat()),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back after successful password reset
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  Provider.of<UserProvider>(context, listen: false).message ??
                      'Failed to reset password. Please try again.',
                  style: GoogleFonts.montserrat()),
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
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forgot Password',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _emailSubmitted
                          ? 'Enter the OTP sent to your email and your new password.'
                          : 'Please enter your email address. We will send you an OTP to reset your password.',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                // Email Field - always visible but disabled after submission
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text("Email", style: GoogleFonts.montserrat()),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_emailSubmitted,
                  style: GoogleFonts.montserrat(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 232, 232, 232), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 232, 232, 232), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 232, 232, 232),
                          width: 1.5),
                    ),
                    errorStyle: GoogleFonts.montserrat(color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                // OTP and Password fields - only visible after email submission
                if (_emailSubmitted) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Text("OTP", style: GoogleFonts.montserrat()),
                  ),
                  const SizedBox(height: 5.0),
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.montserrat(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 232, 232, 232),
                            width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 232, 232, 232),
                            width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 232, 232, 232),
                            width: 1.5),
                      ),
                      errorStyle: GoogleFonts.montserrat(color: Colors.red),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'OTP should contain numbers only';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Text("New Password", style: GoogleFonts.montserrat()),
                  ),
                  const SizedBox(height: 5.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: GoogleFonts.montserrat(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 232, 232, 232),
                            width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 232, 232, 232),
                            width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 232, 232, 232),
                            width: 1.5),
                      ),
                      errorStyle: GoogleFonts.montserrat(color: Colors.red),
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
                ],

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : (_emailSubmitted
                          ? _handleResetPassword
                          : _handleEmailSubmit),
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
                          _emailSubmitted ? 'Reset Password' : 'Submit',
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),
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