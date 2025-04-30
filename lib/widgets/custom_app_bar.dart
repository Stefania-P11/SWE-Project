import 'dart:ui'; // Importing dart:ui for drawing and rendering

import 'package:dressify_app/screens/profile_settings_screen.dart';
import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import '../constants.dart'; // Importing constants for styles and colors
import 'package:flutter_svg/flutter_svg.dart'; // Importing SVG package to load vector icons

/// CustomAppBar - A reusable app bar widget for navigation and actions.
/// This app bar supports a back button, menu icon, edit and delete icons in view mode,
/// and profile navigation.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton; // Flag to show/hide the back button
  final bool isViewMode; // Flag to determine if view mode is active
  final VoidCallback? onEditPressed; // Callback to trigger edit mode
  final bool showEditIcon; // Flag to show/hide the edit button
  final bool showDeleteIcon; // Flag to show/hide the delete button
  final VoidCallback? onDeletePressed;
  final bool showGridViewIcon; // Flag to show/hide the Grid View button
  final VoidCallback? onGridViewPressed;

  /// Constructor to initialize [showBackButton], [isViewMode], and [onEditPressed].
  /// Defaults:
  /// - [showBackButton] is false by default.
  /// - [isViewMode] is false by default.
  /// - [onEditPressed] is null by default.
  const CustomAppBar({
    super.key,
    this.showBackButton = false,
    this.isViewMode = false,
    this.onEditPressed,
    this.showEditIcon = true,
    this.showDeleteIcon = true,
    this.onDeletePressed,
    this.showGridViewIcon = false,
    this.onGridViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kappBarColor, // Set app bar background color
      title: SvgPicture.asset(
          "lib/assets/icons/Logo_type.svg"), // Display the logo in the center

      // Show back button if [showBackButton] is true, otherwise show menu icon
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.chevron_left,
                  color: Colors.black, size: 40), // Back button
              onPressed: () =>
                  Navigator.pop(context), // Navigate back when pressed
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(Icons.menu), // Display menu icon
            ),

      // Right-side icons in the app bar
      actions: [
        // Show edit and delete icons only when [isViewMode] is true
        if (isViewMode) ...[
          if (showGridViewIcon)
            IconButton(
              icon: const Icon(Icons.grid_view,
                  color: Colors.black), // Trash icon (red)
              onPressed: onGridViewPressed, // Trigger delete
            ),
          if (showEditIcon)
            // Edit button to switch to edit mode
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black), // Edit icon
              onPressed: onEditPressed, // Trigger edit mode when pressed
            ),
          // Delete button to remove item
          if (showDeleteIcon)
            IconButton(
              icon: const Icon(Icons.delete,
                  color: Colors.red), // Trash icon (red)
              onPressed: onDeletePressed, // Trigger delete
            ),
        ],

        // Profile button on the right side
IconButton(
  onPressed: () {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProfileSettingsScreen(username: kUsername),
        transitionDuration: Duration.zero, // No animation
        reverseTransitionDuration: Duration.zero, // No animation when going back
      ),
    );
  },
  icon: const Icon(Icons.account_circle_rounded, color: Colors.black),
),
      ],

      // Bottom black line below the app bar for a subtle separator
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.black,
          height: 1.0,
        ),
      ),
    );
  }

  // Define preferred size for the app bar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
