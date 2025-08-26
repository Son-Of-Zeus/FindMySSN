// In lib/services/location_service.dart

import 'package:flutter/material.dart';
import 'package:findmyssn/services/pocketbase_service.dart';

class LocationService {

  /// Determines the location cluster by showing a manual input dialog.
  /// This is the single public method this service will expose for the demo.
  Future<String?> determineLocationCluster(BuildContext context) async {
    // For the demo, we will always show the manual input dialog.
    return await _showManualBssidInputDialog(context);
  }

  /// Shows a pop-up dialog for the user to manually enter a location ID.
  ///
  /// It returns the corresponding 'clusterId' on success, or 'null' on failure/cancel.
  Future<String?> _showManualBssidInputDialog(BuildContext context) async {
    final bssidController = TextEditingController();
    String? finalClusterId;

    // 'showDialog' returns a Future that completes when the dialog is popped.
    await showDialog(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Enter Location ID"),
          content: TextField(
            controller: bssidController,
            autofocus: true, // Automatically focus the text field
            decoration: const InputDecoration(
              hintText: "e.g., 'library_wifi', 'cafe_wifi'",
              labelText: "Demo Location ID",
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog, returns null
              },
            ),
            ElevatedButton(
              child: const Text("Submit"),
              onPressed: () async {
                final manualBssid = bssidController.text.trim();
                if (manualBssid.isEmpty) return;

                try {
                  // Look up the manual BSSID in the PocketBase collection
                  final record = await PocketBaseService.pb
                      .collection('bssid_location_map')
                      .getFirstListItem('bssid = "$manualBssid"');

                  finalClusterId = record.data['clusterId'];
                  Navigator.of(dialogContext).pop(); // Close the dialog
                } catch (e) {
                  // If the ID is not found, show an error and keep the dialog open
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Location ID not found! Please try again.")),
                  );
                }
              },
            ),
          ],
        );
      },
    );

    // This will return the clusterId if found, or null if the user cancelled.
    return finalClusterId;
  }
}
