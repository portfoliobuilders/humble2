import 'dart:convert';

class UserProfile {
  final bool success;
  final User user;

  UserProfile({required this.success, required this.user});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      success: json['success'] ?? false,
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'user': user.toJson(),
    };
  }

  @override
  String toString() {
    return 'UserProfile(success: $success, user: $user)';
  }
}

class User {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final bool approved;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.approved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      approved: json['approved'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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

UserProfile parseUserProfile(String responseBody) {
  final Map<String, dynamic> parsed = json.decode(responseBody);
  return UserProfile.fromJson(parsed);
}


class AssignedLocationResponse {
  final bool success;
  final String message;
  final List<AssignedDate> assignedDates;

  AssignedLocationResponse({
    required this.success,
    required this.message,
    required this.assignedDates,
  });

  factory AssignedLocationResponse.fromJson(Map<String, dynamic> json) {
    return AssignedLocationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      assignedDates: (json['assignedDates'] as List<dynamic>)
          .map((item) => AssignedDate.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'assignedDates': assignedDates.map((e) => e.toJson()).toList(),
    };
  }
}

class AssignedDate {
  final String date;
  final String locationName;
  final double latitude;
  final double longitude;

  AssignedDate({
    required this.date,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  factory AssignedDate.fromJson(Map<String, dynamic> json) {
    return AssignedDate(
      date: json['date'] ?? '',
      locationName: json['locationName'] ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    // Convert string to double if necessary
    return value is double ? value : double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}


class WorkingHours {
  final bool success;
  final String message;
  final String totalHoursWorked;
  final List<WorkSession> workSessions;

  WorkingHours({
    required this.success,
    required this.message,
    required this.totalHoursWorked,
    required this.workSessions,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      success: json['success'],
      message: json['message'],
      totalHoursWorked: json['totalHoursWorked'],
      workSessions: (json['workSessions'] as List)
          .map((session) => WorkSession.fromJson(session))
          .toList(),
    );
  }
}

class WorkSession {
  final String checkInTime;
  final String? checkOutTime;
  final String hoursWorked;
  final String locationName;

  WorkSession({
    required this.checkInTime,
    this.checkOutTime,
    required this.hoursWorked,
    required this.locationName,
  });

  factory WorkSession.fromJson(Map<String, dynamic> json) {
    return WorkSession(
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      hoursWorked: json['hoursWorked'],
      locationName: json['locationName'],
    );
  }
}


class ReadyToWorkResponse {
  final bool success;
  final String message;
  final List<String> readyToWorkDates;

  ReadyToWorkResponse({
    required this.success,
    required this.message,
    required this.readyToWorkDates,
  });

  factory ReadyToWorkResponse.fromJson(Map<String, dynamic> json) {
    return ReadyToWorkResponse(
      success: json['success'],
      message: json['message'],
      readyToWorkDates: json['user'] != null && json['user']['readyToWorkDates'] != null
          ? List<String>.from(json['user']['readyToWorkDates'])
          : [],
    );
  }
}

class ProposedDatesModel {
  final List<ProposedDateItem> proposedDates;

  ProposedDatesModel({required this.proposedDates});

  factory ProposedDatesModel.fromJson(Map<String, dynamic> json) {
    return ProposedDatesModel(
      proposedDates: (json['proposedDates'] as List<dynamic>? ?? [])
          .map((item) => ProposedDateItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proposedDates': proposedDates.map((item) => item.toJson()).toList(),
    };
  }
}

class ProposedDateItem {
  final DateTime date;
  final Location location;

  ProposedDateItem({required this.date, required this.location});

  factory ProposedDateItem.fromJson(Map<String, dynamic> json) {
    return ProposedDateItem(
      date: DateTime.parse(json['date']),
      location: Location.fromJson(json['location']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toUtc().toIso8601String(),
      'location': location.toJson(),
    };
  }
}

class Location {
  final String id;
  final String locationName;

  Location({required this.id, required this.locationName});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['_id'],
      locationName: json['locationname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'locationname': locationName,
    };
  }
}




