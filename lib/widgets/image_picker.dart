import 'dart:io';

import 'package:dressify_app/constants.dart';
import 'package:dressify_app/widgets/custom_button_3.dart';
import 'package:dressify_app/services/image_service.dart';
import 'package:flutter/material.dart';

class ImagePickerContainer extends StatefulWidget {
  final Function(String?)? onImageSelected; // Callback to send image path
  final String? initialImagePath; // To display the selected image initially

  const ImagePickerContainer({
    super.key,
    this.onImageSelected,
    this.initialImagePath,
  });

  @override
  State<ImagePickerContainer> createState() => _ImagePickerContainerState();
}

class _ImagePickerContainerState extends State<ImagePickerContainer> {
  String? _imagePath; // Store selected image path
  final ImageService _imageService = ImageService(); // Create instance of ImageService

  // Method to update selected image
  Future<void> _pickImage(bool fromCamera) async {
    final image = fromCamera
        ? await _imageService.takePicture(context) // Take picture from camera
        : await _imageService.uploadImage(context); // Pick image from gallery

    if (image != null) {
      setState(() {
        _imagePath = image.path; // Update state with image path
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
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
                      // Take Picture Button
                      CustomButton3(
                        label: "Take Picture",
                        onPressed: () async {
                          Navigator.pop(context);
                          await _pickImage(true); // Take Picture
                        },
                      ),
                      const SizedBox(height: 12),

                      // Upload Image Button
                      CustomButton3(
                        label: "Upload Image",
                        onPressed: () async {
                          Navigator.pop(context);
                          await _pickImage(false); // Upload Image
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
      child: Center(
        child: Container(
          width: screenWidth * 0.75,
          height: screenHeight * 0.3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black45),
            image: _imagePath != null
                ? DecorationImage(
                    image: FileImage(
                      File(_imagePath!), // Show selected image
                    ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _imagePath == null
              ? const Center(
                  child: Icon(Icons.camera_alt, size: 50, color: Colors.black45),
                )
              : null,
        ),
      ),
    );
  }
}
