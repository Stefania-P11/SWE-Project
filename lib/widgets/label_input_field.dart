import 'package:flutter/material.dart';

/// A custom input field widget to allow the user to add a name or label.
/// It takes a [TextEditingController] to manage the text input and
/// a [hintText] to provide placeholder guidance to the user.

class LabelInputField extends StatelessWidget {
  // Controller to manage the value of the text field
  final TextEditingController controller;

  // Hint text to be displayed inside the text field when it's empty
  final String hintText;

  // Constructor to initialize the controller and hintText with required arguments.
  const LabelInputField({
    super.key,
    required this.controller,
    this.hintText = "", // Default hint if not provided
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Add padding around the input field
      padding: const EdgeInsets.symmetric(horizontal: 16.0),

      // The actual text input field
      child: TextField(
        // Attach the controller to the TextField
        controller: controller,

        // Limit the input to 15 characters
        maxLength: 15,

        // Define the appearance and behavior of the input field
        decoration: InputDecoration(
          // Use the passed hintText or the default one
          hintText: hintText,

          // Default border when the TextField is not focused
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12.0), // Rounded border with 12px radius
            ),
          ),

          // Border when the TextField is not focused
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12.0),
            ),
            borderSide: BorderSide(
              color: Colors.black, // Border color when not focused
              width: 1.0, // Border thickness
            ),
          ),

          // Border when the TextField is focused
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12.0), // Rounded border with 12px radius
            ),
          ),
        ),
      ),
    );
  }
}
