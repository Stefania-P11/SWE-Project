import 'package:dressify_app/constants.dart'; // Import constants for text styles and colors
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Import custom app bar
import 'package:dressify_app/widgets/custom_button_3.dart'; // Import button with active/inactive state
import 'package:dressify_app/widgets/image_picker.dart'; // Import custom image picker widget
import 'package:flutter/material.dart';


/// AddItemScreen - Allows the user to add a new clothing item to their closet.
class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // Controller to manage input for item name
  final TextEditingController _nameController = TextEditingController();

  // Selected category and list of available categories
  String selectedCategory = '';
  List<String> categories = ['Tops', 'Bottoms', 'Shoes'];

  // Selected temperatures and list of available temperature options
  List<String> selectedTemperatures = [];
  List<String> temperatures = ['Hot', 'Warm', 'Cool', 'Cold'];

  // Path to the selected image (if any)
  String? _imagePath;

  @override//override initState to use setState
  void initState() {
    super.initState();

    // Add a listener to update the UI when the name field changes
    _nameController.addListener(_updateButtonState);
  }

  /// Updates the UI to reflect changes in name input
  void _updateButtonState() {
    setState(() {});
  }


  /*
  @override//override dispose for cleaning up thr resurce to make the app run smoothier
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _nameController.dispose();
    super.dispose();
  }
  */

  /// Method to update the selected image path
  void _updateImage(String? imagePath) {
    setState(() {
      _imagePath = imagePath;
    });
    setState(() {}); // This will re-evaluate the isActive condition
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to ensure responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 240, 240),

      // Custom App Bar with a back button enabled
      appBar: CustomAppBar(
        showBackButton: true,
      ),

      // Body of the Add Item Screen
      body: Column(
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

                    // "Adding New Item" heading
                    Text(
                      "Adding New Item",
                      style: kH2,
                    ),

                    // Add spacing below the heading
                    SizedBox(height: screenHeight * 0.02),

                    // Image Picker container that opens a prompt for choosing from camera/gallery
                    Center(
                      child: ImagePickerContainer(
                        onImageSelected:
                            _updateImage, // Pass method to update selected image
                        initialImagePath:
                            _imagePath, // Show previously selected image (if any)
                      ),
                    ),

                    // Add spacing below image picker
                    SizedBox(height: screenHeight * 0.01),

                    // Label for name input
                    Text("Name", style: kH2),

                    // TextField for entering item name (max length: 15 characters)
                    TextField(
                      controller: _nameController,
                      maxLength: 15,
                      decoration: const InputDecoration(
                        hintText: "e.g. Old Navy Crewneck",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    // Add spacing below name input
                    SizedBox(height: screenHeight * 0.01),

                    // Label for category selection
                    Text("Category", style: kH2),

                    // Wrap to display category selection buttons horizontally
                    Wrap(
                      spacing: 6, // Space between buttons
                      children: categories
                          .map(
                            (category) => IntrinsicWidth(
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
                                onSelected: (selected) {
                                  setState(() => selectedCategory = category);
                                },
                                selectedColor: Colors.black,
                                backgroundColor: Colors.white,
                                showCheckmark:
                                    false, // Prevents the checkmark from appearing
                                visualDensity:
                                    VisualDensity.compact, // Consistent height
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    // Add spacing below category buttons
                    SizedBox(height: screenHeight * 0.01),

                    // Label for temperature selection
                    Text("Temperature", style: kH2),

                    // Wrap to display temperature selection buttons horizontally
                    Wrap(
                      spacing: 6, // Space between buttons
                      children: temperatures
                          .map(
                            (temp) => IntrinsicWidth(
                              child: ChoiceChip(
                                label: Center(
                                  child: Text(
                                    temp,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          selectedTemperatures.contains(temp)
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                selected:
                                    selectedTemperatures.contains(temp), // Check if selected
                                onSelected: (selected) {
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
                          )
                          .toList(),
                    ),

                    // Add spacing before Save and Cancel buttons
                    SizedBox(height: screenHeight * 0.03),

                    // Row for Save and Cancel buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Save Button
                        CustomButton3(
                          // Button is active only if all required fields are filled
                          isActive: selectedCategory.isNotEmpty &&
                              selectedTemperatures.isNotEmpty &&
                              _nameController.text.isNotEmpty &&
                              _imagePath != null,

                          label: "SAVE",
                          onPressed: (selectedCategory.isNotEmpty &&
                                  selectedTemperatures.isNotEmpty &&
                                  _nameController.text.isNotEmpty &&
                                  _imagePath != null)
                              ? () {
                                  // Logic to save the item when all attributes are filled
                                  print("Item Saved!");
                                }
                              : () {}, // If button is inactive, do nothing
                        ),

                        // Cancel Button
                        CustomButton3(
                          label: "CANCEL",
                          onPressed: () {
                            setState(() {
                              // Reset all input fields and selections
                              _nameController.clear(); // Clear name field
                              selectedCategory = ''; // Clear category selection
                              selectedTemperatures
                                  .clear(); // Clear temperature selection
                              _imagePath = null;//clear the image path
                            });

                            // Return to the previous screen
                            Navigator.pop(context);
                          },
                        ),
                      ],
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

      // Bottom navigation bar is hidden to save screen space
      // bottomNavigationBar: const CustomNavBar(),
    );
  }
}
