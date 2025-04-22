import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:humble/view/admin/all_employees.dart';
import 'package:humble/view/admin/homescreen.dart';
import 'package:humble/view/admin/location_home.dart';
import 'package:humble/view/admin/profile.dart';


class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressTime;

  final List<Widget> _pages = [
    DashboardScreen(),
    UserManagementScreen(),
    WorkSitesHome(),
    AdminProfileScreen(),
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
                  gap: 8,
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