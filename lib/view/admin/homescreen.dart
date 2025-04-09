import 'package:flutter/material.dart';
import 'package:humble/model/admin_model.dart';
import 'package:humble/provider/admin_providers.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

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
      // Access the data provider and fetch data
      final dataProvider = Provider.of<AdminProvider>(context, listen: false);
      await dataProvider.fetchDataProvider();

      // Fetch ready-to-work users data
      await dataProvider.fetchReadyToWorkUsersProvider();
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

  void _showAvailabilityDialog(BuildContext context, ReadyToWorkUser user) {
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
  final currentMonth = DateTime.now().month;
  final currentYear = DateTime.now().year;

  // Group dates by month for easier display
  Map<String, List<DateTime>> groupedDates = {};

  for (var date in user.readyToWorkDates) {
    final monthYear = DateFormat('MMMM yyyy').format(date);
    if (!groupedDates.containsKey(monthYear)) {
      groupedDates[monthYear] = [];
    }
    groupedDates[monthYear]!.add(date);
  }

  // Create a list of month-year pairs for showing months before and after
  List<String> allMonthYears = [];
  for (int i = -3; i <= 3; i++) {
    DateTime date = DateTime(currentYear, currentMonth + i, 1);
    allMonthYears.add(DateFormat('MMMM yyyy').format(date));
  }

  return Container(
    width: MediaQuery.of(context).size.width * 0.9,
    height: MediaQuery.of(context).size.height * 0.6, // Reduced height
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
                    'Available Dates',
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
        const Divider(),
        user.readyToWorkDates.isEmpty
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
                  controller: PageController(initialPage: 3), // Start at current month
                  itemBuilder: (context, index) {
                    final monthYear = allMonthYears[index];
                    final dates = groupedDates[monthYear] ?? [];
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 16),
                              onPressed: index > 0 ? () {} : null, // Visual only - PageView handles actual navigation
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
                              onPressed: index < allMonthYears.length - 1 ? () {} : null, // Visual only
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
                            child: _buildCalendarForMonth(dates, monthYear),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF79C9FF),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Close',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildCalendarForMonth(List<DateTime> dates, String monthYear) {
    final parts = monthYear.split(' ');
    final monthName = parts[0];
    final year = int.parse(parts[1]);

    final monthNumber = DateFormat('MMMM').parse(monthName).month;

    final firstDayOfMonth = DateTime(year, monthNumber, 1);

    final lastDayOfMonth = DateTime(year, monthNumber + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final firstWeekday = firstDayOfMonth.weekday;

    final availableDays = dates.map((date) => date.day).toSet();

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
          GridView.builder(
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
              final isAvailable = availableDays.contains(dayNumber);

              return _CalendarDay(
                day: dayNumber,
                isAvailable: isAvailable,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF79C9FF)),
                ),
              )
            : Consumer<AdminProvider>(
                builder: (context, dataProvider, child) {
                  final data = dataProvider.data;
                  final readyToWorkUsers = dataProvider.readyToWorkUsers;

                  if (data == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No data available',
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
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF79C9FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          pinned: true,
                          floating: true,
                          elevation: 0,
                          backgroundColor: Colors.white,
                          expandedHeight: 80,
                          automaticallyImplyLeading: false, 
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            title: const Text(
                              'Dashboard',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: _loadData,
                      color: const Color(0xFF79C9FF),
                      backgroundColor: Colors.white,
                      displacement: 80,
                      edgeOffset: 16,
                      strokeWidth: 3,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.3,
                              children: [
                                _buildStatCard('No of Employees',
                                    data.employeeCount.toString()),
                                _buildStatCard('Available Staff',
                                    '${readyToWorkUsers.length} Available'),
                                _buildStatCard('No of Sites',
                                    data.locationCount.toString()),
                                _buildStatCard(
                                    'No of Admins', data.adminCount.toString()),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Available Employees',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF79C9FF)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${readyToWorkUsers.length} Available',
                                      style: const TextStyle(
                                        color: Color(0xFF79C9FF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (readyToWorkUsers.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.person_off,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No available employees',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: readyToWorkUsers.length,
                                itemBuilder: (context, index) {
                                  final user = readyToWorkUsers[index];
                                  return _EmployeeListItem(
                                    user: user,
                                    onTap: () =>
                                        _showAvailabilityDialog(context, user),
                                  );
                                },
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeListItem extends StatelessWidget {
  final ReadyToWorkUser user;
  final VoidCallback onTap;

  const _EmployeeListItem({
    Key? key,
    required this.user,
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
            color: Colors.grey.shade200,
            width: 1,
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
                Icons.calendar_month,
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

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isAvailable;

  const _CalendarDay({
    Key? key,
    required this.day,
    required this.isAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFF79C9FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isAvailable ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            color: isAvailable ? Colors.white : Colors.black,
            fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
