import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:humble/view/user/user_login.dart';
import 'package:humble/provider/user_providers.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  
  String _phoneNumber = '';
  String _countryCode = 'GB';
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // In _handleGoogleSignIn method of RegisterPage
Future<void> _handleGoogleSignIn() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    print('Starting Google sign-in process');
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) {
      print('Google sign-in was canceled by user');
      _showErrorSnackBar(context, 'Google sign-in cancelled.');
      return;
    }
    
    print('Google user signed in: ${googleUser.email}');
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? googleToken = googleAuth.idToken;
    
    if (googleToken == null) {
      print('Failed to obtain Google token');
      _showErrorSnackBar(context, 'Failed to authenticate with Google.');
      return;
    }
    
    print('Google token obtained: ${googleToken.substring(0, 10)}...');
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.registerWithGoogleProvider(googleToken);
    
    print('Registration result: $success');
    
    if (success) {
      _showSuccessSnackBar(context, 'Google registration successful!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    } else {
      _showErrorSnackBar(context, 'Google registration failed. Please try again.');
    }
  } catch (e) {
    print('Detailed Google sign-in error: $e');
    if (e is PlatformException) {
      String errorMessage = 'Google sign-in error (${e.code})';
      if (e.code == '10') {
        errorMessage += ': Developer Error. Check SHA-1 fingerprint and package name in Google Cloud Console.';
      } else if (e.code == 'sign_in_failed') {
        errorMessage += ': ${e.message ?? 'Unknown sign-in failure'}. Verify app configuration.';
      } else if (e.code == 'network_error') {
        errorMessage += ': Network connectivity issue. Please check your internet connection.';
      } else {
        errorMessage += ': ${e.message ?? 'Unknown error'}';
      }
      _showErrorSnackBar(context, errorMessage);
    } else {
      _showErrorSnackBar(context, 'Error signing in with Google: $e');
    }
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _handleFacebookSignIn() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Implement Facebook sign-in logic here
      // This is a placeholder for Facebook authentication implementation
      
      _showErrorSnackBar(context, 'Facebook login not implemented yet.');
    } catch (e) {
      _showErrorSnackBar(context, 'Error signing in with Facebook: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.grey[900]!
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(40, 60, 60, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 50.0,
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Register',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 38.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Text(
                      'Already have an account?',
                      style: GoogleFonts.montserrat(
                        color: Colors.white70,
                        fontSize: 16.0,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      },
                      child: Text(
                        'Login?',
                        style: GoogleFonts.montserrat(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 5.0),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text("First Name", style: GoogleFonts.montserrat()),
                              ),
                              const SizedBox(height: 5.0),
                              TextField(
                                controller: _firstNameController,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text("Last Name", style: GoogleFonts.montserrat()),
                              ),
                              const SizedBox(height: 5.0),
                              TextField(
                                controller: _secondNameController,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text("Email", style: GoogleFonts.montserrat()),
                    ),
                    const SizedBox(height: 5.0),
                    TextField(
                      controller: _emailController,
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
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text("Phone Number", style: GoogleFonts.montserrat()),
                    ),
                    const SizedBox(height: 5.0),
                    IntlPhoneField(
                      style: GoogleFonts.montserrat(),
                      dropdownTextStyle: GoogleFonts.montserrat(),
                      flagsButtonPadding: const EdgeInsets.all(8),
                      dropdownIconPosition: IconPosition.trailing,
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
                      ),
                      initialCountryCode: 'GB',
                      onChanged: (phone) {
                        setState(() {
                          _phoneNumber = phone.completeNumber;
                          _countryCode = phone.countryCode;
                        });
                      },
                    ),
                    const SizedBox(height: 0.0),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text("Password", style: GoogleFonts.montserrat()),
                    ),
                    const SizedBox(height: 5.0),
                    TextField(
                      controller: _passwordController,
                      style: GoogleFonts.montserrat(),
                      obscureText: _obscurePassword,
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Color.fromARGB(255, 232, 232, 232),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text;
                              final firstName = _firstNameController.text.trim();
                              final lastName = _secondNameController.text.trim();

                              if (email.isNotEmpty && 
                                  password.isNotEmpty && 
                                  firstName.isNotEmpty && 
                                  lastName.isNotEmpty && 
                                  _phoneNumber.isNotEmpty) {
                                
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                userProvider.registerProvider(
                                  email: email,
                                  password: password,
                                  name: '$firstName $lastName',
                                  phoneNumber: _phoneNumber,
                                ).then((success) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  
                                  if (success) {
                                    _showSuccessSnackBar(context, 'Registration successful!');
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => SignInPage()),
                                    );
                                  } else {
                                    _showErrorSnackBar(context, 'Registration failed. Please try again.');
                                  }
                                });
                              } else {
                                _showErrorSnackBar(context, 'Please fill all fields');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size.fromHeight(48.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Register',
                              style: GoogleFonts.montserrat(
                                color: Colors.white, 
                                fontSize: 16.0
                              ),
                            ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Color.fromARGB(255, 232, 232, 232),
                            thickness: 1,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ),
                        Text(
                          'Or register with',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Color.fromARGB(255, 232, 232, 232),
                            thickness: 1,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 45,
                          width: 180,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _handleGoogleSignIn,
                            label: Text(
                              "Google",
                              style: GoogleFonts.montserrat(color: Colors.black),
                            ),
                            icon: Image.asset(
                              'assets/google.png',
                              width: 24.0,
                              height: 24.0,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 232, 232, 232)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 45,
                          width: 180,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _handleFacebookSignIn,
                            label: Text(
                              "Facebook",
                              style: GoogleFonts.montserrat(color: Colors.black),
                            ),
                            icon: Image.asset(
                              'assets/facebook.png',
                              width: 26.0,
                              height: 26.0,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 232, 232, 232)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'By registering, you agree to ',
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 12.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: 'the Terms of Service and Data Processing Agreement',
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}