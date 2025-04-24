import 'package:flutter/material.dart';
import 'package:humble/model/user_models.dart';
import 'package:humble/provider/user_providers.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignedLocationsScreen extends StatefulWidget {
  const AssignedLocationsScreen({Key? key}) : super(key: key);

  @override
  State<AssignedLocationsScreen> createState() =>
      _AssignedLocationsScreenState();
}

class _AssignedLocationsScreenState extends State<AssignedLocationsScreen> {
  Map<int, bool> expandedLocations = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchLocationProvider();
    });
  }

  void toggleExpanded(int index) {
    setState(() {
      expandedLocations[index] = !(expandedLocations[index] ?? false);
    });
  }

  List<AssignedDate> _getSortedLocations(List<AssignedDate> locations) {
    // Create a copy of the list to avoid modifying the original
    final sortedLocations = List<AssignedDate>.from(locations);

    // Sort by date (earliest first)
    sortedLocations.sort((a, b) {
      DateTime dateA;
      DateTime dateB;
      try {
        dateA = DateTime.parse(a.date);
      } catch (e) {
        // If parsing fails, use a far future date
        dateA = DateTime(9999);
      }

      try {
        dateB = DateTime.parse(b.date);
      } catch (e) {
        // If parsing fails, use a far future date
        dateB = DateTime(9999);
      }

      return dateA.compareTo(dateB);
    });

    return sortedLocations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Assigned Locations',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final assignedDates = userProvider.assignedDates;

          if (userProvider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          }

          if (assignedDates == null || assignedDates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 70,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No locations assigned',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have no assigned locations at this time',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort the locations by date (earliest first)
          final sortedLocations = _getSortedLocations(assignedDates);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF2196F3),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Location Center',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Review your assigned locations and appointment details.',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...sortedLocations.asMap().entries.map((entry) {
                final index = entry.key;
                final location = entry.value;
                final isToday = _isToday(location.date);

                return LocationTile(
                  locationName: location.locationName,
                  date: DateTime.parse(location.date),
                  isExpanded: expandedLocations[index] ?? false,
                  onTap: () => toggleExpanded(index),
                  isToday: isToday,
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  bool _isToday(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final today = DateTime.now();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    } catch (e) {
      return false;
    }
  }
}

class LocationTile extends StatelessWidget {
  final String locationName;
  final DateTime date;

  final bool isExpanded;
  final VoidCallback onTap;
  final bool isToday;
  

  const LocationTile({
    Key? key,
    required this.locationName,
    required this.date,
  
    required this.isExpanded,
    required this.onTap,
    required this.isToday,
    
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: isToday ? Colors.blue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday ? Colors.blue.shade300 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isToday
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: isToday ? Colors.blue.shade700 : Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                locationName,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isToday
                                      ? Colors.blue.shade800
                                      : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                if (isToday)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Today',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('MMM dd').format(date),
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('EEEE, yyyy').format(date),
                              style: GoogleFonts.montserrat(
                                color: Colors.grey.shade600,
                                fontSize: 12,
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
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMMM dd, yyyy').format(date),
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                      ],
                    ),
                    
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
