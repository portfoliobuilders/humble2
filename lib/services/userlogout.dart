import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

  Future<void>  logoutuser(
      String _currentLocationMessage) async {
    if (_currentLocationMessage == "empty") {
      print("_currentLocationMessage is empty");
      print(_currentLocationMessage);
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    try {
      // Extract data from _currentLocationMessage
      String location =
          _currentLocationMessage.split(' at ')[0]; // Extracts the location
      DateTime now = DateTime.now();
      String startTime = now.toUtc().toIso8601String();

      // API URL
      final url =
          Uri.parse('https://ukproject-dx1c.onrender.com/api/user/userlogout');
      print(userId);
      
      // Construct request body
      final body = json.encode({
        "userId": userId,
        
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
      } else {
        print('Error: ${response.body}');
        throw Exception('Failed to send location data');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

