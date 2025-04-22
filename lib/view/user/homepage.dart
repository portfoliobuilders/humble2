import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:humble/provider/user_providers.dart';
import 'package:humble/view/user/checkout.dart';
import 'package:humble/view/user/notification.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currentLocationMessage;
  double _sliderPosition = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserProfileProvider();
      userProvider.fetchLocationProvider();
      userProvider.fetchWorkingHoursProvider();
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can continue accessing the position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
  }

  Future<void> _performCheckOut() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ConfirmCheckoutScreen(),
      ),
    );

    if (result is Map<String, dynamic>) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      try {
        Position currentPosition = await _determinePosition();

        await userProvider.checkOutProvider(
          result['headNurseSignature'],
          result['headNurseName'],
          currentPosition.latitude.toString(),
          currentPosition.longitude.toString(),
        );

        setState(() {
          _sliderPosition = 0.0;
        });

        userProvider.fetchWorkingHoursProvider();

        _showSuccessSnackBar(
            'Checkout successful. Total Hours: ${result['totalHoursWorked']}');
      } catch (e) {
        String errorMessage;
        if (e.toString().contains('denied')) {
          errorMessage =
              'Please enable location permissions in your browser settings to check out.';
        } else if (e.toString().contains('disabled')) {
          errorMessage =
              'Please enable location services on your device to check out.';
        } else {
          errorMessage = 'Checkout failed: ${e.toString()}';
        }
        _showErrorSnackBar(errorMessage);
      }
    }
  }

  Future<void> _performCheckIn() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Get the assigned location
      final assignedLocation = userProvider.location;

      if (assignedLocation == null) {
        _showErrorSnackBar('No assigned location found');
        return;
      }

      // Get current position using the new method
      Position currentPosition = await _determinePosition();

      // Calculate distance between current and assigned location
      double distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          assignedLocation.latitude,
          assignedLocation.longitude);

      // Check if within 100 meters
      const double maxAllowedDistance = 100; // meters
      if (distance <= maxAllowedDistance) {
        // Perform check-in
        await userProvider.checkInProvider(
            currentPosition.latitude, currentPosition.longitude);

        // Refresh working hours after check-in
        userProvider.fetchWorkingHoursProvider();

        // Get readable location details
        List<Placemark> placemarks = await placemarkFromCoordinates(
            currentPosition.latitude, currentPosition.longitude);

        String locationDetails = placemarks.isNotEmpty
            ? "${placemarks[0].name}, ${placemarks[0].locality}"
            : "${currentPosition.latitude}, ${currentPosition.longitude}";

        setState(() {
          _currentLocationMessage =
              "$locationDetails at ${DateFormat('hh:mm a').format(DateTime.now())}";
        });

        _showSuccessSnackBar('Check-in successful');
      } else {
        _showErrorSnackBar('You are not within the allowed check-in radius');
      }
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('denied')) {
        errorMessage =
            'Please enable location permissions in your browser settings to check in.';
      } else if (e.toString().contains('disabled')) {
        errorMessage =
            'Please enable location services on your device to check in.';
      } else {
        errorMessage = 'Error accessing location: ${e.toString()}';
      }
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      // _buildDateSelector(),
                      // const SizedBox(height: 24),
                      _buildWorkingHoursAndAttendance(),
                      const SizedBox(height: 24),
                      _buildActivitySection(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _buildSliderButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderButton() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final bool isReady = userProvider.isAvailable;
        final bool isCheckedIn = userProvider.isCheckedIn;

        return LayoutBuilder(
          builder: (context, constraints) {
            double containerWidth = constraints.maxWidth;
            double startPosition = containerWidth * 0.015;
            double endPosition = containerWidth * 0.79;

            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background container
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: isCheckedIn
                              ? Colors.red.shade600
                              : Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            isCheckedIn
                                ? 'Slide to Check Out'
                                : 'Slide to Check In',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      // Slider
                      Positioned(
                        left: _sliderPosition >= startPosition
                            ? (_sliderPosition <= endPosition
                                ? _sliderPosition
                                : endPosition)
                            : startPosition,
                        top: 5,
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            setState(() {
                              _sliderPosition += details.primaryDelta ?? 0;
                              _sliderPosition = _sliderPosition.clamp(
                                  startPosition, endPosition);
                            });
                          },
                          onHorizontalDragEnd: (_) async {
                            if (_sliderPosition > endPosition / 2) {
                              try {
                                if (isCheckedIn) {
                                  await _performCheckOut();
                                } else {
                                  await _performCheckIn();
                                }
                              } catch (e) {
                                _showErrorSnackBar(
                                    'Operation failed: ${e.toString()}');
                              } finally {
                                setState(() {
                                  _sliderPosition = startPosition;
                                });
                              }
                            } else {
                              setState(() {
                                _sliderPosition = startPosition;
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 50,
                            width: 75,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isCheckedIn ? Icons.logout : Icons.login,
                                  color: isCheckedIn
                                      ? Colors.red.shade600
                                      : Colors.blue.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.userProfile?.user;
        if (user == null) {
          return const CircularProgressIndicator();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/user (1).png'),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Floor Manager',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkingHoursAndAttendance() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final location = userProvider.location;
        final workingHours = userProvider.workingHours;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Attendance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Left side - Location info
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.blue),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Assigned Location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          location?.name ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          location != null
                              ? '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}'
                              : 'Fetching location',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Right side - Total Hours info
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.blue),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Total Working Hours',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          workingHours?.totalHoursWorked ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'For This Month',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: AttendanceCard(
                    title: 'Break Time',
                    time: '00:45 min',
                    subtitle: 'Avg Time',
                    icon: Icons.timer,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AttendanceCard(
                    title: 'Total Days',
                    time: '28',
                    subtitle: 'Working Days',
                    icon: Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivitySection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final workSessions = userProvider.workingHours?.workSessions ?? [];

        // Sort work sessions by check-in time (most recent first)
        if (workSessions.isNotEmpty) {
          workSessions.sort((a, b) => DateTime.parse(b.checkInTime)
              .compareTo(DateTime.parse(a.checkInTime)));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Only show the most recent activity
            if (workSessions.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Most recent check-in
                    ActivityItem(
                      title: 'Check In',
                      subtitle: 'At ${workSessions[0].locationName}',
                      time: DateFormat('hh:mm a')
                          .format(DateTime.parse(workSessions[0].checkInTime)),
                      status: 'On Time',
                      icon: Icons.login,
                    ),

                    // Most recent check-out (if exists)
                    if (workSessions[0].checkOutTime != null)
                      ActivityItem(
                        title: 'Check Out',
                        subtitle: 'At ${workSessions[0].locationName}',
                        time: DateFormat('hh:mm a').format(
                            DateTime.parse(workSessions[0].checkOutTime!)),
                        status: 'Hours: ${workSessions[0].hoursWorked}',
                        icon: Icons.logout,
                      ),
                  ],
                ),
              ),
            ] else if (userProvider.isCheckedIn) ...[
              // Current check-in if no historical sessions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ActivityItem(
                      title: 'Check In',
                      subtitle: 'Today',
                      time: DateFormat('hh:mm a')
                          .format(userProvider.checkInTime ?? DateTime.now()),
                      status: 'On Time',
                      icon: Icons.login,
                    ),
                    if (_currentLocationMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentLocationMessage!,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ] else ...[
              // No activities to show
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          bool isSelected = index == 3;
          return DateItem(
            day: (index + 3).toString().padLeft(2, '0'),
            weekDay: _getWeekDay(index),
            isSelected: isSelected,
          );
        },
      ),
    );
  }

  String _getWeekDay(int index) {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekDays[index % 7];
  }
}

class DateItem extends StatelessWidget {
  final String day;
  final String weekDay;
  final bool isSelected;

  const DateItem({
    Key? key,
    required this.day,
    required this.weekDay,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weekDay,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final String title;
  final String time;
  final String subtitle;
  final IconData icon;

  const AttendanceCard({
    Key? key,
    required this.title,
    required this.time,
    required this.subtitle,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String status;
  final IconData icon;

  const ActivityItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
