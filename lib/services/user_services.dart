import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:humble/model/user_models.dart';

class UserApi {
  String baseUrl = 'https://uknew.onrender.com/api';

  Future<http.Response> userregisterAPI(
    String email,
    String password,
    String name,
    String phoneNumber,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred during registration: $e');
    }
  }

  Future<http.Response> registerWithGoogle(String googleToken) async {
    final url = Uri.parse('https://uknew.onrender.com/auth/google');
    try {
      print('Making API call to ${url.toString()}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': googleToken}),
      );

      print('API response received: ${response.statusCode}');
      return response;
    } catch (e) {
      print('API call exception: $e');
      throw Exception('An error occurred during Google registration: $e');
    }
  }

  Future<http.Response> userloginAPI(String email, String password) async {
    final url = Uri.parse('$baseUrl/student/login');
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

  Future<http.Response> fetchUserProfileAPI(String token) async {
    final url = Uri.parse('$baseUrl/student/getprofile');
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
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchUserProfileAPI: $e');
      rethrow;
    }
  }

  Future<http.Response> readyToWorkAPI(
      String token, List<String> readyToWorkDates) async {
    final url = Uri.parse('$baseUrl/student/redytoWork');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"readyToWorkDates": readyToWorkDates}),
      );
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      return response;
    } catch (e) {
      print('Error updating availability: $e');
      rethrow;
    }
  }

  Future<AssignedLocationResponse> fetchLocationAPI(String token) async {
    final url = Uri.parse('$baseUrl/student/getLocation');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return AssignedLocationResponse.fromJson(responseBody);
      } else if (response.statusCode == 404) {
        // 404 means no locations assigned for this student yet - this is normal, not an error
        return AssignedLocationResponse(
          success: true, // Mark as success so we don't treat this as an error
          message: 'No locations assigned',
          assignedDates: [], // Empty list of assignments
        );
      } else {
        // For other error codes
        return AssignedLocationResponse(
          success: false,
          message:
              'Failed to fetch location data (Status: ${response.statusCode})',
          assignedDates: [],
        );
      }
    } catch (e) {
      // For network or parsing errors
      print('Error in fetchLocationAPI: $e');
      return AssignedLocationResponse(
        success: false,
        message: 'Error connecting to server',
        assignedDates: [],
      );
    }
  }

  Future<http.Response> checkInAPI(
      String token, double latitude, double longitude) async {
    final url = Uri.parse('$baseUrl/student/checkIn');
    try {
      print('Check-In Request Details:');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

      // Try to parse as JSON first
      String responseBody = response.body;
      try {
        final decoded = json.decode(responseBody);
        print('Response Body (JSON): $decoded');

        // Check for error message in JSON
        if (response.statusCode >= 400) {
          String errorMessage = decoded['message'] ?? 'Unknown error occurred';
          throw Exception(errorMessage);
        }
      } catch (e) {
        // If not JSON, just print the raw body
        print('Response Body (raw): $responseBody');

        if (response.statusCode == 400) {
          throw Exception('Bad Request: Check input parameters');
        } else if (response.statusCode == 401) {
          throw Exception('Unauthorized: Invalid or expired token');
        } else if (response.statusCode == 500) {
          throw Exception('Server Error: Internal server problem');
        }
      }

      return response;
    } catch (e) {
      print('Detailed Error during check-in: $e');
      rethrow;
    }
  }

  Future<http.Response> checkOutAPI(String token, String headNurseSignature,
      String headNurseName, String latitude, String longitude) async {
    final url = Uri.parse('$baseUrl/student/checkOut');
    try {
      print('Check-Out Request');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "headNurseSignature": headNurseSignature,
          "headNurseName": headNurseName,
          "latitude": latitude,
          "longitude": longitude
        }),
      );
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      // Add 404 error handling
      if (response.statusCode == 404) {
        throw Exception(
            'Not Found: The endpoint /student/checkOut does not exist');
      } else if (response.statusCode == 400) {
        throw Exception('Bad Request: Check input parameters');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else if (response.statusCode == 500) {
        throw Exception('Server Error: Internal server problem');
      }
      return response;
    } catch (e) {
      print('Detailed Error during check-out: $e');
      rethrow;
    }
  }

  Future<http.Response> fetchWorkingHoursAPI(String token) async {
    final url = Uri.parse('$baseUrl/student/getworkingHours');
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
        throw Exception('Failed to fetch working hours: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchWorkingHoursAPI: $e');
      rethrow;
    }
  }

  Future<http.Response> fetchReadyToWorkData(String token) async {
    final url = Uri.parse('$baseUrl/student/getredyToWorkdays');
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
        throw Exception('Failed to fetch Ready-to-Work data: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchReadyToWorkData: $e');
      rethrow;
    }
  }

  Future<http.Response> editReadyToWorkDatesAPI(
      String token, List<String> datesToRemove) async {
    final url = Uri.parse('$baseUrl/student/editDates');

    try {
      final Map<String, dynamic> requestBody = {
        "datesToRemove": datesToRemove,
      };

      print('Request to: $url');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
            'Failed to edit ready-to-work dates. Status: ${response.statusCode}, Response: ${response.body}');
      }
    } catch (e) {
      print('Error in editReadyToWorkDatesAPI: $e');
      rethrow;
    }
  }

  Future<ProposedDatesModel> fetchProposedDatesAPI(String token) async {
  final url = Uri.parse('$baseUrl/student/getRequest');
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
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Assuming proposedDates is directly under the root
      final proposedDatesModel = ProposedDatesModel.fromJson(jsonResponse);
      return proposedDatesModel;
    } else {
      throw Exception('Failed to fetch proposed dates: ${response.body}');
    }
  } catch (e) {
    print('Error in fetchProposedDatesAPI: $e');
    rethrow;
  }
}


  Future<http.Response> sendDateResponsesAPI({
    required String token,
    required List<Map<String, String>> responses,
  }) async {
    final url = Uri.parse('$baseUrl/student/respond');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "responses": responses,
        }),
      );
      return response;
    } catch (e) {
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
}
