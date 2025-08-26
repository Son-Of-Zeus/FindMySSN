// In lib/screens/claim_success_page.dart

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class ClaimSuccessPage extends StatelessWidget {
  final RecordModel claimedItem;
  final String finderName;
  final String finderContact;

  const ClaimSuccessPage({
    super.key,
    required this.claimedItem,
    required this.finderName,
    required this.finderContact,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Claim Successful!"),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    "You have successfully claimed:",
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    claimedItem.data['title'],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 40),
                  Text(
                    "Please contact the finder to arrange collection:",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Finder's Name"),
                    subtitle: Text(finderName, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  ListTile(
                    leading: const Icon(Icons.contact_phone),
                    title: const Text("Finder's Contact"),
                    subtitle: Text(finderContact, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Go back to the item list
                    },
                    child: const Text("Done"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
