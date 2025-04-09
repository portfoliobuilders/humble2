import 'package:flutter/material.dart';
import 'package:humble/view/admin/location_home.dart';
import 'available_employees.dart';
import 'add_location.dart'; // <- Import your add site screen

class WorkSitesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        Widget page = WorkSitesHome();

        switch (settings.name) {
          case '/assign':
            final locationId = settings.arguments as String;
            page = AvailableEmployees(locationId: locationId);
            break;
          case '/add-site':
            final args = settings.arguments as Map<String, dynamic>?;

            page = AddEditLocationScreen(
              locationId: args?['locationId'],
              initialName: args?['initialName'],
              initialLatitude: args?['initialLatitude'],
              initialLongitude: args?['initialLongitude'],
            );
            break;
        }

        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}
