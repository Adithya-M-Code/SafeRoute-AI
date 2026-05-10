import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseService.storage;

  Future<String?> uploadImage(File imageFile) async {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      debugPrint('\n' + '=' * 60);
      debugPrint('📤 IMAGE UPLOAD STARTED');
      debugPrint('📤 Filename: $fileName');
      debugPrint('📤 Platform: ${kIsWeb ? 'WEB' : 'NATIVE'}');
      debugPrint('=' * 60 + '\n');

      debugPrint('📁 Checking file...');

      // Prepare metadata
      final SettableMetadata metadata = SettableMetadata(
        cacheControl: 'public, max-age=31536000',
        contentType: 'image/jpeg',
      );

      // Upload to Firebase Storage
      debugPrint('🚀 Uploading to: hazard_images/$fileName.jpg');
      final Reference ref = _storage.ref().child('hazard_images/$fileName.jpg');

      UploadTask task;

      if (kIsWeb) {
        // Web platform: need to read bytes using XFile
        debugPrint('⚠️  Web platform - uploading via putData with XFile');
        try {
          // On web, the File path is actually a blob URL, so we use XFile to read it
          final XFile xFile = XFile(imageFile.path);
          final bytes = await xFile.readAsBytes();
          debugPrint('📁 File size: ${bytes.length} bytes');

          if (bytes.isEmpty) {
            throw Exception('File is empty (0 bytes)');
          }

          task = ref.putData(bytes, metadata);
        } catch (e) {
          debugPrint('❌ Failed to read file bytes on web: $e');
          rethrow;
        }
      } else {
        // Native platform: use putFile directly
        debugPrint('📱 Native platform - uploading via putFile');
        if (!imageFile.existsSync()) {
          throw Exception('File not found: ${imageFile.path}');
        }

        final int fileSize = imageFile.lengthSync();
        debugPrint('📁 File size: $fileSize bytes');

        if (fileSize == 0) {
          throw Exception('File is empty (0 bytes)');
        }

        task = ref.putFile(imageFile, metadata);
      }

      // Listen to upload progress
      task.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress =
              ((snapshot.bytesTransferred / snapshot.totalBytes) * 100)
                  .toStringAsFixed(1);
          debugPrint('📊 Progress: $progress%');
        },
        onError: (Object error) {
          debugPrint('❌ Upload stream error: $error');
        },
      );

      // Wait for upload to complete
      debugPrint('⏳ Waiting for upload to complete...');
      try {
        await task;
        debugPrint('✅ Upload completed');
      } catch (uploadError) {
        debugPrint('❌ Upload failed during task: $uploadError');
        rethrow;
      }

      // Get download URL
      debugPrint('🔗 Retrieving download URL...');
      final String downloadUrl = await ref.getDownloadURL();

      debugPrint('\n' + '=' * 60);
      debugPrint('✅ IMAGE UPLOAD SUCCESS');
      debugPrint('✅ URL: $downloadUrl');
      debugPrint('=' * 60 + '\n');

      return downloadUrl;
    } catch (e) {
      debugPrint('\n' + '=' * 60);
      debugPrint('❌ IMAGE UPLOAD FAILED');
      debugPrint('❌ Error: $e');
      debugPrint('❌ Type: ${e.runtimeType}');

      if (e is FirebaseException) {
        debugPrint('❌ Firebase Code: ${e.code}');
        debugPrint('❌ Firebase Message: ${e.message}');
      }
      debugPrint('=' * 60 + '\n');

      // Don't rethrow - return null to allow optional image upload
      return null;
    }
  }
}
