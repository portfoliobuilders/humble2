
import 'dart:convert';
import 'package:http/http.dart' as http;

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    String userId = userData['id'];
    final url =
        Uri.parse('https://ukproject-dx1c.onrender.com/api/admin/admitUser');

    // Correct the request body format: Encode userData as JSON
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}), // Properly encode the userData
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create user');
    }
  }