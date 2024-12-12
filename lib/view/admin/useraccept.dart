import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:humble/model/employeemodel.dart';
import 'package:humble/model/unadmitted.dart';

class EmployeeListScreen extends StatefulWidget {
  EmployeeListScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late Future<List<Employeemodel>> allEmployees;
  late Future<List<Unadmitted>> unadmittedUsers;

  @override
  void initState() {
    super.initState();
    allEmployees = fetchAllUsers();
    unadmittedUsers = fetchUnadmittedUsers();
  }

  Future<List<Employeemodel>> fetchAllUsers() async {
    final response = await http.get(
      Uri.parse('https://ukproject-dx1c.onrender.com/api/admin/getAllUsers'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['success'] == true) {
        final List<dynamic> users = json['users'];
        return users.map((item) => Employeemodel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch users: ${json['message']}');
      }
    } else {
      throw Exception(
          'Failed to load all users. Status code: ${response.statusCode}');
    }
  }

  Future<List<Unadmitted>> fetchUnadmittedUsers() async {
    final response = await http.get(
      Uri.parse('https://ukproject-dx1c.onrender.com/api/admin/getUnadmittedUsers'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['success'] == true) {
        final List<dynamic> users = json['unadmittedUsers'];
        return users.map((item) => Unadmitted.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch unadmitted users: ${json['message']}');
      }
    } else {
      throw Exception(
          'No New request');
    }
  }

  Future<Map<String, dynamic>> handleUserAction(
      String userId, String action) async {
    final url =
        Uri.parse('https://ukproject-dx1c.onrender.com/api/admin/admitUser');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'action': action}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('No New Employee');
    }
  }

  void _handleRejectAction(String userId) async {
    try {
      final response = await handleUserAction(userId, 'reject');
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User rejected successfully')),
        );
        setState(() {
          unadmittedUsers = fetchUnadmittedUsers();
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to reject user');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void _handleAcceptAction(String userId) async {
    try {
      final response = await handleUserAction(userId, 'accept');
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User accepted successfully')),
        );
        setState(() {
          unadmittedUsers = fetchUnadmittedUsers();
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to accept user');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          title: const Text(
            'Employees',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black87,
            indicatorColor: Colors.blue,
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: 'All Employees'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEmployeeListFuture(allEmployees, isUnadmitted: false),
            _buildEmployeeListFuture(unadmittedUsers, isUnadmitted: true),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeListFuture(Future<List<dynamic>> futureList,
      {required bool isUnadmitted}) {
    return FutureBuilder<List<dynamic>>(
      future: futureList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(isUnadmitted
                ? 'No unadmitted users available.'
                : 'No employees available.'),
          );
        }

        return _buildEmployeeList(snapshot.data!, isUnadmitted: isUnadmitted);
      },
    );
  }

  Widget _buildEmployeeList(List<dynamic> userList,
      {required bool isUnadmitted}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: userList.map((user) {
          if (isUnadmitted) {
            return _buildUnadmittedCard(user as Unadmitted);
          } else {
            return _buildEmployeeCard(user as Employeemodel);
          }
        }).toList(),
      ),
    );
  }

  Widget _buildEmployeeCard(Employeemodel user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: user.imageUrl.isNotEmpty
                    ? NetworkImage(user.imageUrl)
                    : const AssetImage('assets/placeholder.png') as ImageProvider,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${user.firstname} ${user.lastname}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(user.email,
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(user.phoneNumber,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnadmittedCard(Unadmitted user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: user.imageUrl.isNotEmpty
                        ? NetworkImage(user.imageUrl)
                        : const AssetImage('assets/placeholder.png') as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(user.email,
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text(user.phoneNumber,
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleRejectAction(user.id),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleAcceptAction(user.id),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
