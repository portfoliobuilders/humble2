import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:humble/view/user/bottom.dart';

class Confirmcheckout extends StatefulWidget {
  final String nurseInChargeName;
  final String headNurseSignature;
  final dynamic totalHoursWorked;
  
  const Confirmcheckout({
    Key? key,
    required this.nurseInChargeName,
    required this.headNurseSignature,
    required this.totalHoursWorked,
  }) : super(key: key);

  @override
  State<Confirmcheckout> createState() => _ConfirmcheckoutState();
}

class _ConfirmcheckoutState extends State<Confirmcheckout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  // color: Colors.white.withOpacity(0.3),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content of the current page
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset('assets/confirm.png', height: 150, width: 150),
                  const SizedBox(height: 30),
                  const Text(
                    'Checkout Successful!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nurse In-Charge: ${widget.nurseInChargeName}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Total Hours Worked: ${widget.totalHoursWorked}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'You’ve officially clocked out for the day.',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Thank you for your hard work! Time to relax and enjoy your break.',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BottomNavigationScreen(),
                        ),
                        (Route<dynamic> route) => false, // Remove all previous routes
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(350, 50),
                    ),
                    child: const Text(
                      'Return to Home',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}