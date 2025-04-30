import 'dart:io'; // Importing dart:io to handle file paths
import 'package:dressify_app/widgets/custom_button_3.dart'; // Importing custom button widget
import 'package:dressify_app/services/image_service.dart'; // Importing image service to handle image selection
import 'package:flutter/material.dart'; // Importing Flutter material package for UI components

/// ImagePickerContainer - A widget that allows the user to pick an image
/// either by taking a picture or uploading one from the gallery.
/// The selected image is displayed inside a container.
class ImagePickerContainer extends StatefulWidget {
  final Function(String?)? onImageSelected; // Callback to return the selected image path
  final String? initialImagePath; // Path or URL of the initially selected image (if any)

  const ImagePickerContainer({
    super.key,
    this.onImageSelected,
    this.initialImagePath,
  });

  @override
  State<ImagePickerContainer> createState() => _ImagePickerContainerState();
}

class _ImagePickerContainerState extends State<ImagePickerContainer> {
  String? _imagePath; // Store selected image path or URL
  final ImageService _imageService = ImageService(); // Instance of ImageService to handle image selection

  @override
  void initState() {
    super.initState();
    // Load the initial image path (if available)
    _imagePath = widget.initialImagePath;
  }

  /// Handles the process of picking an image either from the camera or gallery.
  /// [fromCamera] - If true, opens the camera; otherwise, opens the gallery.
  Future<void> _pickImage(bool fromCamera) async {
    final image = fromCamera
        ? await _imageService.takePicture(context) // Take a picture from the camera
        : await _imageService.uploadImage(context); // Pick an image from the gallery

    if (image != null) {
      setState(() {
        _imagePath = image.path; // Update the state with the new image path
      });

      // Send the selected image path back to the parent widget (AddItemScreen)
      if (widget.onImageSelected != null) {
        widget.onImageSelected!(_imagePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to ensure a responsive UI
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      // Open the bottom sheet to allow image selection when tapped
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          builder: (BuildContext context) {
            return SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Button to take a picture from the camera
                      CustomButton3(
                        label: "Take Picture",
                        onPressed: () async {
                          Navigator.pop(context); // Close the bottom sheet
                          await _pickImage(true); // Capture image from camera
                        },
                      ),
                      const SizedBox(height: 12),

                      // Button to upload an image from the gallery
                      CustomButton3(
                        label: "Upload Image",
                        onPressed: () async {
                          Navigator.pop(context); // Close the bottom sheet
                          await _pickImage(false); // Pick image from gallery
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },

      // Container to display the selected or initial image
      child: Center(
        child: Container(
          width: screenWidth * 0.75,
          height: screenHeight * 0.3,
          decoration: BoxDecoration(
            color: Colors.white, // Background color when no image is selected
            borderRadius: BorderRadius.circular(12), // Rounded corners
            border: Border.all(color: Colors.black45), // Border with light gray color

            // If an image is selected or URL is provided, display it in the container
            image: _imagePath != null
                ? (_imagePath!.startsWith('http') // Check if the path is a URL
                    ? DecorationImage(
                        image: NetworkImage(_imagePath!), // Load image from network URL
                        fit: BoxFit.contain,
                      )
                    : DecorationImage(
                        image: FileImage(File(_imagePath!)), // Load image from local file
                        fit: BoxFit.contain,
                      ))
                : null, // No image displayed if no path is available
          ),

          // Show a camera icon if no image is selected
          child: _imagePath == null
              ? const Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: Colors.black45, // Default color for the icon
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
