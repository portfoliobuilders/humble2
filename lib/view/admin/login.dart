import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:humble/view/admin/adminbottom.dart';
import 'package:humble/view/user/login.dart';

class AdminLogin extends StatefulWidget {
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  // Function to handle user login
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('https://ukproject-dx1c.onrender.com/api/admin/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Success: return decoded response
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> loginUser(String email, String password) async {
    final url =
        Uri.parse('https://ukproject-dx1c.onrender.com/api/admin/login');
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
        print('Login successful: $responseData');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => botto()),
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
          'An error occurred. Please check your internet connection.');
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
                          MaterialPageRoute(
                              builder: (context) => SignInPage()),
                        );
                      },
                      child: const Text(
                        'Login As User',
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
                    const SizedBox(height: 32.0),
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
                     
                SizedBox(height: 10),
                 
                    const SizedBox(height: 30.0),
                  
                    const SizedBox(height: 130.0),
                   
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
