import 'package:flutter/material.dart';
import 'package:humble/model/admin_model.dart';
import 'package:humble/provider/admin_providers.dart';
import 'package:humble/view/admin/available_employee_calender.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AvailableEmployees extends StatefulWidget {
  final String locationId;

  const AvailableEmployees({Key? key, required this.locationId})
      : super(key: key);

  @override
  State<AvailableEmployees> createState() => _AvailableEmployeesState();
}

class _AvailableEmployeesState extends State<AvailableEmployees> {
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Map<String, List<DateTime>> _assignedDatesMap =
      {}; // User ID -> List of assigned dates

  @override
  void initState() {
    super.initState();
    // Fetch data when screen initializes
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Access the data provider and fetch only the ready-to-work users data
      final dataProvider = Provider.of<AdminProvider>(context, listen: false);
      await dataProvider.fetchReadyToWorkUsersProvider();

      // Initialize the assigned dates map if it's empty
      await _fetchAssignedDates();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Initialize the assigned dates map
  Future<void> _fetchAssignedDates() async {
    // Since we don't have a specific API endpoint to get all assigned dates,
    // we'll initialize an empty map and rely on the assignment responses
    // to populate it over time
    setState(() {
      // Initialize with empty map if not already initialized
      _assignedDatesMap = _assignedDatesMap.isNotEmpty
          ? _assignedDatesMap
          : <String, List<DateTime>>{};
    });
  }

  void _showAvailabilityPage(BuildContext context, ReadyToWorkUser user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmployeeAvailabilityPage(
          user: user,
          locationId: widget.locationId,
          assignedDates: _assignedDatesMap[user.studentId] ?? [],
          onAssignmentComplete: (List<DateTime> newlyAssignedDates) {
            // Update the assigned dates map when we return from the availability page
            setState(() {
              if (_assignedDatesMap.containsKey(user.studentId)) {
                List<DateTime> existingDates =
                    _assignedDatesMap[user.studentId] ?? [];

                // Add any new dates that aren't already in the list
                for (DateTime date in newlyAssignedDates) {
                  if (!existingDates.any((existing) =>
                      existing.year == date.year &&
                      existing.month == date.month &&
                      existing.day == date.day)) {
                    existingDates.add(date);
                  }
                }

                _assignedDatesMap[user.studentId] = existingDates;
              } else {
                // First time assignment for this user
                _assignedDatesMap[user.studentId] = newlyAssignedDates;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Available Employees',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF79C9FF)),
                ),
              )
            : Consumer<AdminProvider>(
                builder: (context, dataProvider, child) {
                  final readyToWorkUsers = dataProvider.readyToWorkUsers;

                  return RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _loadData,
                    color: const Color(0xFF79C9FF),
                    backgroundColor: Colors.white,
                    child: readyToWorkUsers.isEmpty
                        ? ListView(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_off,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'No available employees',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pull down to refresh',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: readyToWorkUsers.length,
                            itemBuilder: (context, index) {
                              final user = readyToWorkUsers[index];
                              // Check if user has assigned dates
                              final hasAssignedDates = _assignedDatesMap
                                      .containsKey(user.studentId) &&
                                  (_assignedDatesMap[user.studentId]
                                          ?.isNotEmpty ??
                                      false);

                              return _EmployeeListItem(
                                user: user,
                                hasAssignedDates: hasAssignedDates,
                                onTap: () =>
                                    _showAvailabilityPage(context, user),
                              );
                            },
                          ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmployeeListItem extends StatelessWidget {
  final ReadyToWorkUser user;
  final bool hasAssignedDates;
  final VoidCallback onTap;

  const _EmployeeListItem({
    Key? key,
    required this.user,
    this.hasAssignedDates = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasAssignedDates
                ? const Color(0xFF79C9FF)
                : Colors.grey.shade200,
            width: hasAssignedDates ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF79C9FF),
                child: Text(
                  user.name.isNotEmpty
                      ? user.name.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      user.phoneNumber,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasAssignedDates)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF79C9FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Assigned',
                    style: TextStyle(
                      color: Color(0xFF79C9FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CD964).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const CircleAvatar(
                  radius: 6,
                  backgroundColor: Color(0xFF4CD964),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.work_outline,
                color: Color(0xFF79C9FF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}