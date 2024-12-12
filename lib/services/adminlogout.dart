import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void>  _adminlogout() async {
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    try {
      // Extract data from _currentLocationMessage
    

      // API URL
      final url =
          Uri.parse('https://ukproject-dx1c.onrender.com/api/admin/logout');
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