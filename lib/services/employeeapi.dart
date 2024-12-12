import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:humble/model/employeemodel.dart';
 // Fetch employees data from the API

Future<List<Employeemodel>> fetchEmployeesmodel() async {
  final response = await http.get(
    Uri.parse('https://ukproject-dx1c.onrender.com/api/admin/getAllUsers'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);

    // Debugging: Print the API response to verify the structure
    print('Response JSON: $json');

    if (json['success'] == true) {
      final List<dynamic> users = json['users'];
      
      // Map JSON array to a list of Employeemodel objects
      return users.map((item) => Employeemodel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch users: ${json['message']}');
    }
  } else {
    throw Exception('Failed to load employees. Status code: ${response.statusCode}');
  }
}
