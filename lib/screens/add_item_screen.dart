// This screen will allow the user to add a new clothing item to their closet
// It will consist of:
//1) App Bar -- which I already added in.
//2) Body-- which will contain 6 elements: 1) "Add New Item" text (use one of the styles defined in the constants.dart (e.g kH1 or kH2)
                                        // 2) Container that will display the clothing item once uploaded (do not worry about the functionality yet-- but
                                        //    this containerwhen clicked will open a prompt asking the user if they want to upload an image from gallery or take a picture) To be done later on
                                        // 2) A text input field for the item name (this will take maximum 15 characters including whitespaces and will have a hint text: "Name your item")
                                              // -- the text input should have a label "Name" displayed above it.
                                        // 3) Category selection buttons that will allow the user to select the category the item should be added in (do not worry about the functionality-- just add the buttons)
                                        // 4) Temperature selection buttons that will allow the user to select the appropriate temperature for their item (can choose more than one; the 4 options are: hot, warm, cool and cold)
                                        // 5) A row containing 2 buttons: "Save" and "Cancel" (you can reuse the custom_button widget inside the widget folder)
//3) Bottom Navigation Bar -- which I have already added in.

import 'package:dressify_app/constants.dart'; // this allows us to use the constants defined in lib/constants.dart
import 'package:dressify_app/widgets/custom_app_bar.dart'; // this allows us to use the custom app bar defined in lib/widgets/custom_app_bar.dart
import 'package:dressify_app/widgets/custom_bottom_navbar.dart'; // this allows us to use the custom bottom navigation bar defined in lib/widgets/custom_bottom_navbar.dart
import 'package:dressify_app/widgets/custom_button.dart';
import 'package:dressify_app/widgets/custom_button_3.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  String selectedCategory = '';
  List<String> categories = ['Tops', 'Bottoms', 'Shoes'];
  List<String> selectedTemperatures = [];
  List<String> temperatures = ['Hot', 'Warm', 'Cool', 'Cold'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 240, 240),
      appBar: CustomAppBar(showBackButton: true,),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: SingleChildScrollView( // Add scroll if content is still too large
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    Text("Adding New Item", style: kH2,),
                    SizedBox(height: screenHeight * 0.02),
                    GestureDetector(
                      onTap: () {
                        // Placeholder for image upload functionality
                      },
                      child: Center(
                        child: Container(
                          width: screenWidth * 0.75,
                          height: screenHeight * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black45),
                          ),
                          child: const Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.black45)),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text("Name", style: kH2),
                    TextField(
                      controller: _nameController,
                      maxLength: 15,
                      decoration: const InputDecoration(
                        hintText: "e.g. Old Navy Crewneck",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text("Category", style: kH2),
                    Wrap(
                      spacing: 6,
                      children: categories.map((category) => IntrinsicWidth(
                        child: ChoiceChip(
                          label: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontWeight: FontWeight.w500, 
                                color: selectedCategory == category ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          selected: selectedCategory == category,
                          onSelected: (selected) {
                            setState(() => selectedCategory = category);
                          },
                          selectedColor: Colors.black,
                          backgroundColor: Colors.white,
                          showCheckmark: false, // Prevents the checkmark from appearing
                          visualDensity: VisualDensity.compact, // Ensures consistent height
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Consistent padding
                        ),
                      )).toList(),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text("Temperature", style: kH2),
                    Wrap(
                      spacing: 6,
                      children: temperatures.map((temp) => IntrinsicWidth(
                        child: ChoiceChip(
                          label: Center(
                            child: Text(
                              temp,
                              style: TextStyle(
                                fontWeight: FontWeight.w500, // Keep consistent weight
                                color: selectedTemperatures.contains(temp) ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          selected: selectedTemperatures.contains(temp),
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
                          showCheckmark: false, // Prevents the checkmark from appearing
                          visualDensity: VisualDensity.compact, // Ensures consistent height
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Consistent padding
                        ),
                      )).toList(),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

              CustomButton3(
                // THIS WIDGET HAS AN ACTIVE AND INACTIVE STATE NOW
                // Default is : isActive: true
                // We start with the button as isActive: false.Once all conditions are met (all inputs are provided, you want to set isActive: true)
                // This will only allow the user to save an item that has all the required attributes entered
                // This widget is defined in lib/widgets/custom_button_3.dart
                isActive: selectedCategory.isNotEmpty && selectedTemperatures.isNotEmpty, // Button only active when both are selected
                
                // TODO: Once we write the functionality that allows users to upload an image, we must also check that an image was successfully uploaded
                //       as we cannot write to the DB unless we have all the required attributes: image url, label, category and weather suitability.
                
                label: "SAVE",
                onPressed: (selectedCategory.isNotEmpty && selectedTemperatures.isNotEmpty) 
                  ? () {
                      // Save functionality here
                      print("Item Saved!");
                    }
                  : () {}, // If inactive, do nothing

                //isActive: false,
                //label: "SAVE",
                //onPressed: () {}, // Keep logic for enabling/disabling here
              ),
              
              CustomButton3( 
                label: "CANCEL",
                onPressed: () {
                  setState(() {
                    _nameController.clear();
                    selectedCategory = ''; // Unselect category
                    selectedTemperatures.clear(); // Clear all selected temperatures
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
            SizedBox(height: screenHeight * 0.1),
                  ],
                  
                ),
              ),
            ),
          ),
          
        ],
      ),
      // bottomNavigationBar: const CustomNavBar(), HID THIS TO SAVE SCREEN SPACE
    );
  }
}

