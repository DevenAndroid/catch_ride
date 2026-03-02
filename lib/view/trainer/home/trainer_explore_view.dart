import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/view/trainer/settings/notifications_view.dart';
import 'package:catch_ride/view/trainer/settings/edit_profile.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/controllers/explore_controller.dart';
import 'package:get/get.dart';

class TrainerExploreView extends StatefulWidget {
  const TrainerExploreView({super.key});

  @override
  State<TrainerExploreView> createState() => _TrainerExploreViewState();
}

class _TrainerExploreViewState extends State<TrainerExploreView> {
  final ExploreController controller = Get.put(ExploreController());
  final List<String> _filters = ['All', 'Hunter', 'Jumper', 'Equitation'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilters(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.horses.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.horses.isEmpty) {
                  return const Center(
                    child: CommonText(
                      'No horses found',
                      fontSize: AppTextSizes.size16,
                      color: AppColors.textSecondary,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchHorses,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: controller.horses.length,
                    itemBuilder: (context, index) {
                      final horse = controller.horses[index];
                      final trainer = horse['trainerId'];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPostCard(
                          userName: trainer != null 
                              ? '${trainer['firstName']} ${trainer['lastName']}'
                              : (horse['trainerName'] ?? 'Unknown Trainer'),
                          userTitle: trainer != null ? (trainer['barnName'] ?? 'Professional Trainer') : 'Professional Trainer',
                          mainImageUrl: horse['photo'] ?? AppConstants.dummyImageUrl,
                          imageCount: '1 / ${(horse['images']?.length ?? 1)}',
                          tags: [
                            horse['status'] == 'available' ? 'For sale' : horse['status'],
                            if (horse['discipline'] != null) horse['discipline'],
                          ],
                          postTitle: horse['name'] ?? 'Untitled Horse',
                          postDescription: horse['description'] ?? 'No description available',
                          location: horse['location'] ?? 'Location not specified',
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.to(() => const EditProfileView()),
            child: Row(
              children: [
                const CommonImageView(
                  url: AppConstants.dummyImageUrl,
                  height: 48,
                  width: 48,
                  shape: BoxShape.circle,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CommonText(
                      AppStrings.johnSnow,
                      fontSize: AppTextSizes.size18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    CommonText(
                      AppStrings.professionalHorseTrainer,
                      fontSize: AppTextSizes.size12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const NotificationsView()),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: controller.onSearch,
        decoration: InputDecoration(
          hintText: AppStrings.searchByTrainersOrHorses,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 24,
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = controller.selectedDiscipline.value == _filters[index];
          return GestureDetector(
            onTap: () {
              controller.updateDiscipline(_filters[index]);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: CommonText(
                _filters[index],
                fontSize: AppTextSizes.size14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          );
        }),
      ),
    ));
  }

  Widget _buildPostCard({
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
      onTap: () {
        Get.to(() => const TrainerHorseDetailView());
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
