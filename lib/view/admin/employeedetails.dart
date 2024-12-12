import 'package:flutter/material.dart';
import 'package:humble/services/employeeapi.dart';
import 'package:humble/model/employeemodel.dart';
import 'package:humble/view/admin/login.dart';
import 'package:humble/view/user/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
Future<void>  _adminlogout() async {
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    try {
      // Extract data from _currentLocationMessage
    

      // API URL
      final url =
          Uri.parse('https://ukproject-dx1c.onrender.com/api/admin/logout');
      print(userId);
      
      // Construct request body
      final body = json.encode({
        "userId": userId,
        
      });

      // Make the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Response: ${json.decode(response.body)}');
      } else {
        print('Error: ${response.body}');
        throw Exception('Succesfully Logout');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
  late Future<List<Employeemodel>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _employeesFuture = fetchEmployeesmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 30, 30, 30),
                    ),
                  ),
                ),
              ]
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard(
                        'No of Employees', '23', Icons.people, context),
                    _buildStatCard(
                        'Available Staff', '9 Staff', Icons.group, context),
                    _buildStatCard(
                        'Paycheck', '\$120', Icons.attach_money, context),
                    _buildStatCard(
                        'No of Sites', '54', Icons.location_on, context),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Available Employees',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Employeemodel>>(
                future: _employeesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No employees available.'));
                  } else {
                    final employees = snapshot.data!;
                    return ListView.separated(
                      itemCount: employees.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        return _buildEmployeeListItem(employee);
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                              _adminlogout();
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminLogin()),
                            );
                            },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'LogOut',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 82, 87, 91),
            const Color.fromARGB(255, 78, 73, 73),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 25, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeListItem(Employeemodel employee) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color.fromARGB(255, 67, 68, 69).withOpacity(0.2),
        child: const Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0)),
      ),
      title: Text(
        '${employee.firstname} ${employee.lastname}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Color.fromARGB(255, 0, 0, 0)),
        onPressed: () {
          // Edit employee logic
        },
      ),
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
