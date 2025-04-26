import 'package:dressify_app/constants.dart';
import 'package:dressify_app/screens/landing_screen.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:dressify_app/services/authentication_service.dart';
import 'change_password_screen.dart'; 

/// ProfileSettingsScreen displays the user's profile settings options.
/// Shows the username at the top and allows changing password or logging out.
class ProfileSettingsScreen extends StatelessWidget {
  final String username; // Username to display

  const ProfileSettingsScreen({Key? key, required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for layout
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 246, 246), // Light gray background
      appBar: CustomAppBar(
        showBackButton: true, // Show back button in app bar
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding
        children: [
          SizedBox(height: screenHeight * 0.03), // Top spacing

          // Username centered at the top
          Align(
            alignment: Alignment.center,
            child: Text(
              "@$username",
              style: kH2.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),

          SizedBox(height: screenHeight * 0.04), // Spacing below username

          // Container for settings options
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // White card background
              borderRadius: BorderRadius.circular(16), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black12, // Subtle shadow
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Change Password option
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200, // Icon background
                    child: Icon(Icons.lock_outline, color: Colors.black), // Lock icon
                  ),
                  title: Text('Change Password',
                      style: kH3.copyWith(color: Colors.black)),
                  trailing: const Icon(Icons.chevron_right), // Chevron icon
                  onTap: () {
                    // Navigate to Change Password screen without animation
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const ChangePasswordScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),

                Divider(height: 1, thickness: 0.5), // Divider line

                // Log Out option
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kBackgroundColor, // Icon background
                    child: Icon(Icons.logout, color: Colors.black), // Logout icon
                  ),
                  title: Text('Log Out', style: kH3.copyWith(color: Colors.black)),
                  onTap: () async {
                    // Show confirmation dialog before logging out
                    final confirm = await showDialog<bool>(
                      context: context,
                      barrierColor: Colors.black.withOpacity(0.5), // Dark overlay
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Rounded dialog
                        ),
                        backgroundColor: const Color(0xFFF7F7F7), // Dialog background
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              // Dialog message
                              Text(
                                'Are you sure you want to log out?',
                                textAlign: TextAlign.center,
                                style: kH3.copyWith(color: Colors.black87),
                              ),
                              const SizedBox(height: 20),
                              // Dialog buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Cancel button
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                      'Cancel',
                                      style: kH3.copyWith(color: Colors.black),
                                    ),
                                  ),
                                  // Confirm log out button
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      'Log Out',
                                      style: kH3.copyWith(
                                          color: Color.fromARGB(255, 195, 15, 3)), // Accent color
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );

                    // Handle user confirmation
                    if (confirm == true) {
                      await AuthenticationService().signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const LandingScreen()),
                        (route) => false, // Clear all previous routes
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavBar(), 
    );
  }
}
