// In lib/screens/home_page.dart (This is now the main menu)

import 'package:flutter/material.dart';
import 'package:findmyssn/screens/item_list_page.dart';
import 'package:findmyssn/screens/report_item_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SSN Lost & Found"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text("I Lost an Item"),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ItemListPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt),
                label: const Text("I Found an Item"),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReportItemPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
