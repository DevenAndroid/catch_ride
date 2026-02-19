
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class ReviewPromptModal extends StatelessWidget {
  const ReviewPromptModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rate Your Experience', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {}, // Handle rating change
                icon: const Icon(Icons.star_border, size: 40, color: AppColors.mutedGold),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your feedback (optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}
