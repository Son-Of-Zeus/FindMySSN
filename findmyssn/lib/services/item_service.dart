// In lib/services/item_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:findmyssn/services/pocketbase_service.dart';

class ItemService {
  static const _geminiApiKey = '';

  Future<void> reportItem({
    required String title,
    required File image,
    // --- ADD THESE PARAMETERS ---
    required String name,
    required String contact,
    required String? clusterId,
  }) async {
    final pb = PocketBaseService.pb;

    // --- NEW STEP: UPDATE THE FINDER'S (CURRENT USER'S) DETAILS ---
    // Before creating the item, update the current user's profile with
    // the name and contact info they just provided.
    final userId = pb.authStore.model.id;
    await pb.collection('users').update(userId, body: {
      'name': name,
      'contact': contact,
    });

    // Create the item record (no changes here)
    final itemRecord = await pb.collection('items').create(body: {
      'title': title,
      'finder': userId,
      'status': 'processing_ai',
      'clusterId' : clusterId,
      // We removed the clusterId for simplicity in the last step
    });

    // ... (The rest of the method for uploading photo and Gemini analysis is the same)
    final updatedRecord = await pb.collection('items').update(itemRecord.id, files: [
      await http.MultipartFile.fromPath('feature_photo', image.path),
    ]);

    final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: _geminiApiKey);
    final prompt = TextPart(
        "Analyze this image of a unique feature on a lost item. "
            "Your task is to act as a security system. Identify the single most verifiable feature in the image. "
            "Then, formulate a simple question to ask the owner to prove it's theirs. "
            "Finally, provide a short, keyword-based answer for that question. "
            "Return ONLY a JSON object with two keys: 'question' and 'private_answer'. "
    );

    final imageBytes = await image.readAsBytes();
    final content = [Content.multi([prompt, DataPart('image/jpeg', imageBytes)])];
    final response = await model.generateContent(content);

    try {
      String rawResponse = response.text ?? "";
      String cleanedResponse = rawResponse
          .replaceAll("```json", "") // Find and remove the starting ```
          .replaceAll("```", "")     // Find and remove the closing ```
          .trim();

          final jsonResponse = jsonDecode(cleanedResponse);
      final questionText = jsonResponse['question'];
      final privateAnswer = jsonResponse['private_answer'];

      await pb.collection('items').update(itemRecord.id, body: {
        'public_question': {'text': questionText},
        'private_answer': privateAnswer,
        'status': 'ready_for_claim',
      });
    } catch (e) {
      print("Error parsing Gemini response: $e");
      await pb.collection('items').update(itemRecord.id, body: {'status': 'ai_error'});
    }
  }
}

