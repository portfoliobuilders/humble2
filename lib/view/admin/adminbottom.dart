import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:humble/view/admin/homescreen.dart';
import 'package:humble/view/admin/all_employees.dart';
import 'package:humble/view/admin/locations.dart';
import 'package:humble/view/admin/profile.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardScreen(),
    UserManagementScreen(),
    WorkSitesScreen(),
    AdminProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20,1,20,30),
        child: GNav(
          backgroundColor: Colors.white,
          color: Colors.black54,
          activeColor: Colors.blue,
          tabBackgroundColor: Colors.blue.withOpacity(0.2),
          gap: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(
              icon: Icons.home_outlined,
              text: 'Home',
            ),
            GButton(
              icon: Icons.people_outline,
              text: 'Employees',
            ),
            GButton(
              icon: Icons.location_on_outlined,
              text: 'Locations',
            ),
            GButton(
              icon: Icons.person_outline,
              text: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
