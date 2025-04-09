import 'package:flutter/material.dart';
import 'package:humble/model/admin_model.dart';
import 'package:humble/provider/admin_providers.dart';
import 'package:humble/view/admin/add_location.dart';
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
                        // icon: Icon(Icons.add),
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
                          Navigator.of(context).pushNamed('/add-site');
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
    final String status = 'Available'; // Replace with dynamic status if needed

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    location.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    color: status == 'Available' ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: Colors.black54, size: 22),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your address will go here',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.people, color: Colors.black54, size: 22),
                SizedBox(width: 8),
                Text(
                  getFormattedCoordinates(
                      location.latitude, location.longitude),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                Spacer(),
                IconButton(
                  icon: const ImageIcon(
                    AssetImage('assets/Create.png'),
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/add-site',
                      arguments: {
                        'locationId': locationId,
                        'initialName': location.name,
                        'initialLatitude': location.latitude.toString(),
                        'initialLongitude': location.longitude.toString(),
                      },
                    );
                  },
                )
              ],
            ),
            SizedBox(height: 8),
            // Assign Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text(
                  'Assign Workers',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed('/assign', arguments: locationId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
