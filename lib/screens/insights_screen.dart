import 'package:flutter/material.dart';
import 'package:dressify_app/constants.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/screens/display_outfit_screen.dart';
import 'package:dressify_app/widgets/outfit_card.dart';

class MostWornOutfitsSection extends StatelessWidget {
  const MostWornOutfitsSection({super.key});

  List<Outfit> getTopThreeMostWornOutfits() {
    final wornOutfits = Outfit.outfitList.where((o) => o.timesWorn > 0).toList();

    wornOutfits.sort((a, b) {
      if (b.timesWorn != a.timesWorn) {
        return b.timesWorn.compareTo(a.timesWorn);
      } else {
        return a.id.compareTo(b.id);
      }
    });

    return wornOutfits.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topThreeOutfits = getTopThreeMostWornOutfits();

    if (topThreeOutfits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Text("Most Worn Outfits", style: kH2),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: topThreeOutfits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final outfit = topThreeOutfits[index];
              return OutfitCard(
                outfit: outfit,
                isSelected: false,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OutfitSuggestionScreen(
                        outfit: outfit,
                        showFavorite: false,
                        showRegenerate: false,
                        showDeleteIcon: true,
                      ),
                    ),
                  );

                  if (result == true) {
                    // Optional: You can handle refreshing here if needed
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}