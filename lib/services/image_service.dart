import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A service to handle image operations such as taking pictures and uploading images.
class ImageService {
  // Create an instance of ImagePicker to pick images from camera or gallery
  final ImagePicker _picker = ImagePicker();

  /// Function to take a picture using the device's camera
  ///
  /// - [context] is the current BuildContext (optional but useful for future improvements)
  /// - Returns an `XFile` containing the image or `null` if an error occurs or the user cancels.
  Future<XFile?> takePicture(BuildContext context) async {
    try {
      // Use the camera to take a picture
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera, // Set the source to camera
        maxWidth: 800, // Optional: Resize image width to 800 pixels
        maxHeight: 800, // Optional: Resize image height to 800 pixels
      );

      // Check if the image was successfully taken
      if (image != null) {
        print("Picture taken: ${image.path}"); // Log the image path
      }
      return image; // Return the image file or null if canceled
    } catch (e) {
      // Handle errors that may occur while taking the picture
      print("Error taking picture: $e");
      return null; // Return null on error
    }
  }

  /// Function to upload an image from the device's gallery
  ///
  /// - [context] is the current BuildContext (optional but useful for future improvements)
  /// - Returns an `XFile` containing the selected image or `null` if an error occurs or the user cancels.
  Future<XFile?> uploadImage(BuildContext context) async {
    try {
      // Open the gallery to pick an image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, // Set the source to gallery
        maxWidth: 800, // Optional: Resize image width to 800 pixels
        maxHeight: 800, // Optional: Resize image height to 800 pixels
      );

      // Check if the image was successfully selected
      if (image != null) {
        print("Image selected: ${image.path}"); // Log the selected image path
      }
      return image; // Return the selected image file or null if canceled
    } catch (e) {
      // Handle errors that may occur while selecting an image
      print("Error selecting image: $e");
      return null; // Return null on error
    }
  }
}
