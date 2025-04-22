import 'package:flutter/material.dart';
import 'package:humble/model/admin_model.dart';
import 'package:humble/provider/admin_providers.dart';
import 'package:humble/view/admin/add_location.dart';
import 'package:humble/view/admin/available_employees.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WorkSitesHome extends StatefulWidget {
  @override
  _WorkSitesHomeState createState() => _WorkSitesHomeState();
}

class _WorkSitesHomeState extends State<WorkSitesHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false)
          .fetchLocationsProvider();
    });
  }

  String getFormattedCoordinates(double lat, double lng) {
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  void _navigateToAddSite(BuildContext context,
      {Map<String, dynamic>? arguments}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditLocationScreen(
          locationId: arguments?['locationId'],
          initialName: arguments?['initialName'],
          initialLatitude: arguments?['initialLatitude'],
          initialLongitude: arguments?['initialLongitude'],
        ),
      ),
    );
  }

  void _navigateToAssignWorkers(BuildContext context, String locationId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AvailableEmployees(locationId: locationId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              elevation: 0,
              backgroundColor: Colors.white,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  'Work Sites',
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
        body: Consumer<AdminProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: provider.locations.length,
                      itemBuilder: (context, index) {
                        final location = provider.locations[index];
                        return _buildWorkSiteCard(location);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Add Site', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          _navigateToAddSite(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWorkSiteCard(Location location) {
    final String locationId = location.locationId ?? '';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.asset(
                  'assets/workimage.jpg',
                  width: 120,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              // Right side - Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Location name with icon
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue, size: 20),
                          SizedBox(width: 4),
                          Text(
                            'Padamughal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // Coordinates
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Text(
                          '${location.latitude.toStringAsFixed(4)},${location.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      // Assign Employee button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _navigateToAssignWorkers(context, locationId);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            'Assign Employee',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
            child: TextButton(
              onPressed: () {
                _navigateToAddSite(
                  context,
                  arguments: {
                    'locationId': locationId,
                    'initialName': location.name,
                    'initialLatitude': location.latitude.toString(),
                    'initialLongitude': location.longitude.toString(),
                  },
                );
              },
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Edit location details',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
