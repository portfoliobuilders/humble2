import 'package:flutter/material.dart';
import 'package:humble/provider/admin_providers.dart';
import 'package:provider/provider.dart';

class AddEditLocationScreen extends StatefulWidget {
  final String? locationId;
  final String? initialName;
  final String? initialLatitude;
  final String? initialLongitude;

  const AddEditLocationScreen({
    Key? key,
    this.locationId,
    this.initialName,
    this.initialLatitude,
    this.initialLongitude,
  }) : super(key: key);

  @override
  State<AddEditLocationScreen> createState() => _AddEditLocationScreenState();
}

class _AddEditLocationScreenState extends State<AddEditLocationScreen> {
  final _nameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _latitudeController.text = widget.initialLatitude ?? '';
    _longitudeController.text = widget.initialLongitude ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _saveLocation() {
    final name = _nameController.text.trim();
    final latitude = _latitudeController.text.trim();
    final longitude = _longitudeController.text.trim();

    if (name.isEmpty || latitude.isEmpty || longitude.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final locationProvider = Provider.of<AdminProvider>(context, listen: false);

    final Future<void> result = widget.locationId != null
        ? locationProvider.editLocationProvider(
            widget.locationId!, name, latitude, longitude)
        : locationProvider.createLocationProvider(name, latitude, longitude);

    result.then((_) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.locationId != null
              ? 'Location updated successfully'
              : 'Location added successfully'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operation failed: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.locationId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          isEditing ? 'Edit Site' : 'Add Site',
          style: const TextStyle(
              color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Site Details' : 'Add New Site',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel('Site Name'),
            _buildInputField(_nameController),
            const SizedBox(height: 24),
            _buildLabel('Latitude'),
            _buildInputField(_latitudeController),
            const SizedBox(height: 24),
            _buildLabel('Longitude'),
            _buildInputField(_longitudeController),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isEditing ? 'Update Site' : 'Add Site',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (isEditing)
              TextButton.icon(
                onPressed: () {
                  final locationProvider =
                      Provider.of<AdminProvider>(context, listen: false);

                  showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delete Site',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Are you sure you want to delete this site?',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 32),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop(); // Close the dialog
                                    locationProvider
                                        .deleteLocationProvider(
                                            widget.locationId!)
                                        .then((_) {
                                      Navigator.of(context)
                                          .pop(); // Go back to previous screen
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Site deleted successfully')),
                                      );
                                    }).catchError((error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Delete failed: $error')),
                                      );
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Delete Site',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  style: TextButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Delete site',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      );

  Widget _buildInputField(TextEditingController controller) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      );
}
