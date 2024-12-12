import 'package:flutter/material.dart';
import 'package:humble/view/admin/attendence.dart';
import 'package:humble/view/admin/employeedetails.dart';
import 'package:humble/view/admin/useraccept.dart';
import 'package:humble/view/user/userprofile.dart';

class botto extends StatefulWidget {
  const botto({super.key});

  @override
  State<botto> createState() => _bottoState();
}

class _bottoState extends State<botto> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        DashboardScreen(),
        EmployeeattendanceListScreen(),
        EmployeeListScreen(),
        
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: const Color.fromARGB(255, 0, 0, 0)   ,      child: BottomNavigationBar(
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today),
                      label: 'Attendance',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_3_outlined),
                      label: 'User',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  selectedItemColor:Colors.blue,
                  unselectedItemColor: const Color.fromARGB(170, 15, 15, 15),
                  onTap: _onItemTapped,
                ),
              ),
            ],
          ),
    );
  }
}