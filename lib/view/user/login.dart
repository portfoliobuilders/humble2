import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:humble/view/admin/login.dart';
import 'package:humble/view/user/bottom.dart';
import 'package:humble/view/user/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  Future<void> loginUser(String email, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final url =
        Uri.parse('https://ukproject-dx1c.onrender.com/api/user/userlogin');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Decode the response body
        final responseData = jsonDecode(response.body);
        // Handle success - navigate to the next page (e.g., Leader)
        print("__________________________________________");

        await prefs.setString('userId', responseData['user']['id']);
        await prefs.setString('nurseName',responseData['user']['firstname'] + " " +responseData['user']['lastname']);
        

        // await prefs.setString('userId',responseData['userId'] );
        print('Login successful: $responseData');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Leader()),
        );
      } else {
        // Handle error - show an error message
        final errorData = jsonDecode(response.body);
        _showErrorDialog(
            errorData['message'] ?? 'Login failed. Please try again.');
      }
    } catch (error) {
      print('Error during login: $error');
      _showErrorDialog(
          'An error occurred. Please check your details.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top portion with reduced height
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(40, 130, 60, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logo.png', // Replace with your logo asset path
                  height: 50.0,
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Sign in to your Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminLogin()),
                        );
                      },
                      child: const Text(
                        'Login As Admin',
                        style: TextStyle(
                          color: Color.fromARGB(179, 14, 105, 209),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bottom portion with white background
          Expanded(
            
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30.0),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                            ),
                            const Text('Remember me'),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // Implement Forgot Password functionality
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text;

                        if (email.isNotEmpty && password.isNotEmpty) {
                          loginUser(email, password);
                        } else {
                          _showErrorDialog(
                              'Please fill in both email and password fields.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size.fromHeight(48.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()),
                            );
                            // Implement Forgot Password functionality
                          },
                          child: const Text(
                            "Don't you have an account?",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 10),
                    // Center(
                    //   child: Text(
                    //     'Or login with',
                    //     style: TextStyle(
                    //       color: Colors.black,
                    //       fontSize: 14, // You can adjust the font size
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 30.0),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     SizedBox(
                    //       height: 45,
                    //       width: 180,
                    //       child: ElevatedButton.icon(
                    //         onPressed: () {},
                    //         label: Text(
                    //           "Google",
                    //           style: TextStyle(color: Colors.black),
                    //         ),
                    //         icon: Image.asset(
                    //           'assets/google.png',
                    //           width: 24.0,
                    //           height: 24.0,
                    //         ),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor:
                    //               const Color.fromARGB(255, 248, 248, 248),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 10),
                    //     SizedBox(
                    //       height: 45,
                    //       width: 180,
                    //       child: ElevatedButton.icon(
                    //         onPressed: () {},
                    //         label: Text(
                    //           "Facebook",
                    //           style: TextStyle(color: Colors.black),
                    //         ),
                    //         icon: Image.asset(
                    //           'assets/facebook.png',
                    //           width: 26.0,
                    //           height: 26.0,
                    //         ),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor:
                    //               const Color.fromARGB(255, 248, 248, 248),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 150.0),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'By signing up, you agree to ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'the Terms of Service and Data Processing Agreement',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold, // Bold text
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Additional UI for social login, terms, etc.
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
