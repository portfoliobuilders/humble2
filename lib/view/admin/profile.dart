import 'package:flutter/material.dart';
import 'package:humble/provider/admin_providers.dart';
import 'package:humble/view/admin/admin_login.dart';
import 'package:humble/view/admin/change_password.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  // Dummy user data
  final Map<String, dynamic> dummyUser = {
    'name': 'John Doe',
    'role': 'Floor Manager',
    'email': 'john.doe@example.com',
    'phoneNumber': '+1 234 567 8901',
    'address': 'Central Park'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      bottomNavigationBar: SizedBox(height: 0), // Force extension to bottom
      body: SafeArea(
        child: Consumer<AdminProvider>(
          builder: (context, userProvider, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    // App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 60,
                          ),
                          const Spacer(),
                          Text(
                            'My Profile',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    SizedBox(height: 80),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height - 150,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(height: 110),

                                Text(
                                  dummyUser['name'].toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dummyUser['role'],
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                // Contact Section
                                _buildSectionHeader('CONTACT'),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildContactItem(
                                          Icons.email, dummyUser['email']),
                                      const SizedBox(height: 16),
                                      _buildContactItem(Icons.phone,
                                          dummyUser['phoneNumber']),
                                      const SizedBox(height: 16),
                                      _buildContactItem(Icons.location_on,
                                          dummyUser['address']),
                                    ],
                                  ),
                                ),

                                // Account Section
                                const SizedBox(height: 24),
                                _buildSectionHeader('ACCOUNT'),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildAccountItem(
                                        context,
                                        Icons.person_outline,
                                        'Personal Data',
                                        () {}, // Add navigation
                                      ),
                                      _buildAccountItem(
                                        context,
                                        Icons.lock_outline,
                                        'Change Password',
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AdminChangePasswordScreen()),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 30),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final userProvider =
                                          Provider.of<AdminProvider>(context,
                                              listen: false);

                                      userProvider.logoutProvider(context);

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AdminLogin()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2196F3),
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Logout',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 100, // Adjust this value to position the image correctly
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 150,
                      height: 150, // Fixed height instead of double.infinity
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.blue[100],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/image.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2196F3), size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.roboto(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAccountItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: const Color(0xFF2196F3), size: 22),
      title: Text(
        title,
        style: GoogleFonts.roboto(fontSize: 14),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
      onTap: onTap,
    );
  }
}
