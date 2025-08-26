// In lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:findmyssn/services/pocketbase_service.dart';
import 'package:findmyssn/utils/dialog_helper.dart';

class NotificationService {
  final pb = PocketBaseService.pb;

  void initialize(BuildContext context) {
    // Subscribe to all new items being created
    pb.collection('items').subscribe('*', (e) {
      if (e.action == 'create') {
        _checkForMatches(e.record!, context);
      }
    });
  }

  Future<void> _checkForMatches(dynamic newItem, BuildContext context) async {
    try {
      // Don't notify the user who just reported the item
      //if (newItem.data['finder'] == pb.authStore.model.id) return;

      final newItemTitle = newItem.data['title'].toString().toLowerCase();
      final userWatches = await pb.collection('watches').getFullList(
        filter: 'user = "${pb.authStore.model.id}"',
      );

      for (final watch in userWatches) {
        final query = watch.data['query_text'].toString().toLowerCase();
        if (newItemTitle.contains(query)) {
          // A match was found! Show the notification dialog.
          DialogHelper.showInfoDialog(
            context: context,
            title: "Item Found!",
            message: "An item matching your watch for '$query' was just reported: \n\n$newItemTitle",
            type: DialogType.success,
          );
          // We found a match, no need to check other watches for this item
          return;
        }
      }
    } catch (e) {
      print("Error checking for notification matches: $e");
    }
  }
}
