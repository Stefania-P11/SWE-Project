import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Function to take a picture
  Future<XFile?> takePicture(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800, // Optional: Resize the image
        maxHeight: 800,
      );

      if (image != null) {
        print("Picture taken: ${image.path}");
      }
      return image;
    } catch (e) {
      print("Error taking picture: $e");
      return null;
    }
  }

  // Function to upload an image from gallery
  Future<XFile?> uploadImage(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Optional: Resize the image
        maxHeight: 800,
      );

      if (image != null) {
        print("Image selected: ${image.path}");
      }
      return image;
    } catch (e) {
      print("Error selecting image: $e");
      return null;
    }
  }
}
