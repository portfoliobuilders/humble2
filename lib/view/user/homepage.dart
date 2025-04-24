import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humble/model/user_models.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUserProfileProvider();
      await userProvider.fetchLocationProvider();
      await userProvider.fetchWorkingHoursProvider();
    } catch (e) {
      // Handle silently - errors will be managed by the provider
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _performCheckIn() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Check if there's an assigned location for today
      final todayAssignment = _getTodayAssignment(userProvider);

      if (todayAssignment == null) {
        _showInfoSnackBar('No assignment scheduled for today');
        return;
      }

      Position currentPosition = await _determinePosition();
      await userProvider.checkInProvider(
          currentPosition.latitude, currentPosition.longitude);

      await userProvider.fetchWorkingHoursProvider();

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
    } catch (e) {
      String errorMessage = 'Check-in failed';

      if (e.toString().contains('LocationServiceDisabledException')) {
        errorMessage = 'Please enable location services';
      } else if (e.toString().contains('LocationPermissionDeniedException')) {
        errorMessage = 'Location permission required';
      } else if (e.toString().contains('RadiusException')) {
        errorMessage = 'You are not within the allowed check-in area';
      } else if (e.toString().contains('NetworkException')) {
        errorMessage = 'Network connection error. Please try again';
      }

      _showErrorSnackBar(errorMessage);
    }
  }

// Replace the _performCheckOut error handling with this:
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

        final checkoutResult = await userProvider.checkOutProvider(
          result['headNurseSignature'],
          result['headNurseName'],
          currentPosition.latitude.toString(),
          currentPosition.longitude.toString(),
        );

        setState(() {
          _sliderPosition = 0.0;
        });

        await userProvider.fetchWorkingHoursProvider();

        _showSuccessSnackBar(
            'Checkout successful. Hours: ${checkoutResult['totalHoursWorked']}');
      } catch (e) {
        String errorMessage = 'Checkout failed';

        if (e.toString().contains('LocationServiceDisabledException')) {
          errorMessage = 'Please enable location services';
        } else if (e.toString().contains('LocationPermissionDeniedException')) {
          errorMessage = 'Location permission required';
        } else if (e.toString().contains('NetworkException')) {
          errorMessage = 'Network connection error. Please try again';
        } else if (e.toString().contains('ValidationException')) {
          errorMessage = 'Invalid head nurse signature';
        }

        _showErrorSnackBar(errorMessage);
      }
    }
  }

// Add a new method for information-type notifications
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  AssignedDate? _getTodayAssignment(UserProvider userProvider) {
    if (userProvider.assignedDates == null ||
        userProvider.assignedDates!.isEmpty) {
      return null;
    }

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Only return assignment if the date exactly matches today
    try {
      return userProvider.assignedDates!.firstWhere(
        (assignment) => assignment.date == today,
      );
    } catch (e) {
      // If no match is found, return null instead of a default assignment
      return null;
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(),
        ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Main content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _initializeData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 24),
                              _buildWorkingHoursAndAttendance(),
                              const SizedBox(height: 16),
                              _buildActivitySection(),
                            ],
                          ),
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
                            style: GoogleFonts.montserrat(
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
                                    'Operation failed. Please try again.');
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
          return const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/image.png'),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Employee',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Mark notifications as read when navigating to notification screen
                    if (userProvider.hasNewNotifications) {
                      userProvider.markNotificationsAsRead();
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
                if (userProvider.hasNewNotifications)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkingHoursAndAttendance() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final todayAssignment = _getTodayAssignment(userProvider);
        final workingHours = userProvider.workingHours;
        final user = userProvider.userProfile?.user;
        if (user == null) {
          return const SizedBox(
            height: 50,
            child: Center(child: Text('Welcome to Humble')),
          );
        }

        // Check if this is a new student without any assignments
        final bool isNewStudent = userProvider.assignedDates == null ||
            userProvider.assignedDates!.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Assignment",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            // Location Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isNewStudent
                            ? 'Hi ${user?.name} '
                            : 'Assigned Location',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                          isNewStudent
                              ? Icons.back_hand_rounded
                              : (todayAssignment != null
                                  ? Icons.location_on
                                  : Icons.notifications_active),
                          color: Colors.blue,
                          size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      isNewStudent
                          ? 'Welcome to Humble Hearts'
                          : (todayAssignment != null
                              ? todayAssignment.locationName
                              : 'No assignment for today'),
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isNewStudent) ...[
                    Center(
                      child: Text(
                        'Your first location will be assigned soon',
                        style: GoogleFonts.montserrat(
                            fontSize: 12, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ] else if (todayAssignment != null) ...[
                    
                    Center(
                      child: Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(todayAssignment.date))}',
                        style: GoogleFonts.montserrat(
                            fontSize: 18, color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${todayAssignment.latitude}, ${todayAssignment.longitude}',
                        style: GoogleFonts.montserrat(
                            fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    Center(
                      child: Text(
                        'Please check your schedule for upcoming assignments',
                        style: GoogleFonts.montserrat(
                            fontSize: 12, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Total Working Hours Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_outlined,
                          color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Total Working Hours',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      workingHours?.totalHoursWorked ?? '0:00',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'For This Month',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
            Text(
              'Your Recent Activity',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

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
                      status: '',
                      icon: Icons.login,
                    ),

                    const SizedBox(
                      height: 8,
                    ),
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
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
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
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status,
                style: GoogleFonts.montserrat(
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
