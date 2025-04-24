import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
        SnackBar(
          content: Text(
            'Press back again to exit',
            style: GoogleFonts.montserrat(),
          ),
          duration: const Duration(seconds: 2),
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
            decoration: const BoxDecoration(
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: const Duration(milliseconds: 300),
                  tabBackgroundColor: Colors.blue.shade300,
                  color: Colors.black,
                  tabs: [
                    GButton(
                      icon: Icons.home_outlined,
                      text: 'Home',
                      textStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    GButton(
                      icon: Icons.people_outline,
                      text: 'Employees',
                      textStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    GButton(
                      icon: Icons.location_on_outlined,
                      text: 'Locations',
                      textStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    GButton(
                      icon: Icons.person_outline,
                      text: 'Profile',
                      textStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
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