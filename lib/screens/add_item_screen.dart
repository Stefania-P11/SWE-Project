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
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  String selectedCategory = 'Tops';
  List<String> categories = ['Tops', 'Bottoms', 'Shoes'];
  List<String> selectedTemperatures = ['Hot'];
  List<String> temperatures = ['Hot', 'Warm', 'Cool', 'Cold'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 240, 240),
      appBar: CustomAppBar(),
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
                    Text("Adding New Item", style: kH2),
                    SizedBox(height: screenHeight * 0.02),
                    GestureDetector(
                      onTap: () {
                        // Placeholder for image upload functionality
                      },
                      child: Container(
                        width: double.infinity,
                        height: screenHeight * 0.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black45),
                        ),
                        child: const Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.black45)),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text("Name", style: kH2),
                    TextField(
                      controller: _nameController,
                      maxLength: 15,
                      decoration: const InputDecoration(
                        hintText: "Name your item",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text("Category", style: kH2),
                    Wrap(
                      spacing: 6,
                      children: categories.map((category) => ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          setState(() => selectedCategory = category);
                        },
                        selectedColor: Colors.black,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selectedCategory == category ? Colors.white : Colors.black,
                        ),
                      )).toList(),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text("Temperature", style: kH2),
                    Wrap(
                      spacing: 6,
                      children: temperatures.map((temp) => ChoiceChip(
                        label: Text(temp),
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
                        labelStyle: TextStyle(
                          color: selectedTemperatures.contains(temp) ? Colors.white : Colors.black,
                        ),
                      )).toList(),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: "SAVE",
                  onPressed: () {}, // Keep logic for enabling/disabling here
                ),
                CustomButton(
                  text: "CANCEL",
                  onPressed: () {
                    setState(() {
                      _nameController.clear();
                      selectedCategory = 'Tops';
                      selectedTemperatures = ['Hot'];
                    });
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

