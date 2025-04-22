import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:humble/constants/token.dart';
import 'package:humble/model/admin_model.dart';
import 'package:humble/services/admin_services.dart';
import 'package:humble/view/admin/admin_login.dart';
import 'package:humble/view/admin/adminbottom.dart'; // Changed to match your imports

class AdminProvider with ChangeNotifier {
  final AdminApi _apiService = AdminApi();

  String? _token;
  Data? _data;
  List<AllUsers> _users = [];
  bool _isLoading = false;
  List<ReadyToWorkUser> _readyToWorkUsers = [];
  List<Location> _locations = [];
  AssignedDatesResponse? _assignedDatesResponse;
  String? _message;

  String? get token => _token;
  Data? get data => _data;
  List<AllUsers> get users => _users;
  bool get isLoading => _isLoading;
  List<ReadyToWorkUser> get readyToWorkUsers => _readyToWorkUsers;
  List<Location> get locations => _locations;
  AssignedDatesResponse? get assignedDatesResponse => _assignedDatesResponse;
  String? get message => _message;

  Future<void> loginProvider(
    String email,
    String password,
    BuildContext context,
  ) async {
    final response = await _apiService.adminloginAPI(email, password);
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['token'] != null) {
      _token = responseData['token'];
      await saveToken(_token!);
      print('Login Successful');
      print('Response Data: $responseData');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              BottomNavigation(), // Using the class from your original code
        ),
      );
      notifyListeners();
    } else {
      throw Exception(responseData['message'] ?? 'Login failed');
    }
  }

  Future<void> AdminautoLoginProvider(BuildContext context) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        print('Auto-login: No token found');
        throw Exception('No authentication token found');
      }

      print('Auto-login: Token found, attempting to validate');
      _token = token;

      final response = await _apiService.fetchDataAPI(_token!);
      final responseData = jsonDecode(response.body);

      print('Auto-login Token: $_token');
      print('Auto-login API status: ${response.statusCode}');
      print('Auto-login API response: ${response.body}');

      if (response.statusCode == 200) {
        print('Auto-login: Token is valid, navigating to dashboard');

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavigation()),
          );
        }

        notifyListeners();
      } else {
        print('Auto-login: Invalid token or server error');
        throw Exception(
            responseData['message'] ?? 'Session expired. Please log in again.');
      }
    } catch (e) {
      print('Auto-login failed: $e');

      await clearToken();
      _token = null;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session expired. Please log in again.'),
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminLogin()),
        );
      }

      throw e;
    }
  }

  Future<void> logoutProvider(BuildContext context) async {
    try {
      String? token = await getToken();
      if (token != null) {
        final response = await _apiService.userLogoutAPI(token);

        if (response.statusCode == 200) {
          // Clear token from local storage
          await clearToken();

          // Clear authentication state
          _token = null;
          notifyListeners(); // This will trigger the Consumer to rebuild and show login

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      print('Logout Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during logout.')),
      );
    }
  }

  Future<bool> fetchDataProvider() async {
    try {
      if (_token == null) {
        _token = await getToken();
      }

      if (_token != null) {
        final response = await _apiService.fetchDataAPI(_token!);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          if (responseBody['success'] == true) {
            _data = Data.fromJson(responseBody['data']);
            print('Fetched Data: $_data');
            notifyListeners();
            return true;
          } else {
            print(
                'Data fetch failed: ${responseBody['message'] ?? 'Unknown error'}');
            return false;
          }
        } else {
          print('Data fetch failed with status: ${response.statusCode}');
          return false;
        }
      }
      return false;
    } catch (e) {
      print('Error fetching data: $e');
      return false;
    }
  }

  Future<bool> fetchUsersProvider() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_token == null) {
        _token = await getToken();
      }

      if (_token != null) {
        final response = await _apiService.fetchAllUsersAPI(_token!);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          if (responseBody['success'] == true) {
            try {
              _users = (responseBody['users'] as List)
                  .map((user) => AllUsers.fromJson(user))
                  .toList();
              print('Fetched Users: ${_users.length}');
              _isLoading = false;
              notifyListeners();
              return true;
            } catch (parseError) {
              print('Error parsing users: $parseError');
              _isLoading = false;
              notifyListeners();
              return false;
            }
          } else {
            print(
                'User fetch failed: ${responseBody['message'] ?? 'Unknown error'}');
            _isLoading = false;
            notifyListeners();
            return false;
          }
        } else {
          print('User fetch failed with status: ${response.statusCode}');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Error fetching users: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> approveActionProvider(String userId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final response = await _apiService.approveActionAPI(_token!, userId);
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        print('Action approved successfully');
        // Update local state to reflect approval
        await fetchUsersProvider(); // Refresh the user list
      } else {
        print('Failed to approve action: ${response.body}');
        throw Exception('Failed to approve action');
      }
    } catch (e) {
      print('Error approving action: $e');
      rethrow;
    }
  }

  Future<bool> fetchReadyToWorkUsersProvider() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_token == null) {
        _token = await getToken();
      }

      if (_token != null) {
        final response = await _apiService.fetchReadyToWorkUsersAPI(_token!);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          if (responseBody['success'] == true) {
            try {
              _readyToWorkUsers = (responseBody['students'] as List)
                  .map((user) => ReadyToWorkUser.fromJson(user))
                  .toList();
              print('Fetched Ready To Work Users: ${_readyToWorkUsers.length}');
              _isLoading = false;
              notifyListeners();
              return true;
            } catch (parseError) {
              print('Error parsing ready-to-work users: $parseError');
              _isLoading = false;
              notifyListeners();
              return false;
            }
          } else {
            print(
                'Ready-to-work user fetch failed: ${responseBody['message'] ?? 'Unknown error'}');
            _isLoading = false;
            notifyListeners();
            return false;
          }
        } else {
          print(
              'Ready-to-work user fetch failed with status: ${response.statusCode}');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Error fetching ready-to-work users: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchLocationsProvider() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_token == null) {
        _token = await getToken();
      }

      if (_token != null) {
        final response = await _apiService.fetchLocationsAPI(_token!);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          if (responseBody['success'] == true) {
            try {
              _locations = (responseBody['locations'] as List)
                  .map((loc) => Location.fromJson(loc))
                  .toList();
              print('Fetched Locations: ${_locations.length}');
              _isLoading = false;
              notifyListeners();
              return true;
            } catch (parseError) {
              print('Error parsing locations: $parseError');
              _isLoading = false;
              notifyListeners();
              return false;
            }
          } else {
            print(
                'Location fetch failed: ${responseBody['message'] ?? 'Unknown error'}');
            _isLoading = false;
            notifyListeners();
            return false;
          }
        } else {
          print('Location fetch failed with status: ${response.statusCode}');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Error fetching locations: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> createLocationProvider(
      String name, String latitude, String longitude) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final response = await _apiService.createLocationAPI(
          _token!, name, latitude, longitude);

      print('Full API response: ${response.body}');

      final responseBody = json.decode(response.body);

      // Check if status code is 200 OR 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Location created successfully with body: ${response.body}');
        await fetchLocationsProvider();
        return; // Success, exit early
      }

      // If we get here, the status code wasn't successful
      print('Failed to create location: ${response.body}');
      throw Exception(
          'Failed to create location: Server returned ${response.statusCode}');
    } catch (e) {
      print('Error creating location: $e');
      rethrow;
    }
  }

  Future<void> editLocationProvider(
      String locationId, String name, String latitude, String longitude) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final response = await _apiService.editLocationAPI(
          _token!, locationId, name, latitude, longitude);

      print('Full edit response: ${response.body}');

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Location edited successfully with body: ${response.body}');
        await fetchLocationsProvider();
        return;
      }

      print('Failed to edit location: ${response.body}');
      throw Exception(
          'Failed to edit location: Server returned ${response.statusCode}');
    } catch (e) {
      print('Error editing location: $e');
      rethrow;
    }
  }

  Future<void> deleteLocationProvider(String locationId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final response = await _apiService.deleteLocationAPI(_token!, locationId);

      print('Full delete response: ${response.body}');

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Location deleted successfully with body: ${response.body}');
        await fetchLocationsProvider();
        return;
      }

      print('Failed to delete location: ${response.body}');
      throw Exception(
          'Failed to delete location: Server returned ${response.statusCode}');
    } catch (e) {
      print('Error deleting location: $e');
      rethrow;
    }
  }

  Future<void> assignLocationProvider(
      String studentId, String locationId, List<String> assignedDates) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final response = await _apiService.assignLocationAPI(
        _token!,
        studentId,
        locationId,
        assignedDates,
      );

      print('Full API response: ${response.body}');

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Student location marked successfully: ${response.body}');
        // If you need to refresh data after this, do it here (like fetchAttendanceProvider?)
        return;
      }

      print('Failed to mark student location: ${response.body}');
      throw Exception(
          'Failed to mark student location: Server returned ${response.statusCode}');
    } catch (e) {
      print('Error marking student location: $e');
      rethrow;
    }
  }

  Future<void> proposeDatesProvider(
      String userId, List<String> proposedDates) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final response = await _apiService.proposeDatesAPI(
        _token!,
        userId,
        proposedDates,
      );

      print('Full API response: ${response.body}');

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Dates proposed successfully: ${response.body}');
        // If you need to refresh or notify UI after success, do it here.
        return;
      }

      print('Failed to propose dates: ${response.body}');
      throw Exception(
          'Failed to propose dates: Server returned ${response.statusCode}');
    } catch (e) {
      print('Error proposing dates: $e');
      rethrow;
    }
  }

  Future<bool> fetchAssignedDatesProvider(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_token == null) {
        _token = await getToken();
      }

      if (_token != null) {
        final response =
            await _apiService.fetchAssignedDatesAPI(_token!, userId);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          if (responseBody['success'] == true) {
            try {
              _assignedDatesResponse =
                  AssignedDatesResponse.fromJson(responseBody);
              print(
                  'Fetched Assigned Dates: ${_assignedDatesResponse?.assignedDates.length}');
              _isLoading = false;
              notifyListeners();
              return true;
            } catch (parseError) {
              print('Error parsing assigned dates: $parseError');
              _isLoading = false;
              notifyListeners();
              return false;
            }
          } else {
            print(
                'Fetch failed: ${responseBody['message'] ?? 'Unknown error'}');
            _isLoading = false;
            notifyListeners();
            return false;
          }
        } else {
          print('Fetch failed with status: ${response.statusCode}');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Error fetching assigned dates: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> sendForgotPasswordEmailProvider(String email) async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      final response = await _apiService.sendForgotPasswordEmail(email: email);
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        _message = responseBody['message'];
        print('OTP sent successfully');
      } else {
        _message = responseBody['message'] ?? 'Something went wrong';
        print('Failed to send OTP: ${response.body}');
        throw Exception('Failed to send forgot password email');
      }
    } catch (e) {
      _message = 'Error: $e';
      print(_message);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ForgotPasswordProvider({
    required String otp,
    required String password,
  }) async {
    _isLoading = true;
    _message = null;
    notifyListeners();
    try {
      final response = await _apiService.ForgotPasswordAPI(
        otp: otp,
        password: password,
      );

      // First check if we got HTML
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        _message = 'Server error. Please try again later.';
        print('API returned HTML instead of JSON');
        throw Exception('API returned HTML instead of JSON');
      }

      // If it's not HTML, try to parse as JSON
      try {
        final responseBody = json.decode(response.body);
        // Assuming your API returns a success flag and message
        if (response.statusCode == 200) {
          _message = responseBody['message'] ?? 'Password reset successfully';
          print('Password reset successfully: $_message');
        } else {
          _message = responseBody['message'] ?? 'Failed to reset password';
          print('Failed to reset password: $_message');
          throw Exception(_message);
        }
      } catch (parseError) {
        // If JSON parsing fails
        print('Error parsing JSON: $parseError');
        _message = 'Invalid response from server';
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      print('Error in ForgotPasswordProvider: $e');
      if (_message == null) {
        _message = 'Error: $e';
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePasswordProvider({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      final response = await _apiService.changePasswordAPI(
        token: _token!,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        _message = responseBody['message'];
      } else {
        _message = responseBody['message'] ?? 'Something went wrong';
        throw Exception('Failed to change password');
      }
    } catch (e) {
      _message = 'Error: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
