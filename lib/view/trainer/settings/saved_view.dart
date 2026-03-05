import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavedView extends StatelessWidget {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Saved',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSavedPostCard(
            userName: 'Arya Stark',
            userTitle: 'Professional Horse Trainer',
            mainImageUrl: AppConstants.dummyImageUrl,
            imageCount: '1 / 12',
            tags: ['For sale', 'Weekly Lease'],
            postTitle: 'Speedy mare - Dressage Star',
            postDescription:
                'Perfect for competitive riders looking for a spirited partner',
            location: 'Winterfell, USA, United States',
          ),
          const SizedBox(height: 16),
          _buildSavedPostCard(
            userName: 'Arya Stark',
            userTitle: 'Professional Horse Trainer',
            mainImageUrl: AppConstants.dummyImageUrl,
            imageCount: '1 / 12',
            tags: ['For sale', 'Weekly Lease'],
            postTitle: 'Speedy mare - Dressage Star',
            postDescription:
                'Perfect for competitive riders looking for a spirited partner',
            location: 'Winterfell, USA, United States',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSavedPostCard({
    required String userName,
    required String userTitle,
    required String mainImageUrl,
    required String imageCount,
    required List<String> tags,
    required String postTitle,
    required String postDescription,
    required String location,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => const TrainerHorseDetailView()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const CommonImageView(
                    url: AppConstants.dummyImageUrl,
                    height: 40,
                    width: 40,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          userName,
                          fontSize: AppTextSizes.size14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        CommonText(
                          userTitle,
                          fontSize: AppTextSizes.size12,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: AppColors.textPrimary),
                ],
              ),
            ),

            // Image
            Stack(
              children: [
                CommonImageView(
                  url: mainImageUrl,
                  height: 220,
                  width: double.infinity,
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CommonText(
                      imageCount,
                      color: Colors.white,
                      fontSize: AppTextSizes.size12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Action Row & Tags
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.tabBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CommonText(
                                tag,
                                fontSize: AppTextSizes.size12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const Icon(
                    Icons.share_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.bookmark,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    postTitle,
                    fontSize: AppTextSizes.size16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  const SizedBox(height: 6),
                  CommonText(
                    postDescription,
                    fontSize: AppTextSizes.size14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      CommonText(
                        location,
                        fontSize: AppTextSizes.size12,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
