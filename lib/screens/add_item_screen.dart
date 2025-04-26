import 'package:dressify_app/constants.dart'; // Import constants for text styles and colors
import 'package:dressify_app/models/item.dart'; // Import Item model to populate and save item data
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Import custom app bar for navigation
import 'package:dressify_app/widgets/custom_button_3.dart'; // Import button with active/inactive state
import 'package:dressify_app/widgets/image_picker.dart'; // Import custom image picker widget
import 'package:flutter/material.dart';
import 'package:dressify_app/services/firebase_service.dart'; 
import 'package:dressify_app/services/cloud_service.dart';
import 'package:image_picker/image_picker.dart';

/// AddItemScreen - Allows the user to add, view, and update a clothing item.
class AddItemScreen extends StatefulWidget {
  final Item? item; // If an item is passed, screen opens in view mode

  const AddItemScreen({super.key, this.item});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // Controller to manage input for item name
  final TextEditingController _nameController = TextEditingController();

  // Selected category and list of available categories
  String selectedCategory = '';
  List<String> categories = ['Top', 'Bottom', 'Shoes'];

  // Selected temperatures and list of available temperature options
  List<String> selectedTemperatures = [];
  List<String> temperatures = ['Hot', 'Warm', 'Cool', 'Cold'];

  // Path to the selected image (if any) or URL from Firestore
  String? _imagePath;

  late bool isViewMode = true; // Start in view mode by default

  @override
  void initState() {
    super.initState();

    // Determine if the screen should be in view mode or edit mode
    isViewMode = widget.item != null;

    // Pre-populate fields if an item is passed for editing/viewing
    if (widget.item != null) {
      _nameController.text = widget.item!.label;

      // Assign category if it matches one of the available options
      if (categories.contains(widget.item!.category)) {
        selectedCategory = widget.item!.category;
      }

      // Assign temperature preferences
      selectedTemperatures = List<String>.from(widget.item!.weather);

      // Load image URL from Firestore if available
      _imagePath = widget.item!.url;
    }

    // Add a listener to update button state when text field changes
    _nameController.addListener(_updateButtonState);
  }


void _handleSaveOrUpdate() async {
  // Show a loading spinner while the save process is happening
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    String? imageUrl = _imagePath;

    // Upload image to Firebase Storage only if it's not already a URL (i.e., it's a local file)
    if (_imagePath != null && !_imagePath!.startsWith('http')) {
      final file = XFile(_imagePath!);
      imageUrl = await CloudService().uploadImageToFirebase(file);

      // If image upload fails, exit early and show error message
      if (imageUrl == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image upload failed.")),
        );
        return;
      }
    }

    // Create a new Item object (either a new item or updated one)
    final item = Item(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch, // Use existing ID if editing, or generate a new one
      label: _nameController.text,
      category: selectedCategory,
      weather: selectedTemperatures,
      url: imageUrl!, // Must be non-null at this point
      timesWorn: widget.item?.timesWorn ?? 0, // Keep original value if editing, or start from 0 if new
    );

    // Save item depending on whether it's new or being updated
    if (widget.item == null) {
      // Save new item to Firestore
      await FirebaseService.addFirestoreItem(item);
    } else {
      // Update item in Firestore
      await FirebaseService.editFirestoreItemDetails(
        item,
        item.label,
        item.category,
        item.weather,
      );

      // Also update item locally in the in-memory list
      FirebaseService.editLocalItemDetails(
        widget.item!,
        item.label,
        item.category,
        item.weather,
      );
    }

    // Close loading dialog and pop screen with success flag
    Navigator.pop(context);
    Navigator.pop(context, true);

  } catch (e) {
    // On error, close dialog and show error message
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}


  /// Switches to Edit Mode when the edit icon is clicked
  void _switchToEditMode() {
    setState(() {
      isViewMode = false; // Switch to edit mode
    });
  }

  /// Updates the button state when the name input changes
  void _updateButtonState() {
    setState(() {});
  }

  /// Updates the selected image path
  void _updateImage(String? imagePath) {
    setState(() {
      _imagePath = imagePath; // Update the selected image path
    });
  }

  void _handleDeleteItem() async {
  if (widget.item != null) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Step 1: Delete from Firestore (using existing method)
        await FirebaseService.removeFirestoreItem(widget.item!);
        
        // Step 2: Delete locally (using existing method)
        FirebaseService.removeLocalItem(widget.item!);
        
        // Step 3: (Optional) Add storage cleanup if needed
        // await FirebaseStorage.instance.refFromURL(widget.item!.url).delete();
        
        if (mounted) Navigator.pop(context, true); // Close screen + refresh parent
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Deletion failed: ${e.toString()}")),
          );
        }
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to ensure responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBackgroundColor,

      // Custom App Bar with back button and optional edit/delete icons
      appBar: CustomAppBar(
        showBackButton: true,
        isViewMode: isViewMode,
        onEditPressed: _switchToEditMode, // Pass callback to enable edit mode
        onDeletePressed: _handleDeleteItem, // 
      ),

      // Body of the Add Item Screen
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: SingleChildScrollView(
                  // Allows scrolling if the content overflows
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add spacing at the top
                      SizedBox(height: screenHeight * 0.02),
        
                      // Show different titles based on mode
                      SizedBox(
                        child: !isViewMode
                            ? (widget.item != null
                                ? Text(
                                    "Update Item", // Show this title when in edit mode
                                    style: kH2.copyWith(color: Colors.black),
                                  )
                                : Text(
                                    "Adding New Item", // Show this title when adding a new item
                                    style: kH2.copyWith(color: Colors.black),
                                  ))
                            : Text(
                                "Item Details", // Show this title when viewing an item
                                style: kH2.copyWith(color: Colors.black),
                              ),
                      ),
        
                      // Add spacing below the title
                      SizedBox(height: screenHeight * 0.02),
        
                      // Image Picker container that opens a prompt for choosing from camera/gallery
                      Center(
                        child: GestureDetector(
                          onTap: isViewMode
                              ? null // Disable image selection in View Mode
                              : () => _updateImage(_imagePath),
                          child: ImagePickerContainer(
                            onImageSelected: _updateImage,
                            initialImagePath: _imagePath,
                          ),
                        ),
                      ),
        
                      // Add spacing below image picker
                      SizedBox(height: screenHeight * 0.01),
        
                      // Label for name input
                      Text("Name", style: kH3.copyWith(color: Colors.black)),
        
                      SizedBox(height: screenHeight * 0.01),
        
                      // TextField for entering item name (max length: 15 characters)
                      TextField(
                        controller: _nameController,
                        maxLength: 15,
                        enabled: !isViewMode, // Disable in View Mode
                        decoration: const InputDecoration(
                          hintText: "e.g. Old Navy Crewneck",
                          border: OutlineInputBorder(),
                        ),
                      ),
        
              
        
                      // Label for category selection
                      Text("Category", style: kH3.copyWith(color: Colors.black)),
        
                      SizedBox(height: screenHeight * 0.01),
        
                      // Wrap to display category selection buttons horizontally
                      Wrap(
                        spacing: 6, // Space between buttons
                        children: categories
                            .map(
                              (category) => IntrinsicWidth(
                                child: Opacity(
                                  opacity: isViewMode ? 0.9 : 1.0, // Dim in view mode
                                  child: ChoiceChip(
                                    label: Center(
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: selectedCategory == category
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    selected: selectedCategory == category,
                                    onSelected: isViewMode
                                        ? null // Disable selection in view mode
                                        : (selected) {
                                            setState(
                                                () => selectedCategory = category);
                                          },
                                    selectedColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    showCheckmark:
                                        false, // Prevent checkmark from appearing
                                    visualDensity:
                                        VisualDensity.compact, // Consistent height
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
        
                      // Add spacing below category buttons
                      SizedBox(height: screenHeight * 0.02),
        
                      // Label for temperature selection
                      Text("Temperature", style: kH3.copyWith(color: Colors.black)),
        
                      SizedBox(height: screenHeight * 0.01),

                      // Wrap to display temperature selection buttons horizontally
                      Wrap(
                        spacing: 6, // Space between buttons
                        children: temperatures
                            .map(
                              (temp) => IntrinsicWidth(
                                child: Opacity(
                                  opacity: isViewMode ? 0.9 : 1.0, // Dim in view mode
                                  child: ChoiceChip(
                                    label: Center(
                                      child: Text(
                                        temp,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: selectedTemperatures.contains(temp)
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    selected: selectedTemperatures.contains(temp),
                                    onSelected: isViewMode
                                        ? null // Disable selection in view mode
                                        : (selected) {
                                            setState(() {
                                              if (selected) {
                                                selectedTemperatures.add(temp);
                                              } else {
                                                selectedTemperatures.remove(temp);
                                              }
                                            });
                                          },
                                    selectedColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    showCheckmark: false,
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
        
                      // Add spacing before Save and Cancel buttons
                      SizedBox(height: screenHeight * 0.03),
        
                      // Show Save/Cancel buttons only in Edit Mode
                      Visibility(
                        visible: !isViewMode, // Hide buttons in View Mode
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Save Button
                            CustomButton3(
                              isActive: selectedCategory.isNotEmpty &&
                                  selectedTemperatures.isNotEmpty &&
                                  _nameController.text.isNotEmpty &&
                                  _imagePath != null,
                              label: widget.item == null ? "SAVE" : "UPDATE",
                              onPressed: () {
                                if (selectedCategory.isNotEmpty &&
                                    selectedTemperatures.isNotEmpty &&
                                    _nameController.text.isNotEmpty &&
                                    _imagePath != null) {
                                  _handleSaveOrUpdate(); // Save or update logic
                                }
                              },
                            ),
                            // Cancel Button
                            CustomButton3(
                              label: "CANCEL",
                              onPressed: () {
                                setState(() {
                                  _nameController.clear();
                                  selectedCategory =
                                      ''; // Clear category selection
                                  selectedTemperatures
                                      .clear(); // Clear temperature selection
                                  _imagePath = null; // Clear the image path
                                });
        
                                // Return to the previous screen
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
        
                      // Add extra space below buttons
                      SizedBox(height: screenHeight * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//TODO: Fix the image display container-- some items appear cropped