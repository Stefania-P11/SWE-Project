import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:dressify_app/constants.dart';
import 'package:dressify_app/services/authentication_service.dart';
import 'package:dressify_app/widgets/label_input_field.dart';
import 'package:dressify_app/widgets/custom_button.dart';

/// Screen that allows users to change their account password
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Text controllers for password fields
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();

  // State variables to track validation and loading
  bool passwordValid = false;
  bool passwordsMatch = false;
  bool isLoading = false;

  // Authentication service instance
  final AuthenticationService _authService = AuthenticationService();

  @override
  void initState() {
    super.initState();
    // Add listeners to password fields to validate inputs in real time
    _newPasswordController.addListener(_validatePasswords);
    _retypePasswordController.addListener(_validatePasswords);
  }

  /// Validates password strength and match between new passwords
  void _validatePasswords() {
    final newPassword = _newPasswordController.text;
    final retypePassword = _retypePasswordController.text;

    setState(() {
      passwordValid = _authService.validatePassword(newPassword);
      passwordsMatch = newPassword == retypePassword;
    });
  }

  /// Handles changing the user's password
  Future<void> _handleChangePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final retypePassword = _retypePasswordController.text.trim();

    // Validation: passwords must match
    if (newPassword != retypePassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }

    // Validation: password strength
    if (!_authService.validatePassword(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password does not meet requirements.')),
      );
      return;
    }

    setState(() => isLoading = true);

    // Attempt to change password using AuthenticationService
    final bool error = await _authService.setNewPassword(currentPassword, newPassword);

    setState(() => isLoading = false);

    if (error) {
      // Password successfully changed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.pop(context, true); // Navigate back after success
      }
    } else {
      // Show specific error message if password change failed
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Password update failed.')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: CustomAppBar(
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),

            // Screen title
            Text(
              "Create New Password",
              style: kH2.copyWith(color: Colors.black),
            ),

            SizedBox(height: screenHeight * 0.04),

            // Current Password field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Text('Current Password:', style: kH3),
                ),
                const SizedBox(height: 10),
                LabelInputField(
                  controller: _currentPasswordController,
                  hintText: "Enter your current password",
                  obscureText: true,
                  maxLength: 50,
                  showCounter: false,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // New Password field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Text('New Password:', style: kH3),
                ),
                const SizedBox(height: 10),
                LabelInputField(
                  controller: _newPasswordController,
                  hintText: "Enter your new password",
                  obscureText: true,
                  maxLength: 50,
                  showCounter: false,
                ),
                // Error message for password strength
                if (!passwordValid && _newPasswordController.text.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 20.0, right: 14.0),
                    child: Text(
                      'Password must have:\n• Minimum 8 characters\n• At least one uppercase letter (A-Z)\n• At least one digit (0-9)',
                      style: kErrorMessage,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            // Re-Enter New Password field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Text('Re-Enter New Password:', style: kH3),
                ),
                const SizedBox(height: 10),
                LabelInputField(
                  controller: _retypePasswordController,
                  hintText: "Re-type your new password",
                  obscureText: true,
                  maxLength: 50,
                  showCounter: false,
                ),
                // Error message for password mismatch
                if (!passwordsMatch && _retypePasswordController.text.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 20.0, right: 14.0),
                    child: Text(
                      'Passwords do not match.',
                      style: kErrorMessage,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 60),

      

            // Update Password button
            SizedBox(
              width: screenWidth * 0.6,
              child: CustomButton(
                text: isLoading ? "Updating..." : "Update Password",
                onPressed: () {
                  if (!isLoading) {
                    _handleChangePassword();
                  }
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
