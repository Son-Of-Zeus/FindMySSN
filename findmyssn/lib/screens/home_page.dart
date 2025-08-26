// In lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:findmyssn/screens/item_list_page.dart';
import 'package:findmyssn/screens/my_watches_page.dart';
import 'package:findmyssn/screens/report_item_page.dart';
import 'package:findmyssn/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure the context is fully available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SSN Lost & Found Hub"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionCard(
              context: context,
              icon: Icons.search_sharp,
              title: "I Lost an Item",
              subtitle: "Browse reported items to find what you've lost.",
              color: Colors.blue.shade700,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ItemListPage()),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildActionCard(
              context: context,
              icon: Icons.add_location_alt_outlined,
              title: "I Found an Item",
              subtitle: "Report a found item to help it get back to its owner.",
              color: Colors.green.shade700,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportItemPage()),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildActionCard(
              context: context,
              icon: Icons.remove_red_eye,
              title: "My Watch List",
              subtitle: "Get notified when items you're looking for are found.",
              color: Colors.purple.shade700,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyWatchesPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- THE METHOD IS NOW CORRECTLY PLACED INSIDE THE STATE CLASS ---
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
