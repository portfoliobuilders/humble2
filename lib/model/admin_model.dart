import 'dart:convert';

class Data {
  final int locationCount;
  final int employeeCount;
  final int readyToWorkCount;
  final int adminCount;

  Data({
    required this.locationCount,
    required this.employeeCount,
    required this.readyToWorkCount,
    required this.adminCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      locationCount: json['locationCount'],
      employeeCount: json['employeeCount'],
      readyToWorkCount: json['readyToWorkCount'],
      adminCount: json['adminCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationCount': locationCount,
      'employeeCount': employeeCount,
      'readyToWorkCount': readyToWorkCount,
      'adminCount': adminCount,
    };
  }
}

class AllUsers {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final bool approved;
  final DateTime createdAt;
  final DateTime updatedAt;

  AllUsers({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.approved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AllUsers.fromJson(Map<String, dynamic> json) {
    return AllUsers(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      approved: json['approved'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'approved': approved,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AllUsersResponse {
  final List<AllUsers> users;

  AllUsersResponse({required this.users});

  factory AllUsersResponse.fromJson(String str) {
    final jsonData = json.decode(str);
    return AllUsersResponse(
      users: List<AllUsers>.from(
          jsonData['users'].map((x) => AllUsers.fromJson(x))),
    );
  }

  String toJson() {
    return json.encode({
      'users': users.map((user) => user.toJson()).toList(),
    });
  }
}

class ReadyToWorkUser {
  final String studentId;
  final String name;
  final String email;
  final String phoneNumber;
  final bool readyToWork;
  final List<DateTime> readyToWorkDates;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReadyToWorkUser({
    required this.studentId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.readyToWork,
    required this.readyToWorkDates,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReadyToWorkUser.fromJson(Map<String, dynamic> json) {
    return ReadyToWorkUser(
      studentId: json['studentId'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      readyToWork: json['readyToWork'],
      readyToWorkDates: List<String>.from(json['readyToWorkDates'])
          .map((date) => DateTime.parse(date))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'readyToWork': readyToWork,
      'readyToWorkDates':
          readyToWorkDates.map((date) => date.toIso8601String()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Location {
  final String locationId;
  final String name;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Location({
    required this.locationId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      locationId: json['locationId'],
      name: json['name'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationId': locationId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
class AssignedDatesResponse {
  final bool success;
  final String message;
  final String userId;
  final String userName;
  final String assignedLocation;
  final List<String> assignedDates;

  AssignedDatesResponse({
    required this.success,
    required this.message,
    required this.userId,
    required this.userName,
    required this.assignedLocation,
    required this.assignedDates,
  });

  factory AssignedDatesResponse.fromJson(Map<String, dynamic> json) {
    return AssignedDatesResponse(
      success: json['success'],
      message: json['message'],
      userId: json['userId'],
      userName: json['userName'],
      assignedLocation: json['assignedLocation'],
      assignedDates: List<String>.from(json['assignedDates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'userId': userId,
      'userName': userName,
      'assignedLocation': assignedLocation,
      'assignedDates': assignedDates,
    };
  }
}
