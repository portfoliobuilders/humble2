import 'package:flutter/material.dart';
import 'package:humble/model/admin_model.dart';
import 'package:humble/provider/admin_providers.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AvailableEmployees extends StatefulWidget {
  final String locationId;

  const AvailableEmployees({Key? key, required this.locationId}) : super(key: key);

  @override
  State<AvailableEmployees> createState() => _AvailableEmployeesState();
}

class _AvailableEmployeesState extends State<AvailableEmployees> {
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Set<DateTime> _selectedDates = {};
  ReadyToWorkUser? _selectedUser;
  Map<String, List<DateTime>> _assignedDatesMap = {}; // User ID -> List of assigned dates

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

  void _showAvailabilityDialog(BuildContext context, ReadyToWorkUser user) {
    _selectedUser = user;
    _selectedDates = {};
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildAvailabilityDialog(context, user),
        );
      },
    );
  }

  Widget _buildAvailabilityDialog(BuildContext context, ReadyToWorkUser user) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Get assigned dates for this user
    List<DateTime> assignedDates = _assignedDatesMap[user.studentId] ?? [];

    // Group dates by month for easier display
    Map<String, List<DateTime>> groupedDates = {};

    for (var date in user.readyToWorkDates) {
      final monthYear = DateFormat('MMMM yyyy').format(date);
      if (!groupedDates.containsKey(monthYear)) {
        groupedDates[monthYear] = [];
      }
      groupedDates[monthYear]!.add(date);
    }

    // Create a list of month-year pairs for showing 6 months before and 6 months after
    List<String> allMonthYears = [];
    for (int i = -6; i <= 6; i++) {
      DateTime date = DateTime(currentYear, currentMonth + i, 1);
      allMonthYears.add(DateFormat('MMMM yyyy').format(date));
    }

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF79C9FF),
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Select Dates to Assign',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              user.readyToWorkDates.isEmpty && assignedDates.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No available dates specified',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Expanded(
                      child: PageView.builder(
                        itemCount: allMonthYears.length,
                        controller: PageController(initialPage: 6), // Start at current month
                        itemBuilder: (context, index) {
                          final monthYear = allMonthYears[index];
                          final availableDates = groupedDates[monthYear] ?? [];
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                                    onPressed: index > 0 ? () {} : null, // Visual only
                                    color: const Color(0xFF79C9FF),
                                  ),
                                  Text(
                                    monthYear,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF79C9FF),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onPressed: index < allMonthYears.length - 1 ? () {} : null,
                                    color: const Color(0xFF79C9FF),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: _buildSelectableCalendarForMonth(
                                    availableDates, 
                                    assignedDates,
                                    monthYear, 
                                    _selectedDates,
                                    (date, isSelectable) {
                                      if (isSelectable) {
                                        setDialogState(() {
                                          if (_selectedDates.contains(date)) {
                                            _selectedDates.remove(date);
                                          } else {
                                            _selectedDates.add(date);
                                          }
                                        });
                                      }
                                    }
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 10),
              // Selected dates count indicator
              if (_selectedDates.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '${_selectedDates.length} dates selected',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF79C9FF),
                    ),
                  ),
                ),
              // Assign Location Button
              ElevatedButton(
                onPressed: _selectedDates.isNotEmpty
                    ? () => _assignLocation(user)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF79C9FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text(
                  'Assign Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  minimumSize: const Size(double.infinity, 45),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildSelectableCalendarForMonth(
    List<DateTime> availableDates,
    List<DateTime> assignedDates,
    String monthYear, 
    Set<DateTime> selectedDates,
    Function(DateTime, bool) onDateTap
  ) {
    final parts = monthYear.split(' ');
    final monthName = parts[0];
    final year = int.parse(parts[1]);

    final monthNumber = DateFormat('MMMM').parse(monthName).month;

    final firstDayOfMonth = DateTime(year, monthNumber, 1);
    final lastDayOfMonth = DateTime(year, monthNumber + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final firstWeekday = firstDayOfMonth.weekday;

    // Normalize all dates to compare just year, month, day
    final availableDaysSet = availableDates.map((date) => DateTime(
      date.year, 
      date.month, 
      date.day
    )).toSet();
    
    final assignedDaysSet = assignedDates.map((date) => DateTime(
      date.year, 
      date.month, 
      date.day
    )).toSet();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayLabel('M'),
              _WeekdayLabel('T'),
              _WeekdayLabel('W'),
              _WeekdayLabel('T'),
              _WeekdayLabel('F'),
              _WeekdayLabel('S'),
              _WeekdayLabel('S'),
            ],
          ),
          const SizedBox(height: 10),
          // Calendar grid
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: (firstWeekday - 1) + daysInMonth,
              itemBuilder: (context, index) {
                if (index < (firstWeekday - 1)) {
                  return const SizedBox();
                }

                final dayNumber = index - (firstWeekday - 1) + 1;
                final currentDate = DateTime(year, monthNumber, dayNumber);
                final isAvailable = availableDaysSet.contains(currentDate);
                final isAssigned = assignedDaysSet.contains(currentDate);
                final isSelected = selectedDates.contains(currentDate);

                // All days are selectable
                return _SelectableCalendarDay(
                  date: currentDate,
                  isAvailable: isAvailable,
                  isAssigned: isAssigned,
                  isSelected: isSelected,
                  onTap: () => onDateTap(currentDate, true),
                );
              },
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                // Available dates
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF79C9FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('Available', style: TextStyle(fontSize: 12)),
                  ],
                ),
                // Assigned dates
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('Assigned', style: TextStyle(fontSize: 12)),
                  ],
                ),
                // Selected dates
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('Selected', style: TextStyle(fontSize: 12)),
                  ],
                ),
                // New proposed dates
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('New Date', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _assignLocation(ReadyToWorkUser user) async {
    if (_selectedDates.isEmpty) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Convert DateTime to formatted strings (yyyy-MM-dd)
      List<String> formattedDates = _selectedDates
          .map((date) => DateFormat('yyyy-MM-dd').format(date))
          .toList();
      
      // Split dates into categories: available dates and newly proposed dates
      Set<DateTime> availableDatesSet = user.readyToWorkDates.map((date) => 
          DateTime(date.year, date.month, date.day)).toSet();
          
      List<String> existingDates = [];
      List<String> newDates = [];
      
      for (DateTime date in _selectedDates) {
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);
        if (availableDatesSet.contains(normalizedDate)) {
          existingDates.add(DateFormat('yyyy-MM-dd').format(date));
        } else {
          newDates.add(DateFormat('yyyy-MM-dd').format(date));
        }
      }
      
      final provider = Provider.of<AdminProvider>(context, listen: false);
      List<DateTime> assignedDatesList = [];
      
      // Process existing dates
      if (existingDates.isNotEmpty) {
        await provider.assignLocationProvider(
          user.studentId,
          widget.locationId,
          existingDates,
        );
        
        // Add these dates to our assigned dates list
        for (String dateStr in existingDates) {
          assignedDatesList.add(DateFormat('yyyy-MM-dd').parse(dateStr));
        }
      }
      
      // Process new proposed dates
      if (newDates.isNotEmpty) {
        await provider.proposeDatesProvider(
          user.studentId,
          newDates,
        );
        
        await provider.assignLocationProvider(
          user.studentId,
          widget.locationId,
          newDates,
        );
        
        // Add these dates to our assigned dates list
        for (String dateStr in newDates) {
          assignedDatesList.add(DateFormat('yyyy-MM-dd').parse(dateStr));
        }
      }
      
      // Close dialog first
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Update assigned dates map with the new dates
      setState(() {
        // If user already has assigned dates, add to them
        if (_assignedDatesMap.containsKey(user.studentId)) {
          List<DateTime> existingAssignedDates = _assignedDatesMap[user.studentId] ?? [];
          
          // Add any new dates that aren't already in the list
          for (DateTime date in assignedDatesList) {
            if (!existingAssignedDates.any((existing) => 
                existing.year == date.year && 
                existing.month == date.month && 
                existing.day == date.day)) {
              existingAssignedDates.add(date);
            }
          }
          
          _assignedDatesMap[user.studentId] = existingAssignedDates;
        } else {
          // First time assignment for this user
          _assignedDatesMap[user.studentId] = assignedDatesList;
        }
      });
      
      // Success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location assignments completed successfully'),
            backgroundColor: Color(0xFF4CD964),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign location: $e'),
            backgroundColor: Colors.red,
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
                              final hasAssignedDates = _assignedDatesMap.containsKey(user.studentId) && 
                                  (_assignedDatesMap[user.studentId]?.isNotEmpty ?? false);
                              
                              return _EmployeeListItem(
                                user: user,
                                hasAssignedDates: hasAssignedDates,
                                onTap: () => _showAvailabilityDialog(context, user),
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
            color: hasAssignedDates ? const Color(0xFF79C9FF) : Colors.grey.shade200,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SelectableCalendarDay extends StatelessWidget {
  final DateTime date;
  final bool isAvailable;
  final bool isAssigned;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCalendarDay({
    Key? key,
    required this.date,
    required this.isAvailable,
    required this.isAssigned,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BoxBorder? border;
    
    if (isSelected) {
      if (isAvailable) {
        bgColor = Colors.green; // Selected and available
        textColor = Colors.white;
      } else {
        bgColor = Colors.orange; // Selected but not originally available
        textColor = Colors.white;
      }
    } else if (isAssigned) {
      bgColor = Colors.purple; // Already assigned to this location
      textColor = Colors.white;
    } else if (isAvailable) {
      bgColor = const Color(0xFF79C9FF); // Available but not selected
      textColor = Colors.white;
    } else {
      bgColor = Colors.transparent; // Not available and not selected
      textColor = Colors.black;
      border = Border.all(color: Colors.grey.shade300);
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected || isAvailable || isAssigned ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}