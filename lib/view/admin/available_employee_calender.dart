import 'package:flutter/material.dart';
import 'package:humble/model/admin_model.dart';
import 'package:humble/provider/admin_providers.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EmployeeAvailabilityPage extends StatefulWidget {
  final ReadyToWorkUser user;
  final String locationId;
  final List<DateTime> assignedDates;
  final Function(List<DateTime>) onAssignmentComplete;

  const EmployeeAvailabilityPage({
    Key? key,
    required this.user,
    required this.locationId,
    required this.assignedDates,
    required this.onAssignmentComplete,
  }) : super(key: key);

  @override
  State<EmployeeAvailabilityPage> createState() =>
      _EmployeeAvailabilityPageState();
}

class _EmployeeAvailabilityPageState extends State<EmployeeAvailabilityPage> {
  Set<DateTime> _selectedDates = {};
  Set<DateTime> _proposedDates = {};
  bool _isLoading = true;
  late PageController _pageController;
  int _currentPage = 6;
  List<DateTime> _assignedDates = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _assignedDates = widget.assignedDates;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAssignedDates();
    });
  }

  Future<void> _fetchAssignedDates() async {
    try {
      // Access the provider after the first frame is rendered
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      final provider = Provider.of<AdminProvider>(context, listen: false);
      final success =
          await provider.fetchAssignedDatesProvider(widget.user.studentId);

      if (success && mounted) {
        setState(() {
          // Update assignedDates with the fetched data
          if (provider.assignedDatesResponse != null &&
              provider.assignedDatesResponse!.assignedDates.isNotEmpty) {
            // Convert the string dates to DateTime objects
            _assignedDates =
                provider.assignedDatesResponse!.assignedDates.map((dateString) {
              // Parse the string date to DateTime
              return DateFormat('yyyy-MM-dd').parse(dateString);
            }).toList();
          }
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch assigned dates'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching assigned dates: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _assignLocation() async {
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
      Set<DateTime> availableDatesSet = widget.user.readyToWorkDates
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet();

      List<String> existingDates = [];
      List<String> newDates = [];

      for (DateTime date in _selectedDates) {
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);
        if (availableDatesSet.contains(normalizedDate)) {
          existingDates.add(DateFormat('yyyy-MM-dd').format(date));
        } else {
          newDates.add(DateFormat('yyyy-MM-dd').format(date));

          // Add to proposed dates set for UI highlighting
          _proposedDates.add(normalizedDate);
        }
      }

      final provider = Provider.of<AdminProvider>(context, listen: false);
      List<DateTime> assignedDatesList = [];

      // Process existing dates
      if (existingDates.isNotEmpty) {
        await provider.assignLocationProvider(
          widget.user.studentId,
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
          widget.user.studentId,
          newDates,
        );

        await provider.assignLocationProvider(
          widget.user.studentId,
          widget.locationId,
          newDates,
        );

        // Add these dates to our assigned dates list
        for (String dateStr in newDates) {
          assignedDatesList.add(DateFormat('yyyy-MM-dd').parse(dateStr));
        }
      }

      // Update the parent with newly assigned dates
      widget.onAssignmentComplete(assignedDatesList);

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

      // Navigate back
      if (mounted) {
        Navigator.of(context).pop();
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

  List<String> _getMonthYearList() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Create a list of month-year pairs for showing 6 months before and 6 months after
    List<String> allMonthYears = [];
    for (int i = -6; i <= 6; i++) {
      DateTime date = DateTime(currentYear, currentMonth + i, 1);
      allMonthYears.add(DateFormat('MMMM yyyy').format(date));
    }

    return allMonthYears;
  }

  // Group dates by month for easier display
  Map<String, List<DateTime>> _getGroupedDates(List<DateTime> dates) {
    Map<String, List<DateTime>> groupedDates = {};

    for (var date in dates) {
      final monthYear = DateFormat('MMMM yyyy').format(date);
      if (!groupedDates.containsKey(monthYear)) {
        groupedDates[monthYear] = [];
      }
      groupedDates[monthYear]!.add(date);
    }

    return groupedDates;
  }

  @override
  Widget build(BuildContext context) {
    final monthYearList = _getMonthYearList();
    final groupedDates = _getGroupedDates(widget.user.readyToWorkDates);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Assign ${widget.user.name}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF79C9FF)),
              ),
            )
          : Column(
              children: [
                // Employee info card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF79C9FF),
                        child: Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.user.phoneNumber,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CD964)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF4CD964),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.user.readyToWorkDates.length} Available Days',
                                        style: const TextStyle(
                                          color: Color(0xFF4CD964),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Month selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        onPressed: _currentPage > 0
                            ? () {
                                _currentPage--;
                                _pageController.animateToPage(
                                  _currentPage,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        color: const Color(0xFF79C9FF),
                      ),
                      Text(
                        monthYearList[_currentPage],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF79C9FF),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: _currentPage < monthYearList.length - 1
                            ? () {
                                _currentPage++;
                                _pageController.animateToPage(
                                  _currentPage,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        color: const Color(0xFF79C9FF),
                      ),
                    ],
                  ),
                ),

                // Calendar view
                Expanded(
                  child: PageView.builder(
                    itemCount: monthYearList.length,
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final monthYear = monthYearList[index];
                      final availableDates = groupedDates[monthYear] ?? [];

                      return Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: _buildCalendarForMonth(
                          availableDates,
                          monthYear,
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(const Color.fromARGB(255, 198, 232, 255),
                          'Available'),
                      _buildLegendItem(Colors.green, 'Assigned'),
                      _buildLegendItem(Colors.blue, 'Selected'),
                      _buildLegendItem(Colors.orange, 'Proposed'),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_selectedDates.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            '${_selectedDates.length} dates selected',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF79C9FF),
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed:
                            _selectedDates.isNotEmpty ? _assignLocation : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF79C9FF),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Assign Location',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCalendarForMonth(
    List<DateTime> availableDates,
    String monthYear,
  ) {
    final parts = monthYear.split(' ');
    final monthName = parts[0];
    final year = int.parse(parts[1]);

    final monthNumber = DateFormat('MMMM').parse(monthName).month;

    final firstDayOfMonth = DateTime(year, monthNumber, 1);
    final daysInMonth = DateTime(year, monthNumber + 1, 0).day;

    // Add firstWeekday - 1 days before the 1st to account for the offset
    // Monday = 1, Sunday = 7 in DateTime.weekday
    final firstWeekday = firstDayOfMonth.weekday;

    // Normalize all dates to compare just year, month, day
    final availableDaysSet = availableDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet();

    final assignedDaysSet = _assignedDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet();

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
                final isSelected = _selectedDates.contains(currentDate);
                final isProposed = _proposedDates.contains(currentDate);

                // Build the day cell
                return _CalendarDay(
                  date: currentDate,
                  isAvailable: isAvailable,
                  isAssigned: isAssigned,
                  isSelected: isSelected,
                  isProposed: isProposed,
                  onTap: () {
                    setState(() {
                      if (_selectedDates.contains(currentDate)) {
                        _selectedDates.remove(currentDate);

                        // Also remove from proposed dates if it's not available
                        if (!isAvailable) {
                          _proposedDates.remove(currentDate);
                        }
                      } else {
                        _selectedDates.add(currentDate);

                        // If it's not in the available dates, mark it as proposed
                        if (!isAvailable) {
                          _proposedDates.add(currentDate);
                        }
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
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

class _CalendarDay extends StatelessWidget {
  final DateTime date;
  final bool isAvailable;
  final bool isAssigned;
  final bool isSelected;
  final bool isProposed;
  final VoidCallback onTap;

  const _CalendarDay({
    Key? key,
    required this.date,
    required this.isAvailable,
    required this.isAssigned,
    required this.isSelected,
    required this.isProposed,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BoxBorder? border;

    if (isSelected) {
      if (isAvailable) {
        bgColor = Colors.blue; // Selected and available
        textColor = Colors.white;
      } else {
        bgColor = Colors.blue;
        textColor = Colors.white;
      }
    } else if (isAssigned) {
      bgColor = Colors.green; // Already assigned to this location
      textColor = Colors.white;
    } else if (isProposed) {
      bgColor =
          Colors.orange; // Proposed date (not available but selected before)
      textColor = Colors.white;
    } else if (isAvailable) {
      bgColor = const Color.fromARGB(
          255, 198, 232, 255); // Available but not selected
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
              fontWeight: isSelected || isAvailable || isAssigned || isProposed
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
