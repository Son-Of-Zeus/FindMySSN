import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart'; // Ensure RecordAuth is imported
import 'package:findmyssn/screens/home_page.dart';
import 'package:findmyssn/services/location_service.dart';
import 'package:findmyssn/services/pocketbase_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final LocationService _locationService = LocationService();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeUserSession();
  }

  Future<void> _initializeUserSession() async {
    final pb = PocketBaseService.pb;

    if (pb.authStore.isValid) {
      print("Found valid session. Re-using existing user.");
      _isLoggedIn = true;
    } else {
      print("No valid session found. Creating a new guest user.");
      try {
        final guestUsername = 'guest_${DateTime.now().millisecondsSinceEpoch}';
        final fakeEmail = '$guestUsername@guest.com';

        // --- THE CORRECTED LOGIC ---
        // Use the generic 'authWithPassword' but on the 'users' collection to create a user and log in.
        // The SDK handles this flow by first creating the user if they don't exist.
        // However, a more explicit and reliable way is to use the result of the create call.

        // 1. Create the user record first
        final newUserRecord = await pb.collection('users').create(body: {
          'username': guestUsername,
          'email': fakeEmail,
          'emailVisibility': false,
          'password': '12345678',
          'passwordConfirm': '12345678',
        });

        print("Successfully created new guest user: ${newUserRecord.id}");

        // 2. Authenticate using the same credentials
        final authData = await pb.collection('users').authWithPassword(
          fakeEmail,
          '12345678',
        );

        print("Successfully authenticated user: ${authData.record?.id}");

        _isLoggedIn = true;

      } catch (e) {
        print("CRITICAL: Failed to create or authenticate guest user: $e");
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? const HomePage()
        : const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
