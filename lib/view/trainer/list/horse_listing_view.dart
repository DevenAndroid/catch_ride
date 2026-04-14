import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/view/trainer/list/add_new_listing_view.dart';
import 'package:catch_ride/view/trainer/list/edit_horse_listing_view.dart';
import 'package:catch_ride/view/barn_manager/barn_manager_availability_view.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:catch_ride/controllers/horse_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/widgets/horse_card.dart';
import 'package:catch_ride/widgets/horse_card.dart';

import 'package:catch_ride/utils/date_util.dart';

class HorseListingView extends StatefulWidget {
  const HorseListingView({super.key});

  @override
  State<HorseListingView> createState() => _HorseListingViewState();
}

class _HorseListingViewState extends State<HorseListingView> {
  final HorseController horseController = Get.find<HorseController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadHorses();
    // Re-load when user profile is fetched
    ever(profileController.user, (_) => _loadHorses());
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadHorses({bool refresh = true}) async {
    if (profileController.user.value == null) {
      int retries = 0;
      while (profileController.user.value == null && retries < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }
    }

    final trainerId = profileController.trainerId;
    final userId = profileController.id;

    if (trainerId.isNotEmpty) {
      horseController.fetchHorses(refresh: refresh, trainerId: trainerId);
    } else if (userId.isNotEmpty) {
      // Fallback to ownerId if trainer profile is not yet fully linked
      horseController.fetchHorses(refresh: refresh, ownerId: userId);
    } else {
      // If we still don't have ids, we can't fetch anything specific that is 'My Horses'
      horseController.horses.clear();
      horseController.hasNextPage.value = false;
      horseController.isLoading.value = false;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!horseController.isLoading.value &&
          !horseController.isMoreLoading.value &&
          horseController.hasNextPage.value) {
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2F4F7),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          "assets/images/logo.svg",
                          width: 32,
                          height: 32,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF00083B),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CommonText(
                              'Add your horses',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF101828),
                            ),
                            const SizedBox(height: 2),
                            CommonText(
                              'Create a listing to share availability',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF667085),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if ((horseController.isLoading.value || profileController.isLoading.value) &&
                    horseController.horses.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (horseController.horses.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const CommonText(
                            'Your Sales Start Here',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const CommonText(
                            'Add your first horse to share availability and connect with the right rides, trainers, and opportunities.',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                            height: 1.6,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: () =>
                                Get.to(() => const AddNewListingView()),
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
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount:
                        horseController.horses.length +
                        (horseController.hasNextPage.value ? 1 : 0),
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
                      return _buildVerticalHorseCard(horse);
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

  Widget _buildVerticalHorseCard(HorseModel horse) {
    final user = profileController.user.value;
    final String userName = user?.fullName ?? 'N/A';
    final String? userAvatar = user?.displayAvatar;
    final String timePosted = DateUtil.getTimeAgo(horse.createdAt);
    final String? mainImageUrl = horse.photo;
    final String imageCount = horse.images.isNotEmpty
        ? "1 / ${horse.images.length}"
        : "1 / 1";
    final List<String> listingTypes = horse.listingTypes;
    final String postTitle =
        "${horse.name.isEmpty ? 'N/A' : horse.name} - ${horse.displayDiscipline.isEmpty ? 'N/A' : horse.displayDiscipline}";
    final String postDescription =
        (horse.description == null || horse.description!.isEmpty)
        ? "N/A"
        : horse.description!;
    final String location = (horse.location == null || horse.location!.isEmpty)
        ? "N/A"
        : horse.location!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CommonImageView(
                  url: userAvatar,
                  height: 40,
                  width: 40,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CommonText(
                            userName,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: horse.isActive
                                  ? const Color(0xFFECFDF3)
                                  : const Color(0xFFFEF3F2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: CommonText(
                              horse.isActive ? 'Active' : 'Inactive',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: horse.isActive
                                  ? const Color(0xFF027A48)
                                  : const Color(0xFFB42318),
                            ),
                          ),
                        ],
                      ),
                      CommonText(
                        timePosted,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textPrimary,
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Get.to(() => EditHorseListingView(horse: horse));
                    } else if (value == 'active') {
                      final success = await horseController.toggleHorseActive(
                        horse.id!,
                        !horse.isActive,
                      );
                      if (success) {
                        Get.snackbar(
                          'Success',
                          'Horse status updated successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      }
                    } else if (value == 'delete') {
                      _confirmDelete(horse);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20),
                          const SizedBox(width: 8),
                          const CommonText('Edit listing', fontSize: 14),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'active',
                      child: Row(
                        children: [
                          Icon(
                            horse.isActive
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: horse.isActive
                                ? Colors.orange
                                : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          CommonText(
                            horse.isActive ? 'Deactivate' : 'Activate',
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          const CommonText(
                            'Delete listing',
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Image
          GestureDetector(
            onTap: () => Get.to(
              () => TrainerHorseDetailView(horse: horse, isOwnHorse: true),
            ),
            child: Stack(
              children: [
                CommonImageView(
                  url: mainImageUrl,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
          /*      Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CommonText(
                      imageCount,
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),*/
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: listingTypes
                      .map((type) => _buildTypeTag(type))
                      .toList(),
                ),
                const SizedBox(height: 12),
                CommonText(
                  postTitle,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 6),
                CommonText(
                  postDescription,
                  fontSize: 14,
                  color: const Color(0xFF4B5563),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    CommonText(
                      location,
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTag(String label) {
    return Container(
      margin: EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF713B34).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CommonText(
        label,
        fontSize: 11,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _confirmDelete(HorseModel horse) {
    Get.dialog(
      AlertDialog(
        title: const CommonText('Delete Listing', fontSize: 18, fontWeight: FontWeight.bold),
        content: CommonText(
          'Are you sure you want to delete ${horse.name}? This action cannot be undone.',
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const CommonText('Cancel', color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await horseController.deleteHorse(horse.id!);
              if (success) {
                Get.snackbar(
                  'Deleted',
                  'Horse listing has been removed',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to delete horse listing',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            },
            child: const CommonText('Delete', color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
