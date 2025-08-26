// In lib/screens/my_watches_page.dart

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:findmyssn/services/pocketbase_service.dart';
import 'package:findmyssn/utils/dialog_helper.dart';

class MyWatchesPage extends StatefulWidget {
  const MyWatchesPage({super.key});

  @override
  State<MyWatchesPage> createState() => _MyWatchesPageState();
}

class _MyWatchesPageState extends State<MyWatchesPage> {
  final pb = PocketBaseService.pb;
  List<RecordModel> _watches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWatches();
  }

  Future<void> _fetchWatches() async {
    setState(() => _isLoading = true);
    try {
      final records = await pb.collection('watches').getFullList(
        sort: '-created',
        filter: 'user = "${pb.authStore.model.id}"',
      );
      if (mounted) {
        setState(() => _watches = records);
      }
    } catch (e) {
      print("Error fetching watches: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addWatch() async {
    final queryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Watch"),
        content: TextField(
          controller: queryController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Keywords to watch for",
            hintText: "e.g., 'blue bottle', 'iphone 14'",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (queryController.text.trim().isEmpty) return;
              try {
                await pb.collection('watches').create(body: {
                  'user': pb.authStore.model.id,
                  'query_text': queryController.text.trim(),
                });
                Navigator.of(context).pop();
                _fetchWatches(); // Refresh the list
              } catch (e) {
                print("Error creating watch: $e");
              }
            },
            child: const Text("Add Watch"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWatch(String id) async {
    try {
      await pb.collection('watches').delete(id);
      _fetchWatches(); // Refresh the list
    } catch (e) {
      print("Error deleting watch: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Watch List")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _watches.isEmpty
          ? const Center(child: Text("You are not watching for any items yet."))
          : ListView.builder(
        itemCount: _watches.length,
        itemBuilder: (context, index) {
          final watch = _watches[index];
          return ListTile(
            leading: const Icon(Icons.remove_red_eye_outlined),
            title: Text(watch.data['query_text']),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteWatch(watch.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWatch,
        icon: const Icon(Icons.add),
        label: const Text("Add Watch"),
      ),
    );
  }
}
