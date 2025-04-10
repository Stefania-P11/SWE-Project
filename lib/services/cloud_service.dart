import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

class CloudService {
  /// Uploads a compressed image to Firebase Storage and returns its URL.
  Future<String?> uploadImageToFirebase(XFile imageFile) async {
    try {
      // Compress the image
      final Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 800,
        minHeight: 800,
        quality: 75, // Adjust quality if needed
      );

      if (compressedImage == null) {
        print("Image compression failed");
        return null;
      }

      // Generate a unique file name
      final fileName = path.basename(imageFile.path);
      final storageRef = FirebaseStorage.instance.ref().child('images/$fileName');

      // Upload compressed image bytes
      final uploadTask = await storageRef.putData(compressedImage);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print("Upload successful: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }
}
