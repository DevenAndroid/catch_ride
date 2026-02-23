import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class HorseCard extends StatelessWidget {
  final String name;
  final String location;
  final String price;
  final String breed;
  final String height;
  final String age;
  final String imageUrl; // Placeholder for now
  final String? description;
  final String? discipline;
  final String? listingType;
  final bool isTopRated;

  const HorseCard({
    super.key,
    required this.name,
    required this.location,
    required this.price,
    required this.breed,
    required this.height,
    required this.age,
    required this.imageUrl,
    this.description,
    this.discipline,
    this.listingType,
    this.isTopRated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media Section (Video/Image Placeholder)
          Stack(
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  color: AppColors.grey300,
                  image: DecorationImage(
                    image: NetworkImage(
                      imageUrl,
                    ), // Will fail if offline or invalid URL, handle gracefully
                    fit: BoxFit.cover,
                  ),
                ),
                // Fallback if network image fails? Flutter handles it by just not showing or showing error builder.
                // For now, I'll assume valid URLs or handle error logic later.
              ),

              // Graduate/Top Rated Badge
              if (isTopRated)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mutedGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.deepNavy,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Top Rated',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.deepNavy,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Favorite Button
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              // Video Indicator
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(name, style: AppTextStyles.titleMedium)],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(location, style: AppTextStyles.bodyMedium),
                  ],
                ),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),

                // Attributes: Breed • Height • Age • Discipline • Listing Type
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildAttributeChip(breed),
                    _buildAttributeChip(height),
                    _buildAttributeChip(age),
                    if (discipline != null && discipline!.isNotEmpty)
                      _buildAttributeChip(discipline!),
                    if (listingType != null && listingType!.isNotEmpty)
                      _buildAttributeChip(listingType!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
