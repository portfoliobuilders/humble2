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

  Future<http.Response> assignStudentToLocationAPI(
    String token,
    String locationId,
    List<String> studentId,
    List<String> assignedDates,
  ) async {
    final url = Uri.parse('$baseUrl/admin/assignLocation');
    try {
      final requestBody = {
        'locationId': locationId,
        'studentId': studentId,
        'assignedDates': assignedDates,
      };

      print('Sending request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      return response;
    } catch (e) {
      print('Error assigning student to location: $e');
      rethrow;
    }
  }

  Future<http.Response> proposeDatesAPI(
  String token,
  String userId,
  List<Map<String, String>> proposedDates,
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

  Future<http.Response> fetchAssignedDatesAPI(
      String token, String userId) async {
    final url = Uri.parse('$baseUrl/admin/getAssignedDates/$userId');
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
      print('Error in fetchAssignedDatesAPI: $e');
      rethrow;
    }
  }

  Future<http.Response> sendForgotPasswordEmail({
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/forgotPassword');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> ForgotPasswordAPI({
    required String otp,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/resetpassword');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'otp': otp,
          'password': password,
        }),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> changePasswordAPI({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/changePassword');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> editAssignedLocationAPI(
    String token,
    String studentId,
    String dateToEdit,
    String newDate,
    String newLocationId,
  ) async {
    final url =
        Uri.parse('$baseUrl/admin/editAssignedlocation');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'studentId': studentId,
          'dateToEdit': dateToEdit,
          'newDate': newDate,
          'newLocationId': newLocationId,
        }),
      );
      return response;
    } catch (e) {
      print('Error editing assigned location: $e');
      rethrow;
    }
  }

  Future<http.Response> deleteAssignedLocationAPI(
    String token,
    String studentId,
    String dateToDelete,
  ) async {
    final url = Uri.parse('$baseUrl/admin/delteDates');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'studentId': studentId,
          'dateToDelete': dateToDelete,
        }),
      );
      return response;
    } catch (e) {
      print('Error deleting assigned location: $e');
      rethrow;
    }
  }


}
