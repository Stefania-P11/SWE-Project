import 'package:flutter/material.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:dressify_app/widgets/outfit_card.dart';
import 'package:dressify_app/constants.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<Outfit> mostWornOutfits = [];

  @override
  void initState() {
    super.initState();
    _prepareInsights();
  }

  Future<void> _prepareInsights() async {
    // Make sure outfits are fetched
    if (Outfit.outfitList.isEmpty) {
      await Outfit.fetchOutfits(kUsername);
    }

    // Sort outfits by timesWorn
    final sortedOutfits = List<Outfit>.from(Outfit.outfitList)
      ..sort((a, b) => b.timesWorn.compareTo(a.timesWorn));

    // Take top 10 most worn
    setState(() {
      mostWornOutfits = sortedOutfits.take(10).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: kBackgroundColor,
      bottomNavigationBar: const CustomNavBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Most Worn Outfits", style: kH2),
            const SizedBox(height: 10),
            SizedBox(
              height: 280, // enough height for the full outfit card
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mostWornOutfits.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final outfit = mostWornOutfits[index];
                  return OutfitCard(
                    outfit: outfit,
                    isSelected: false,
                    onTap: () {
                      // Optional: navigate to outfit details
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
