import 'package:flutter/material.dart';
import 'package:humble/constants/token.dart';
import 'package:humble/model/user_models.dart';
import 'package:humble/services/user_services.dart';
import 'package:humble/view/user/bottom.dart';
import 'dart:convert';

import 'package:humble/view/user/user_login.dart';
import 'package:intl/intl.dart';

class UserProvider with ChangeNotifier {
  final UserApi _apiService = UserApi();

  String? _token;
  UserProfile? _userProfile;
  bool _isAvailable = false;
  Location? _location;
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  double? _distance;
  Location? _assignedLocation;
  String? _headNurseSignature;
  String? _totalHoursWorked;
  WorkingHours? _workingHours;
  bool _isLoading = false;
  List<String> _readyToWorkDates = [];
  ReadyToWorkResponse? _readyToWorkData;
  List<DateTime> _proposedDates = [];

  UserProfile? get userProfile => _userProfile;
  String? get token => _token;
  bool get isAvailable => _isAvailable;
  Location? get location => _location;
  bool get isCheckedIn => _isCheckedIn;
  DateTime? get checkInTime => _checkInTime;
  double? get distance => _distance;
  Location? get assignedLocation => _assignedLocation;
  String? get headNurseSignature => _headNurseSignature;
  String? get totalHoursWorked => _totalHoursWorked;
  WorkingHours? get workingHours => _workingHours;
  bool get isLoading => _isLoading;
  List<String> get readyToWorkDates => _readyToWorkDates;
  ReadyToWorkResponse? get readyToWorkData => _readyToWorkData;
  List<DateTime> get proposedDates => _proposedDates;

  String formatDateTime(DateTime dateTime) {
    // Convert to local timezone before formatting
    final localDateTime = dateTime.toLocal();
    return DateFormat('hh:mm a').format(localDateTime);
  }

  Future<bool> registerProvider({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      // Call the existing userregisterAPI method
      final response = await _apiService.userregisterAPI(
        email,
        password,
        name,
        phoneNumber,
      );

      // Parse the response body
      final responseBody = json.decode(response.body);

      // Check if registration was successful based on the response
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          (responseBody['success'] == true &&
              responseBody.containsKey('user'))) {
        print('Registration successful: ${responseBody['message']}');
        notifyListeners();
        return true;
      } else {
        print(
            'Registration failed: ${responseBody['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      // If the response indicates success but an exception is thrown
      if (e.toString().contains('User registered successfully')) {
        print('Registration successful despite exception');
        notifyListeners();
        return true;
      }

      print('Error during registration: $e');
      return false;
    }
  }

  Future<bool> registerWithGoogleProvider(String googleToken) async {
    try {
      print('Sending Google token to API');
      final response = await _apiService.registerWithGoogle(googleToken);
      print('API response status code: ${response.statusCode}');
      print('API response body: ${response.body}');

      final responseBody = json.decode(response.body);

      // More flexible response handling
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Google registration successful based on status code');
        notifyListeners();
        return true;
      } else if (responseBody['success'] == true) {
        print('Google registration successful based on success flag');
        notifyListeners();
        return true;
      } else {
        final errorMsg = responseBody['message'] ?? 'Unknown error';
        print('Google registration failed: $errorMsg');
        return false;
      }
    } catch (e) {
      // Check for partial success string in error
      final errorStr = e.toString();
      print('Exception during Google registration: $errorStr');

      if (errorStr.contains('User registered successfully')) {
        print(
            'Google registration interpreted as successful despite exception');
        notifyListeners();
        return true;
      }
      return false;
    }
  }

  Future<void> loginProvider(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final response = await _apiService.userloginAPI(email, password);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print('Login Successful');
        print('Response Data: $responseData');

        _token = responseData['token'];

        print('Token to be saved: $_token');

        await saveToken(_token!);

        _isCheckedIn = responseData['checkInStatus'] ?? false;

        try {
          await fetchUserProfileProvider();
          // Fetch location after successful login
          await fetchLocationProvider();
        } catch (locationError) {
          print('Error fetching profile or location: $locationError');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Could not fetch profile or location: $locationError'),
              backgroundColor: Colors.orange,
            ),
          );
        }

        // Navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavigationScreen(),
            settings: RouteSettings(name: '/home'),
          ),
        );

        notifyListeners();
      } else {
        final errorData = jsonDecode(response.body);

        print('Error Details: $errorData');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorData['message'] ?? 'Login failed. Please try again.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Login error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please check your details.'),
        ),
      );
    }
  }

  Future<void> autoLoginProvider(BuildContext context) async {
    try {
      String? token = await getToken();

      if (token != null && token.isNotEmpty) {
        print('Auto-login: Token found, attempting to validate');

        _token = token;

        bool profileSuccess = false;

        try {
          final response = await _apiService.fetchUserProfileAPI(token);

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);

            print('Auto-login: Profile fetched successfully');
            profileSuccess = true;

            // Try to fetch location data (but don't fail login if this fails)
            try {
              await fetchLocationProvider();
            } catch (locationError) {
              print('Warning: Error fetching location: $locationError');
              // Continue with login even if location fetch fails
            }
          } else {
            print(
                'Auto-login: Profile fetch failed with status: ${response.statusCode}');
            throw Exception('Invalid token or server error');
          }
        } catch (profileError) {
          print('Auto-login: Error fetching profile: $profileError');
          throw Exception('Failed to validate token');
        }

        if (profileSuccess && context.mounted) {
          // Navigate to home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavigationScreen()),
          );

          notifyListeners();
          return;
        }
      } else {
        print('Auto-login: No token found');
        throw Exception('No authentication token found');
      }
    } catch (e) {
      print('Auto-login failed: $e');

      // Clear token on error
      await clearToken();
      _token = null;

      // Only try to navigate if context is still valid
      if (context.mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session expired. Please log in again.'),
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      }

      // Rethrow to let splash screen know login failed
      throw e;
    }
  }

  Future<void> logoutProvider(BuildContext context) async {
    try {
      String? token = await getToken();
      if (token != null) {
        final response = await _apiService.userLogoutAPI(token);
        print('Logout Status Code: ${response.statusCode}');
        print('Logout Response Body: ${response.body}');
        if (response.statusCode == 200) {
          print('Logout successful');
          // Clear token from local storage
          await clearToken();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully.')),
          );
          // Navigate to Login Screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SignInPage()),
            (route) => false,
          );
          notifyListeners();
        } else {
          print('Logout failed: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Logout failed. Please try again.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Logout Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred during logout.'),
        ),
      );
    }
  }

  Future<bool> fetchUserProfileProvider() async {
    try {
      if (_token == null) {
        _token = await getToken();
      }

      if (_token != null) {
        final response = await _apiService.fetchUserProfileAPI(_token!);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          if (responseBody['success'] == true) {
            _userProfile = UserProfile.fromJson(responseBody);
            print('Fetched User Profile: $_userProfile');
            notifyListeners();
            return true;
          } else {
            print(
                'Profile fetch failed: ${responseBody['message'] ?? 'Unknown error'}');
            return false;
          }
        } else {
          print('Profile fetch failed with status: ${response.statusCode}');
          return false;
        }
      }
      return false;
    } catch (e) {
      print('Error fetching user profile: $e');
      return false;
    }
  }

  Future<void> fetchLocationProvider() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final response = await _apiService.fetchLocationAPI(_token!);
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody['success'] == true) {
        _location = Location.fromJson(responseBody['location']);
        print('Fetched Location: $_location');
        notifyListeners();
      } else {
        throw Exception('Failed to fetch location');
      }
    } catch (e) {
      print('Error fetching location: $e');
      rethrow;
    }
  }

  Future<void> checkInProvider(double latitude, double longitude) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final response =
          await _apiService.checkInAPI(_token!, latitude, longitude);
      final responseBody = json.decode(response.body);

      if (responseBody['success'] == true) {
        // Store check-in time in local timezone
        _checkInTime = DateTime.now();
        _isCheckedIn = true;
        _distance = responseBody['distance']?.toDouble() ?? 0.0;

        print(
            'Check-in successful at ${formatDateTime(_checkInTime!)}, Distance: $_distance');
        notifyListeners();
      } else {
        print('Failed to check-in: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Check-in failed');
      }
    } catch (e) {
      print('Error during check-in: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkOutProvider(
      String headNurseSignature, String headNurseName) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final response = await _apiService.checkOutAPI(
          _token!, headNurseSignature, headNurseName);
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == true) {
        final checkOutTime = DateTime.now();
        // Add check-out activity to history

        // Set check-in status to false (checked out)
        _isCheckedIn = false;
        _checkInTime = null;
        _distance = null;
        _headNurseSignature = responseBody['headNurseSignature'];
        _totalHoursWorked = responseBody['totalHoursWorked'];
        headNurseName = responseBody['headNurseName']; // Store head nurse name

        print('Check-out successful');
        print('Total Hours Worked: $_totalHoursWorked');
        print('Head Nurse Signature: $_headNurseSignature');
        print('Head Nurse Name: $headNurseName');

        notifyListeners();
        return {
          'success': true,
          'totalHoursWorked': _totalHoursWorked,
          'headNurseSignature': _headNurseSignature,
          'headNurseName': headNurseName
        };
      } else {
        print('Failed to check-out: ${response.body}');
        throw Exception(responseBody['message'] ?? 'Check-out failed');
      }
    } catch (e) {
      print('Error during check-out: $e');
      rethrow;
    }
  }

  Future<void> fetchWorkingHoursProvider() async {
    if (_token == null) throw Exception('Token is missing');

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.fetchWorkingHoursAPI(_token!);
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody['success'] == true) {
        _workingHours = WorkingHours.fromJson(responseBody);
        print('Fetched Working Hours: ${_workingHours!.totalHoursWorked}');
      } else {
        throw Exception(
            'Failed to fetch working hours: ${responseBody['message']}');
      }
    } catch (e) {
      print('Error fetching working hours: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<WorkSession> getSessionsByMonth(int year, int month) {
    if (_workingHours == null) return [];

    var filteredSessions = _workingHours!.workSessions.where((session) {
      try {
        final DateTime sessionDate = DateTime.parse(session.checkInTime);
        // Only include sessions that have checkout data
        return sessionDate.year == year &&
            sessionDate.month == month &&
            session.checkOutTime != null &&
            session.checkOutTime!.isNotEmpty;
      } catch (e) {
        return false;
      }
    }).toList();

    // Sort the sessions by date in descending order (newest first)
    filteredSessions.sort((a, b) {
      try {
        final DateTime dateA = DateTime.parse(a.checkInTime);
        final DateTime dateB = DateTime.parse(b.checkInTime);
        return dateB.compareTo(dateA); // Reverse order (newest first)
      } catch (e) {
        return 0;
      }
    });

    return filteredSessions;
  }

  Future<void> readyToWorkProvider(List<String> readyToWorkDates) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final response =
          await _apiService.readyToWorkAPI(_token!, readyToWorkDates);
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == true) {
        _readyToWorkDates = List<String>.from(
            responseBody['user']['readyToWorkDates'] ?? readyToWorkDates);

        print('Ready to Work dates updated successfully: $_readyToWorkDates');
        notifyListeners();
      } else {
        print('Failed to update Ready to Work dates: ${response.body}');
        throw Exception('Failed to update Ready to Work dates');
      }
    } catch (e) {
      print('Error updating Ready to Work dates: $e');
      rethrow;
    }
  }

  Future<void> fetchReadyToWorkData() async {
    if (_token == null) throw Exception('Token is missing');

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.fetchReadyToWorkData(_token!);
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody['success'] == true) {
        final readyToWorkResponse = ReadyToWorkResponse.fromJson(responseBody);
        _readyToWorkDates = readyToWorkResponse.readyToWorkDates;
        print('Fetched Ready-to-Work Dates: $_readyToWorkDates');
      } else {
        throw Exception(
            'Failed to fetch Ready-to-Work data: ${responseBody['message']}');
      }
    } catch (e) {
      print('Error fetching Ready-to-Work data: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editReadyToWorkDates(List<String> datesToRemove) async {
    if (_token == null) {
      throw Exception('Token is missing');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _apiService.editReadyToWorkDatesAPI(_token!, datesToRemove);
      final Map<String, dynamic> responseBody = json.decode(response.body);

      print('API Response: $responseBody');

      if (response.statusCode == 200 &&
          responseBody.containsKey('success') &&
          responseBody['success'] == true) {
        // Remove the selected dates from the local list
        _readyToWorkDates.removeWhere((date) => datesToRemove.contains(date));

        print('Updated Ready-to-Work Dates: $_readyToWorkDates');
      } else {
        throw Exception(
            'Failed to edit Ready-to-Work dates. API Response: $responseBody');
      }
    } catch (e) {
      print('Error in editReadyToWorkDates: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProposedDatesProvider() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.fetchProposedDatesAPI(token!);
      final jsonData = jsonDecode(response.body);
      final model = ProposedDatesModel.fromJson(jsonData);
      _proposedDates = model.proposedDates;
      print('Fetched Proposed Dates: $_proposedDates');
    } catch (e) {
      print('Error fetching proposed dates: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> respondToRequestProvider() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final response = await _apiService.postAcceptAPI(_token!, 'respond');
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        // Optionally update any local state if needed
        print('Response accepted successfully');
        notifyListeners();
      } else {
        print('Failed to respond: ${response.body}');
        throw Exception('Failed to respond to the request');
      }
    } catch (e) {
      print('Error responding to the request: $e');
      rethrow;
    }
  }
}
