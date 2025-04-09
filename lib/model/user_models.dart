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


class LocationResponse {   
  final bool success;   
  final String message;   
  final Location location;    

  LocationResponse({     
    required this.success,     
    required this.message,     
    required this.location,   
  });    

  factory LocationResponse.fromJson(Map<String, dynamic> json) {     
    return LocationResponse(       
      success: json['success'],       
      message: json['message'],       
      location: Location.fromJson(json['location']),     
    );   
  }    

  Map<String, dynamic> toJson() {     
    return {       
      'success': success,       
      'message': message,       
      'location': location.toJson(),     
    };   
  } 
}  

class Location {   
  final String locationId;   
  final String name;   
  final double latitude;   
  final double longitude;    

  Location({     
    required this.locationId,     
    required this.name,     
    required this.latitude,     
    required this.longitude,   
  });    

  factory Location.fromJson(Map<String, dynamic> json) {     
    return Location(       
      locationId: json['locationId'],       
      name: json['name'],       
      latitude: json['latitude'].toDouble(),       
      longitude: json['longitude'].toDouble(),     
    );   
  }    

  Map<String, dynamic> toJson() {     
    return {       
      'locationId': locationId,       
      'name': name,       
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
  final List<DateTime> proposedDates;

  ProposedDatesModel({required this.proposedDates});

  factory ProposedDatesModel.fromJson(Map<String, dynamic> json) {
    return ProposedDatesModel(
      proposedDates: List<String>.from(json['proposedDates'] ?? [])
          .map((date) => DateTime.parse(date))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proposedDates': proposedDates.map((date) => date.toUtc().toIso8601String()).toList(),
    };
  }
}



