import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/view/trainer/list/add_new_listing_view.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:get/get.dart';

class HourseListingView extends StatefulWidget {
  const HourseListingView({super.key});

  @override
  State<HourseListingView> createState() => _HourseListingViewState();
}

class _HourseListingViewState extends State<HourseListingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const CommonText(
          'Horse Listing',
          color: AppColors.textPrimary,
          fontSize: AppTextSizes.size22,
          fontWeight: FontWeight.bold,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Get.to(() => const AddNewListingView(),
                );
              },
              child: Image.asset(
                "assets/images/add_hours4x.png",
                width: double.infinity,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonText(
                      'My horse listing',
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    _buildPostCard(
                      userName: 'John Snow',
                      timePosted: '16 days ago',
                      mainImageUrl: AppConstants.dummyImageUrl,
                      // Fallback dummy
                      imageCount: '1 / 12',
                      tags: ['For sale', 'Weekly Lease'],
                      postTitle: 'Demo horse - Young Developing Hunter',
                      postDescription:
                          'An ideal small pony and great for a Child An ideal small pony and great for a Child',
                      location: 'Ocklawaha, USA, United States',
                    ),
                    const SizedBox(height: 16),
                    _buildPostCard(
                      userName: 'John Snow',
                      timePosted: '16 days ago',
                      mainImageUrl: AppConstants.dummyImageUrl,
                      // Fallback dummy
                      imageCount: '1 / 12',
                      tags: ['For sale', 'Weekly Lease'],
                      postTitle: 'Speedy mare - Dressage Star',
                      postDescription:
                          'Perfect for competitive riders looking for a spirited partner',
                      location: 'Winterfell, USA, United States',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard({
    required String userName,
    required String timePosted,
    required String mainImageUrl,
    required String imageCount,
    required List<String> tags,
    required String postTitle,
    required String postDescription,
    required String location,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const TrainerHorseDetailView(),
        );
      },
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
                    height: 48,
                    width: 48,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          userName,
                          fontSize: AppTextSizes.size16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        CommonText(
                          timePosted,
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
                      color: Colors.black.withValues(alpha: 0.6),
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
                    Icons.bookmark_outline,
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
