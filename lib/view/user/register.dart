import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:humble/view/user/login.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('https://ukproject-dx1c.onrender.com/api/user/userregister');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create user');
    }
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final bool _rememberMe = false;
  DateTime? _selectedDate;
  String _selectedCountryCode = "+91"; // Default country code for India
  String _selectedFlag = '🇮🇳'; // Default flag for India

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top portion with reduced height
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey[900]!], // Gradient background
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(40, 60, 60, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logo.png', // Replace with your logo asset path
                  height: 50.0, // Adjust logo size
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38.0, // Larger font for prominence
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
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
                      child: const Text(
                        'Login?',
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              hintText: 'First Name',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: TextField(
                            controller: _secondNameController,
                            decoration: InputDecoration(
                              hintText: 'Second Name',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
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
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: _selectedDate == null
                                ? 'Date of Birth'
                                : DateFormat('dd-MM-yyyy').format(_selectedDate!),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Phone Number',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: GestureDetector(
                                onTap: () async {
                                  // Show a dialog to select country
                                  final result = await _showCountryPicker();
                                  if (result != null) {
                                    setState(() {
                                      _selectedFlag = result['flag']!;
                                      _selectedCountryCode = result['code']!;
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedFlag,
                                      style: const TextStyle(fontSize: 17.0),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      _selectedCountryCode,
                                      style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                    ),
                                    const SizedBox(width: 8.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Set Password',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_firstNameController.text.isNotEmpty &&
                            _secondNameController.text.isNotEmpty &&
                            _emailController.text.isNotEmpty &&
                            _phoneNumberController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty &&
                            _selectedDate != null) {
                          final userData = {
                            "firstname": _firstNameController.text,
                            "lastname": _secondNameController.text,
                            "email": _emailController.text,
                            "dateOfBirth": DateFormat('yyyy-MM-dd').format(_selectedDate!),
                            "phoneNumber": _selectedCountryCode + _phoneNumberController.text,
                            "password": _passwordController.text,
                          };

                          try {
                            final response = await createUser(userData);
                            print("User registered: $response");
                            // Navigate to the next page (e.g., Leader page)
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignInPage()),
                            );
                          } catch (e) {
                            print('Error registering user: $e');
                          }
                        } else {
                          print('Please fill all the fields');
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
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
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

  Future<Map<String, String>?> _showCountryPicker() async {
    // Country list
    final countries = [
      {'flag': '🇮🇳', 'code': '+91', 'name': 'India'},
      {'flag': '🇺🇸', 'code': '+1', 'name': 'United States'},
      {'flag': '🇬🇧', 'code': '+44', 'name': 'United Kingdom'},
      {'flag': '🇦🇺', 'code': '+61', 'name': 'Australia'},
      {'flag': '🇨🇦', 'code': '+1', 'name': 'Canada'},
      {'flag': '🇩🇪', 'code': '+49', 'name': 'Germany'},
      {'flag': '🇯🇵', 'code': '+81', 'name': 'Japan'},
    ];

    // Show dialog
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Country'),
          content: SingleChildScrollView(
            child: Column(
              children: countries.map((country) {
                return ListTile(
                  leading: Text(country['flag']!),
                  title: Text(country['name']!),
                  onTap: () {
                    Navigator.pop(context, country);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
