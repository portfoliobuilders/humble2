import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:humble/view/user/attendance.dart';
import 'package:humble/view/user/date_selection.dart';
import 'package:humble/view/user/homepage.dart';
import 'package:humble/view/user/userprofile.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressTime;

  final List<Widget> _pages = [
    HomeScreen(),
    AttendanceScreen(),
    ReadyToWorkCalendarScreen(),
    UserProfileScreen(),
  ];

  final GlobalKey<NavigatorState> _currentNavigatorKey =
      GlobalKey<NavigatorState>();

  Future<bool> _onWillPop() async {
    final currentNavigator = _currentNavigatorKey.currentState;
    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    }

    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Don't exit the app
    }

    // Exit the app completely instead of navigating back
    SystemNavigator.pop();
    return false; // We handle the app exit ourselves
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: _pages[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 4,
                  activeColor: Colors.white,
                  iconSize: 24,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: Duration(milliseconds: 300),
                  tabBackgroundColor: Colors.blue.shade300,
                  color: Colors.black,
                  tabs: [
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
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        ));
  }
}
