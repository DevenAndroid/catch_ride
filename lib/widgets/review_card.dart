
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class ReviewCard extends StatelessWidget {
  final String reviewerName;
  final String date;
  final String comment;
  final double rating;

  const ReviewCard({
    super.key,
    required this.reviewerName,
    required this.date,
    required this.comment,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(reviewerName, style: AppTextStyles.titleMedium),
                Text(date, style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: AppColors.mutedGold,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(comment, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
