import 'dart:convert';

import 'package:http/http.dart' as http;

class AdminApi {
  String baseUrl = 'https://uknew.onrender.com/api';

  Future<http.Response> adminloginAPI(String email, String password) async {
    final url = Uri.parse('$baseUrl/admin/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> userLogoutAPI(String token) async {
    final url = Uri.parse('$baseUrl/logout');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> fetchDataAPI(String token) async {
    final url = Uri.parse('$baseUrl/admin/getCount');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to fetch data: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchDataAPI: $e');
      rethrow;
    }
  }

  Future<http.Response> fetchAllUsersAPI(String token) async {
    // Implementation from your code
    final url = Uri.parse('$baseUrl/admin/getallUsers');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      print('Error in fetchAllUsers: $e');
      rethrow;
    }
  }

  Future<http.Response> approveActionAPI(String token, String userId) async {
    final url = Uri.parse('$baseUrl/admin/approve/$userId');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"action": "approve", "userId": userId}),
      );
      return response;
    } catch (e) {
      print('Error approving action: $e');
      rethrow;
    }
  }

  Future<http.Response> fetchReadyToWorkUsersAPI(String token) async {
    final url = Uri.parse('$baseUrl/admin/readytoWork');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      print('Error in fetchReadyToWorkUsersAPI: $e');
      rethrow;
    }
  }

  Future<http.Response> fetchLocationsAPI(String token) async {
    final url =
        Uri.parse('$baseUrl/admin/getallLocation'); // Update the path as needed
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      print('Error in fetchLocationsAPI: $e');
      rethrow;
    }
  }

  Future<http.Response> createLocationAPI(
      String token, String name, String latitude, String longitude) async {
    final url = Uri.parse('$baseUrl/admin/addLocations');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      return response;
    } catch (e) {
      print('Error creating location: $e');
      rethrow;
    }
  }

  Future<http.Response> editLocationAPI(
    String token,
    String locationId,
    String name,
    String latitude,
    String longitude,
  ) async {
    final url = Uri.parse('$baseUrl/admin/editLocation/$locationId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      return response;
    } catch (e) {
      print('Error editing location: $e');
      rethrow;
    }
  }

  Future<http.Response> deleteLocationAPI(
  String token,
  String locationId,
) async {
  final url = Uri.parse('$baseUrl/admin/deleteLocation/$locationId'); 
  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  } catch (e) {
    print('Error deleting location: $e');
    rethrow;
  }
}



Future<http.Response> assignLocationAPI(
  String token,
  String studentId,
  String locationId,
  List<String> assignedDates,
) async {
  final url = Uri.parse('$baseUrl/admin/assignLocation'); 
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'studentId': studentId,
        'locationId': locationId,
        'assignedDates': assignedDates,
      }),
    );
    return response;
  } catch (e) {
    print('Error marking student location: $e');
    rethrow;
  }
}

Future<http.Response> proposeDatesAPI(
  String token,
  String userId,
  List<String> proposedDates,
) async {
  final url = Uri.parse('$baseUrl/admin/assignWorkdates');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'proposedDates': proposedDates,
      }),
    );
    return response;
  } catch (e) {
    print('Error proposing dates: $e');
    rethrow;
  }
}



}
