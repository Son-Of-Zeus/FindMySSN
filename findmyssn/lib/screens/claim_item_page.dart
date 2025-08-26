import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:findmyssn/screens/claim_success_page.dart';
import 'package:findmyssn/services/pocketbase_service.dart';
import 'package:findmyssn/utils/dialog_helper.dart';


class ClaimItemPage extends StatefulWidget {
  final RecordModel item;

  const ClaimItemPage({super.key, required this.item});

  @override
  State<ClaimItemPage> createState() => _ClaimItemPageState();
}

class _ClaimItemPageState extends State<ClaimItemPage> {
  final _answerController = TextEditingController();
  bool _isLoading = false;

  /// Submits the claim for the item.
  ///
  /// This function performs the following steps:
  /// 1. Fetches the full item record to get the private answer and finder's ID.
  /// 2. Compares the user's provided answer with the correct answer.
  /// 3. If correct, it fetches the finder's user record for their contact details.
  /// 4. Updates the item's status to "claimed".
  /// 5. Navigates to the ClaimSuccessPage with all the necessary details.
  /// 6. If incorrect, it shows a SnackBar error message.
  Future<void> _submitClaim() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final pb = PocketBaseService.pb;
    final providedAnswer = _answerController.text.trim();

    try {
      // 1. Fetch the latest version of the item to get the private_answer and the finder's user ID.
      final itemRecord = await pb.collection('items').getOne(widget.item.id);
      final correctAnswer = itemRecord.data['private_answer'];
      final finderId = itemRecord.data['finder'];

      // 2. Compare the provided answer with the correct answer (case-insensitive).
      if (providedAnswer.toLowerCase() == correctAnswer.toLowerCase()) {
        // 3. If correct, fetch the finder's user record to get their name and contact info.
        final finderRecord = await pb.collection('users').getOne(finderId);
        // Safely access the name and contact, providing defaults if they are null.
        final finderName = finderRecord.data['name'] ?? 'Not Provided';
        final finderContact = finderRecord.data['contact'] ?? finderRecord.data['email'];

        // 4. Update the item's status to 'claimed' and record who claimed it.
        await pb.collection('items').update(widget.item.id, body: {
          'status': 'claimed',
          'claimer': pb.authStore.model.id,
        });

        // 5. Navigate to the success page, replacing the current page.
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ClaimSuccessPage(
                claimedItem: itemRecord,
                finderName: finderName,
                finderContact: finderContact,
              ),
            ),
          );
        }
      } else {
        // If incorrect, show an error message.
        if (mounted) {
          DialogHelper.showInfoDialog(
            context: context,
            title: "Incorrect Answer",
            message: "The answer you provided is incorrect. Please try again.",
            type: DialogType.error,
          );

        }
      }
    } catch (e) {
      print("Error submitting claim: $e");
      if (mounted) {
        DialogHelper.showInfoDialog(
          context: context,
          title: "Submission Error",
          message: "An unexpected error occurred. Could not submit your claim.",
          type: DialogType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely extract the public question text from the JSON field.
    final publicQuestion = widget.item.data['public_question']?['text'] ?? "No security question available.";

    return Scaffold(
      appBar: AppBar(title: Text("Claim: ${widget.item.data['title']}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "To prove this item belongs to you, please answer the following question:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                publicQuestion,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: "Your Answer",
                hintText: "Enter the secret answer here",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submitClaim,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Submit Claim"),
              ),
          ],
        ),
      ),
    );
  }
}
