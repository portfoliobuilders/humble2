import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:humble/view/user/ConfirmCheckoutScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> sendCheckOutCurrentLocation(context, signatureString) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString("userId");
  String? nurseName = prefs.getString("nurseName");
  try {
    DateTime now = DateTime.now();
    String endTime = now.toUtc().toIso8601String();
    final url =
        Uri.parse('https://ukproject-dx1c.onrender.com/api/user/submitNurseSignature');
    print(userId);
    print(endTime);
    print(nurseName);
    print(signatureString);

    final body = json.encode({
      "userId": userId,
      "nurseName": nurseName,
      "endTime": endTime,
      "nurseSignature": signatureString,
     
    });

    // Make the POST request
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    // Handle response
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Response: ${json.decode(response.body)}');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Confirmcheckout()),
      );
    } else {
      print('Error: ${response.body}');
      throw Exception('Failed to send location data');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
