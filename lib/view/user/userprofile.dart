import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:humble/services/userlogout.dart';
import 'package:humble/view/user/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    
  }
  
  Future<void>  _logoutuser() async {
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    try {
      // Extract data from _currentLocationMessage
    

      // API URL
      final url =
          Uri.parse('https://ukproject-dx1c.onrender.com/api/user/userlogout');
      print(userId);
      
      // Construct request body
      final body = json.encode({
        "userId": userId,
        
      });

      // Make the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Response: ${json.decode(response.body)}');
      } else {
        print('Error: ${response.body}');
        throw Exception('Failed to send location data');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> fetchUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    final url = "https://ukproject-dx1c.onrender.com/api/user/$userId/getUserProfile";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            userData = data['user'];
            isLoading = false;
          });
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception("Failed to fetch user profile. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        title: const Text(
          'My Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userData == null
                ? const Center(child: Text("Failed to load user data."))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Section
                        Container(
                          width: 900,
                          height: 300,
                          margin: const EdgeInsets.all(18),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D5FFF),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(height:50,),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey[200],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/user (1).png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${userData!['firstname']} ${userData!['lastname']}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userData!['role'] ?? 'User',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[200],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Contact & Account Sections
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionTitle(title: 'CONTACT'),
                              const SizedBox(height: 16),
                              ContactItem(
                                icon: Icons.email_outlined,
                                text: userData!['email'] ?? 'N/A',
                              ),
                              const SizedBox(height: 32),
                              const SectionTitle(title: 'ACCOUNT'),
                              const SizedBox(height: 16),
                              AccountItem(
                                icon: Icons.person_outline,
                                title: 'Personal Data',
                                onTap: () {},
                              ),
                              AccountItem(
                                icon: Icons.lock_outline,
                                title: 'Change Password',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        // Logout Button
                        const SizedBox(height: 200),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton(
                            onPressed: () {
                              _logoutuser();Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInPage()),
                            );
                            },
                            
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D5FFF),
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}


class ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const ContactItem({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF2D5FFF),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class AccountItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const AccountItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF2D5FFF),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }
}
