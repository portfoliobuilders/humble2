import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:humble/services/conform_checkout.dart';
import 'package:humble/view/user/bottom.dart';
import 'package:humble/view/user/homepage.dart';

class Confirmcheckout extends StatefulWidget {
  const Confirmcheckout({super.key});

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
          // Ensuring the previous page is visible
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0), // Transparent to see through
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
            child: Container(
              color: Colors.white.withOpacity(0.6), // Semi-transparent overlay
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
                    
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Leader()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize:
                          const Size(350, 50), // Set width and height here
                    ),
                    child: const Text(
                      'Submit',
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