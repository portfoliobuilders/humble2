import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmployeeattendanceListScreen extends StatefulWidget {
  @override
  _EmployeeattendanceListScreenState createState() =>
      _EmployeeattendanceListScreenState();
}

class _EmployeeattendanceListScreenState
    extends State<EmployeeattendanceListScreen> {
  Future<List<Employeeattendancemodel>> fetchAllUsersattendance() async {
    final response = await http.get(
    Uri.parse('https://ukproject-dx1c.onrender.com/api/admin/getAllUsersWorkingDaysWithDetails'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);

    // Debugging: Print the API response to verify the structure
    print('Response JSON: $json');

    if (json['success'] == true) {
      final List<dynamic> users = json['data'];
      
      // Map JSON array to a list of Employeemodel objects
      return users.map((item) => Employeeattendancemodel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch users: ${json['message']}');
    }
  } else {
    throw Exception('Failed to load employees. Status code: ${response.statusCode}');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: FutureBuilder<List<Employeeattendancemodel>>(
        future: fetchAllUsersattendance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No employees found'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return _buildEmployeeCard(users[index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildEmployeeCard(Employeeattendancemodel user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeAttendanceDetailsScreen(user: user),
          ),
        );
      },
    child: Container(
      constraints: BoxConstraints(
        maxHeight: 80, // You can adjust this to suit your design.
        minHeight: 80, // Ensure a minimum height.
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        elevation: 3,
        child: ListTile(
          leading: CircleAvatar(
            child: Text(user.firstname.isNotEmpty ? user.firstname[0] :''),
            radius: 24, // You can adjust the size of the avatar
          ),
          title: Text('${user.firstname} ${user.lastname},',style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text('Total Working days : ${user.totalWorkingDays}',style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ),
    )
    );
  }
}

class Employeeattendancemodel {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final int totalWorkingDays;
  final List<WorkingDayDetail> workingDaysDetails;

  Employeeattendancemodel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.totalWorkingDays,
    required this.workingDaysDetails,
  });

  factory Employeeattendancemodel.fromJson(Map<String, dynamic> json) {
    return Employeeattendancemodel(
      id: json['userDetails']['id'],
      firstname: json['userDetails']['firstname'],
      lastname: json['userDetails']['lastname'],
      email: json['userDetails']['email'],
      totalWorkingDays: json['totalWorkingDays'],
      workingDaysDetails: (json['workingDaysDetails'] as List)
          .map((e) => WorkingDayDetail.fromJson(e))
          .toList(),
    );
  }
}

class WorkingDayDetail {
  final String date;
  final String workingTimeFormatted;
  final List<Activity> activities;

  WorkingDayDetail({
    required this.date,
    required this.workingTimeFormatted,
    required this.activities,
  });

  factory WorkingDayDetail.fromJson(Map<String, dynamic> json) {
    return WorkingDayDetail(
      date: json['date'],
      workingTimeFormatted: json['workingTimeFormatted'],
      activities: (json['activities'] as List)
          .map((e) => Activity.fromJson(e))
          .toList(),
    );
  }
}

class Activity {
  final String time;
  final String location;

  Activity({required this.time, required this.location});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      time: json['time'],
      location: json['location'],
    );
  }
}
class EmployeeAttendanceDetailsScreen extends StatelessWidget {
  final Employeeattendancemodel user;

  const EmployeeAttendanceDetailsScreen({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(5,50,5,5),
        child: Column(
          children: [
            // Month navigation row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.blue, size: 28),
                  onPressed: () {},
                ),
                const Text(
                  'December 2023',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.blue, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
            // Attendance list
            Expanded(
              child: ListView.builder(
                itemCount: user.workingDaysDetails.length,
                itemBuilder: (context, index) {
                  final detail = user.workingDaysDetails[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Hours Indicator
                          Container(
                            width: 60,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E5BFF),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ' ${detail.workingTimeFormatted}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Hours',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Time and Location Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date
                                  Text(
                                    'Date: ${detail.date}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Time and Location Activities
                                  ...detail.activities.map((activity) {
                                    return Row(
                                      children: [
                                        _buildIconWithText(
                                          Icons.login_outlined,
                                          Text('Time: ${activity.time}'),
                                          Colors.blue,
                                        ),
                                        const Spacer(),
                                        _buildIconWithText(
                                          Icons.logout_outlined,
                                          Text('Location: ${activity.location}'),
                                          Colors.red,
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Icon with text helper function
  Widget _buildIconWithText(IconData icon, Text text, Color iconColor) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        text,
      ],
    );
  }
}
