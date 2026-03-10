import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/view/trainer/list/add_new_listing_view.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:catch_ride/controllers/horse_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';

class HourseListingView extends StatefulWidget {
  const HourseListingView({super.key});

  @override
  State<HourseListingView> createState() => _HourseListingViewState();
}

class _HourseListingViewState extends State<HourseListingView> {
  final HorseController horseController = Get.find<HorseController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadHorses();
    _scrollController.addListener(_onScroll);
  }

  void _loadHorses({bool refresh = true}) {
    final trainerId = profileController.trainerId;
    final userId = profileController.id;
    
    if (trainerId.isNotEmpty) {
      horseController.fetchHorses(refresh: refresh, trainerId: trainerId);
    } else if (userId.isNotEmpty) {
      // Fallback to ownerId if trainer profile is not yet fully linked
      horseController.fetchHorses(refresh: refresh, ownerId: userId);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!horseController.isLoading.value && !horseController.isMoreLoading.value && horseController.hasNextPage.value) {
        _loadHorses(refresh: false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const CommonText(
          'My Horses',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => Get.to(() => const AddNewListingView()),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/images/logo.svg"),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CommonText(
                              'Add your horses',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00083B),
                            ),
                            CommonText(
                              'Create a listing to share availability.',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (horseController.isLoading.value && horseController.horses.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (horseController.horses.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '🐴',
                            style: TextStyle(fontSize: 72),
                          ),
                          const SizedBox(height: 20),
                          const CommonText(
                            'Your stable is empty!',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const CommonText(
                            'Every great trainer starts somewhere.\nList your first horse and let the rides find you.',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                            height: 1.6,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: () => Get.to(() => const AddNewListingView()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  CommonText(
                                    'List Your First Horse',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadHorses(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: horseController.horses.length + (horseController.hasNextPage.value ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == horseController.horses.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final horse = horseController.horses[index];
                      return _buildPostCard(
                        horse: horse,
                        userName: (horse.trainerName != null && horse.trainerName!.isNotEmpty) ? horse.trainerName! : profileController.fullName,
                        userAvatar: (horse.trainerAvatar != null && horse.trainerAvatar!.isNotEmpty) ? horse.trainerAvatar! : profileController.avatar,
                        timePosted: '16 days ago', // Placeholder to match design
                        mainImageUrl: horse.images.isNotEmpty ? horse.images.first : AppConstants.dummyImageUrl,
                        imageCount: '1 / ${horse.images.length}',
                        tags: horse.listingTypes,
                        postTitle: horse.listingTitle ?? horse.name,
                        postDescription: horse.description ?? '',
                        location: horse.location ?? 'Ocala, FL',
                        isOwnHorse: true,
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

  Widget _buildPostCard({
    required HorseModel horse,
    required String userName,
    String? userAvatar,
    required String timePosted,
    required String mainImageUrl,
    required String imageCount,
    required List<String> tags,
    required String postTitle,
    required String postDescription,
    required String location,
    bool isOwnHorse = false,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(() => TrainerHorseDetailView(horse: horse, isOwnHorse: isOwnHorse));
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
                  CommonImageView(
                    url: (userAvatar != null && userAvatar.isNotEmpty) ? userAvatar : AppConstants.dummyImageUrl,
                    height: 44,
                    width: 44,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          userName,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        CommonText(
                          timePosted,
                          fontSize: 13,
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
                      runSpacing: 8,
                      children: tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CommonText(
                                tag,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  const SizedBox(height: 6),
                  CommonText(
                    postDescription,
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      CommonText(
                        location,
                        fontSize: 13,
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
