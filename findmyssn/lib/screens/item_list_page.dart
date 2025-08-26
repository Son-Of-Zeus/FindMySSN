// In lib/screens/item_list_page.dart

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:findmyssn/screens/claim_item_page.dart';
import 'package:findmyssn/services/pocketbase_service.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  List<RecordModel> _items = [];
  bool _isLoading = true;
  final pb = PocketBaseService.pb;

  @override
  void initState() {
    super.initState();
    _fetchItems();
    // Subscribe to real-time updates for automatic refresh
    pb.collection('items').subscribe('*', (e) {
      if (mounted) {
        _fetchItems();
      }
    });
  }

  /// Fetches the list of items that are ready for claim.
  Future<void> _fetchItems() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final resultList = await pb.collection('items').getList(
        filter: 'status="ready_for_claim"',
        sort: '-created',
      );
      if (mounted) {
        setState(() {
          _items = resultList.items;
        });
      }
    } catch (e) {
      print("Error fetching items: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reported Items"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchItems, // Allows pull-to-refresh
        child: _items.isEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "No items are currently waiting to be claimed. Pull down to refresh.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        )
            : ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            final imageUrl = pb.files.getUrl(item, item.data['feature_photo']).toString();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                )
                    : const Icon(Icons.image_not_supported),
                title: Text(item.data['title']),
                subtitle: Text("Found at: ${item.data['clusterId'] ?? 'Unknown'}"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ClaimItemPage(item: item),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
