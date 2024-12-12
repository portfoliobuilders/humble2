import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Define the WorkingDaysScreen class
class WorkingDaysScreen extends StatefulWidget {
  @override
  _WorkingDaysScreenState createState() => _WorkingDaysScreenState();
}

class _WorkingDaysScreenState extends State<WorkingDaysScreen> {
  bool isLoading = true;
  String? message;
  int? totalWorkingDays;
  int? totalWorkingTime;
  List<WorkingDayDetails>? workingDaysDetails;

  @override
  void initState() {
    super.initState();
    fetchWorkingDays();
  }

  // Fetch working days from the API
  Future<void> fetchWorkingDays() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    final url = Uri.parse(
        'https://ukproject-dx1c.onrender.com/api/user/$userId/getTotalWorkingDaysWithDetails');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            message = data['message'];
            totalWorkingDays = data['totalWorkingDays'];
            workingDaysDetails = (data['workingDaysDetails'] as List)
                .map((e) => WorkingDayDetails.fromJson(e))
                .toList();
            totalWorkingTime = data['totalWorkingTime'];  // Added this line for total working time
          });
        } else {
          setState(() {
            message = 'Error: ${data['message']}';
          });
        }
      } else {
        setState(() {
          message = 'Failed to fetch data. Status Code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : workingDaysDetails == null || workingDaysDetails!.isEmpty
              ? Center(child: Text(message ?? 'No data available'))
              : ListView.builder(
                  itemCount: workingDaysDetails!.length + 1, // Add one for the total days at the top
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // The first item is for total working days
                      return _buildTotalDays();
                    } else {
                      // The rest are for individual working day cards
                      return _buildWorkingDayCard(workingDaysDetails![index - 1]);
                    }
                  },
                ),
    );
  }

  // The updated _buildTotalDays method
  Widget _buildTotalDays() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: const EdgeInsets.all(6.0),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Total Working Days:  $totalWorkingDays',
            //\nTotal Working Hours: $totalWorkingTime',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build the working day card widget
  Widget _buildWorkingDayCard(WorkingDayDetails detail) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Card(
        margin: const EdgeInsets.all(6.0),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
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
                      ' ${detail.totalWorkingTime}',
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
                              Text('Time: ${activity.workingTime}',style:const TextStyle(fontSize: 12)),
                              Colors.blue,
                            ),
                            const Spacer(),
                            _buildIconWithText(
                              Icons.location_on_outlined,
                              Text('Location: ${activity.location}',style:TextStyle(fontSize: 12) ,),
                              Colors.red,
                            ),
                             const Spacer(),
                            // _buildIconWithText(
                            //   Icons.location_on_outlined,
                            //   Text('Location: ${activity.location}',style:TextStyle(fontSize: 12) ,),
                            //   Colors.red,
                            // ),
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
      ),
    );
  }

  // Helper function for creating rows with icons and text
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

// WorkingDayDetails to represent individual working day data
class WorkingDayDetails {
  String date;
  String totalWorkingTime;
  List<Activity> activities;

  WorkingDayDetails({
    required this.date,
    required this.totalWorkingTime,
    required this.activities,
  });

  factory WorkingDayDetails.fromJson(Map<String, dynamic> json) {
    return WorkingDayDetails(
      date: json['date'],
      totalWorkingTime: json['totalWorkingTime'],
      activities: (json['activities'] as List)
          .map((e) => Activity.fromJson(e))
          .toList(),
    );
  }
}

// Activity to represent activity data within a working day
class Activity {
  String startTime;
  String endTime;
  String location;
  String workingTime;

  Activity({
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.workingTime,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      startTime: json['startTime'],
      endTime: json['endTime'],
      location: json['location'],
      workingTime: json['workingTime'],
    );
  }
}
