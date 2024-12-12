import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:humble/services/conform_checkout.dart';
import 'package:humble/view/user/ConfirmCheckoutScreen.dart';

class ConfirmCheckoutScreen extends StatefulWidget {
  const ConfirmCheckoutScreen({Key? key}) : super(key: key);

  @override
  _ConfirmCheckoutScreenState createState() => _ConfirmCheckoutScreenState();
}

class _ConfirmCheckoutScreenState extends State<ConfirmCheckoutScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // List to store the points for drawing the signature
  List<Offset?> _signaturePoints = [];

  // Method to clear the signature area
  void _clearSignature() {
    setState(() {
      _signaturePoints.clear();
    });
  }

  // Method to convert the signature to a string
  String _signatureToString() {
    // Convert the points to a list of maps
    List<Map<String, double>?> pointData = _signaturePoints
        .map((point) => point != null
            ? {'x': point.dx, 'y': point.dy} // Store x and y coordinates
            : null) // Use null to separate strokes
        .toList();

    // Convert the list to a JSON string
    return jsonEncode(pointData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Confirm Checkout',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please confirm that you have completed your shift by taking signature confirmation from nurse in-charge before your checkout.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Nurse's Name",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter nurse name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Signature',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearSignature,
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 0),
              // Custom Signature Area (Handwriting area)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black38),
                ),
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    // Record the user's drawing points
                    setState(() {
                      _signaturePoints.add(details.localPosition);
                    });
                  },
                  onPanEnd: (details) {
                    // Add a null to indicate end of a drawing stroke
                    _signaturePoints.add(null);
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: SignaturePainter(points: _signaturePoints),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Signature should only be marked by the nurse in-charge for the proper approval of checkout of your shift!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_signaturePoints.isEmpty) {
                      // Show a message if the signature is not done
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please provide a signature before proceeding.'),
                        ),
                      );
                      return;
                    }

                    // If the form and signature are valid, proceed
                    String signatureString = _signatureToString();
                    print("Signature JSON String: $signatureString".toString());
                    // Navigate to the next page
                      sendCheckOutCurrentLocation(context,signatureString);
                   
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
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

// Custom Painter to draw the signature
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black // Pen color
      ..strokeCap = StrokeCap.round // Round pen tip
      ..strokeWidth = 2.0; // Pen width

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint the canvas when the points change
  }
}
