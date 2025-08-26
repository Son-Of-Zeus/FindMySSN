// In lib/screens/report_item_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:findmyssn/services/item_service.dart';
import 'package:findmyssn/services/location_service.dart';
import 'package:findmyssn/utils/dialog_helper.dart';

class ReportItemPage extends StatefulWidget {
  const ReportItemPage({super.key});

  @override
  State<ReportItemPage> createState() => _ReportItemPageState();
}

class _ReportItemPageState extends State<ReportItemPage> {
  final _titleController = TextEditingController();
  // --- ADD THESE CONTROLLERS ---
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();

  final _itemService = ItemService();
  final _locationService = LocationService();
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }
  Future<void> _submitReport() async {
    // First, validate all the other fields
    if (_titleController.text.isEmpty || _image == null || _nameController.text.isEmpty || _contactController.text.isEmpty) {
      DialogHelper.showInfoDialog(
        context: context,
        title: "Incomplete Form",
        message: "Please fill all fields and select an image.",
        type: DialogType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Call the location service to get the location ID via the pop-up dialog.
    final clusterId = await _locationService.determineLocationCluster(context);

    // 2. If the user cancels the dialog, the clusterId will be null.
    //    In this case, we stop the submission process.
    if (clusterId == null) {
      setState(() => _isLoading = false);
      return;
    }

    // 3. If a location was successfully determined, proceed to report the item.
    await _itemService.reportItem(
      title: _titleController.text,
      image: _image!,
      name: _nameController.text.trim(),
      contact: _contactController.text.trim(),
      clusterId: clusterId, // Pass the ID here
    );

    if (mounted) {
      Navigator.of(context).pop();
      DialogHelper.showInfoDialog(
        context: context,
        title: "Report Submitted",
        message: "Your item report was successful! It is now being analyzed by our AI and will appear in the list shortly.",
        type: DialogType.success,
      );
    }

    setState(() => _isLoading = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report a Found Item")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ... (Title TextField remains the same)
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Item Title",
                hintText: "e.g., 'Black Nike Water Bottle'",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // --- ADD THESE NEW TEXTFIELDS ---
            Text("Your Details (for the owner to contact you)", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Your Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: "Your Contact Info (Email or Phone)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // ... (Image picker remains the same)
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _image == null
                  ? const Center(child: Text("Please select a feature photo"))
                  : Image.file(_image!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text("Select Photo"),
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submitReport,
                child: const Text("Submit Report"),
              ),
          ],
        ),
      ),
    );
  }
}

