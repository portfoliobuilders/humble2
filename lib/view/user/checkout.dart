import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humble/view/user/ConfirmCheckoutScreen.dart';
import 'package:provider/provider.dart';
import 'package:humble/provider/user_providers.dart';

class ConfirmCheckoutScreen extends StatefulWidget {
  const ConfirmCheckoutScreen({Key? key}) : super(key: key);

  @override
  _ConfirmCheckoutScreenState createState() => _ConfirmCheckoutScreenState();
}

class _ConfirmCheckoutScreenState extends State<ConfirmCheckoutScreen> {
  final TextEditingController _nameController =
      TextEditingController(); // Nurse's name
  final TextEditingController _headNurseNameController =
      TextEditingController(); // Head Nurse's name
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Offset?> _signaturePoints = [];

  void _clearSignature() {
    setState(() {
      _signaturePoints.clear();
    });
  }

  String _signatureToString() {
    List<Map<String, double>?> pointData = _signaturePoints
        .map((point) => point != null ? {'x': point.dx, 'y': point.dy} : null)
        .toList();

    return jsonEncode(pointData);
  }

  Future<void> _performCheckout() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Check if form is valid
      if (!_formKey.currentState!.validate()) {
        return;
      }

      // Check if signature is drawn
      if (_signaturePoints.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide a signature before proceeding.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Convert signature to string
      String headNurseSignature = _signatureToString();

      // Get current position for checkout
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      // Perform checkout using provider with all required parameters
      final result = await userProvider.checkOutProvider(
        headNurseSignature,
        _headNurseNameController.text,
        currentPosition.latitude.toString(),
        currentPosition.longitude.toString(),
      );

      // Navigate to confirmation screen instead of popping with result
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Confirmcheckout(
              nurseInChargeName: _headNurseNameController.text,
              headNurseSignature: headNurseSignature,
              totalHoursWorked: result['totalHoursWorked'],
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Confirm Checkout',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please confirm that you have completed your shift by taking signature confirmation from nurse in-charge before your checkout.',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Head In Charge",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _headNurseNameController,
                style: GoogleFonts.montserrat(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 232, 232, 232), width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter head nurse name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Signature',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearSignature,
                    child: Text(
                      'Clear',
                      style: GoogleFonts.montserrat(color: Colors.red),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color.fromARGB(255, 232, 232, 232)),
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
              Text(
                'Signature should only be marked by the nurse in-charge for the proper approval of checkout of your shift!',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _performCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.montserrat(
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
