import 'package:dressify_app/constants.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:dressify_app/services/authentication_service.dart';
import 'change_password_screen.dart'; // Next screen to navigate to

/// ProfileSettingsScreen displays the user's profile settings options.
/// Shows the username at the top and settings like Change Password and Log Out.
class ProfileSettingsScreen extends StatelessWidget {
  final String username;

  const ProfileSettingsScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 246, 246), // Light gray background color
      appBar: CustomAppBar(
        showBackButton: true, // Display back button
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          SizedBox(height: screenHeight * 0.03),

          // Username centered at the top
          Align(
            alignment: Alignment.center,
            child: Text(
              "@$username",
              style: kH2.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),

          SizedBox(height: screenHeight * 0.04),

          // Settings card with options
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
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
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(Icons.lock_outline, color: Colors.black),
                  ),
                  title: Text('Change Password', style: kH3.copyWith(color: Colors.black)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const ChangePasswordScreen(),
    transitionDuration: Duration.zero, // No animation duration
    reverseTransitionDuration: Duration.zero, // No reverse animation
  ),
);
                  },
                ),
                Divider(height: 1, thickness: 0.5),

                // Log Out option
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kBackgroundColor,
                    child: Icon(Icons.logout, color: Colors.black),
                  ),
                  title: Text('Log Out', style: kH3.copyWith(color: Colors.black)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await AuthenticationService().signOut();
                    // TODO: Navigate to login or landing page after logout
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
