import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:humble/provider/user_providers.dart';
import 'package:humble/view/user/attendance.dart';
import 'package:humble/view/user/date_selection.dart';
import 'package:humble/view/user/userprofile.dart';
import 'package:humble/view/user/homepage.dart';
import 'package:provider/provider.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  // Create pages list with lazy loading
  final List<Widget> _pages = [
    HomeScreen(),
    AttendanceScreen(),
    ReadyToWorkCalendarScreen(),
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      if (provider.token != null) {
        provider.fetchWorkingHoursProvider();
      }
    }

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
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: GNav(
          backgroundColor: Colors.white,
          color: Colors.black54,
          activeColor: Colors.blue,
          tabBackgroundColor: Colors.blue.withOpacity(0.2),
          gap: 4,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            _onItemTapped(index);
          },
          tabs: const [
            GButton(
              icon: Icons.home_outlined,
              text: 'Home',
            ),
            GButton(
              icon: Icons.assignment_outlined,
              text: 'Attendance',
            ),
            GButton(
              icon: Icons.calendar_month_outlined,
              text: 'Availability',
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
