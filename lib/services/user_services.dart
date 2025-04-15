import 'dart:convert';

import 'package:http/http.dart' as http;

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

  Future<http.Response> fetchLocationAPI(String token) async {
    final url = Uri.parse('$baseUrl/student/getLocation');
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
        throw Exception('Failed to fetch location: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchLocationAPI: $e');
      rethrow;
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
      print('Response Body: ${response.body}');

      if (response.statusCode == 400) {
        throw Exception('Bad Request: Check input parameters');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else if (response.statusCode == 500) {
        throw Exception('Server Error: Internal server problem');
      }

      return response;
    } catch (e) {
      print('Detailed Error during check-in: $e');
      rethrow;
    }
  }

  Future<http.Response> checkOutAPI(
      String token, String headNurseSignature, String headNurseName, String latitude, String longitude) async {
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
          "latitude":latitude,
          "longitude":longitude
        }),
      );
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 400) {
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

  Future<http.Response> fetchProposedDatesAPI(String token) async {
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
        return response;
      } else {
        throw Exception('Failed to fetch proposed dates: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchProposedDatesAPI: $e');
      rethrow;
    }
  }

  Future<http.Response> postAcceptAPI(String token, String endpoint) async {
    final url = Uri.parse('$baseUrl/student/respond');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "accept": "true",
        }),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
