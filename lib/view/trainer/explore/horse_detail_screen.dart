import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/controllers/user_role_controller.dart';

class HorseDetailScreen extends StatelessWidget {
  const HorseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roleController = Get.find<UserRoleController>();
    final isBM = roleController.isBarnManager;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black26,
                shape: const CircleBorder(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                ),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://images.unsplash.com/photo-1534008897995-27a23e859048?auto=format&fit=crop&q=80&w=1000',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.grey300,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: AppColors.grey500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              // Negative margin to pull up over image
              transform: Matrix4.translationValues(0, -20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thunderbolt',
                            style: AppTextStyles.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Warmblood • 17.1hh • 9 yrs',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$65,000',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTag('Jumper'),
                      _buildTag('Lease Option'),
                      _buildTag('Experienced'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.deepNavy,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Wellington Stables, FL',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text('About', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Thunderbolt is an exceptional warmblood gelding with a proven show record in 1.30m jumpers. He is brave, careful, and has a huge stride. Perfect for a junior or amateur looking to move up. Currently available for sale or lease.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: isBM
                              ? 'Request More Info\n(on behalf of Trainer)'
                              : 'Contact Seller',
                          isOutlined: true,
                          onPressed: () {
                            if (isBM) {
                              Get.snackbar(
                                'Inquiry Sent',
                                'Message explicitly labeled: "From Sarah (Barn Manager) acting on behalf of ${roleController.linkedTrainerName.value}"',
                                duration: const Duration(seconds: 4),
                              );
                            } else {
                              Get.snackbar(
                                'Message',
                                'Opening chat with seller',
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          text: isBM
                              ? 'Request Trial\n(on behalf of Trainer)'
                              : 'Book Trial',
                          onPressed: () {
                            // Book Trial Flow
                            Get.snackbar('Trial', 'Navigate to booking flow');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey800),
      ),
    );
  }
}
