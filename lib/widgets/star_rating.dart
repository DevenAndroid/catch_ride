
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final int count;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = AppColors.mutedGold,
    this.count = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, size: size, color: color);
        } else if (index < rating && (rating - index) >= 0.5) {
          return Icon(Icons.star_half, size: size, color: color);
        } else {
          return Icon(Icons.star_border, size: size, color: color);
        }
      }),
    );
  }
}
