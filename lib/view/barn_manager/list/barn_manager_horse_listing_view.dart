import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/view/barn_manager/home/barn_manager_horse_detail_view.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/view/barn_manager/barn_manager_availability_view.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:catch_ride/controllers/horse_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/utils/date_util.dart';
import 'package:catch_ride/widgets/horse_card.dart';

class BarnManagerHorseListingView extends StatefulWidget {
  const BarnManagerHorseListingView({super.key});

  @override
  State<BarnManagerHorseListingView> createState() =>
      _BarnManagerHorseListingViewState();
}

class _BarnManagerHorseListingViewState
    extends State<BarnManagerHorseListingView> {
  final HorseController horseController = Get.find<HorseController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadHorses();
    // Re-load when user profile or linked trainer is fetched
    ever(profileController.user, (_) => _loadHorses());
    ever(profileController.linkedTrainerProfile, (_) => _loadHorses());
    _scrollController.addListener(_onScroll);
  }

  void _loadHorses({bool refresh = true}) {
    // Try to get trainer ID from multiple sources
    String trainerId = profileController.trainerId;
    if (trainerId.isEmpty) {
      trainerId = profileController.user.value?.linkedTrainer?.id ?? '';
    }
    
    final userId = profileController.id;

    if (trainerId.isNotEmpty) {
      horseController.fetchHorses(refresh: refresh, trainerId: trainerId);
    } else if (userId.isNotEmpty) {
      // Fallback to ownerId if trainer profile is not yet fully linked
      horseController.fetchHorses(refresh: refresh, ownerId: userId);
    } else {
      // Ensure loading spinner stops even if no IDs found
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
            Expanded(
              child: Obx(() {
                if (horseController.isLoading.value &&
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
                          const Text('🐴', style: TextStyle(fontSize: 72)),
                          const SizedBox(height: 20),
                          const CommonText(
                            'No horses found',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const CommonText(
                            'Your associated trainer hasn\'t listed any horses yet. They will appear here once added.',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                            height: 1.6,
                            maxLines: 4,
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
    // Determine the "Owner" to display in the header
    // Preference: 1. Booked User (buyer) 2. Specific Owner 3. Trainer info on horse 4. Linked Trainer profile 5. Trainer on User record
    final String ownerName = horse.bookedByName ??
        horse.ownerName ??
        horse.trainerName ??
        profileController.linkedTrainerProfile.value?.fullName ??
        profileController.user.value?.linkedTrainer?.fullName ??
        'N/A';

    final String? ownerAvatar = horse.bookedByAvatar ??
        horse.ownerAvatar ??
        horse.trainerAvatar ??
        profileController.linkedTrainerProfile.value?.displayAvatar ??
        profileController.user.value?.linkedTrainer?.avatar;

    final String timePosted = DateUtil.getTimeAgo(horse.createdAt);
    final String? mainImageUrl = horse.photo;
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
                  url: ownerAvatar,
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
                            ownerName,
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
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  onSelected: (value) {
                    if (value == 'availability') {
                      Get.to(() => BarnManagerAvailabilityView(horse: horse));
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'availability',
                      child: Row(
                        children: const [
                          Icon(
                            Icons.calendar_month,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          CommonText('Manage Availability', fontSize: 14),
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
              () => BarnManagerHorseDetailView(horse: horse, isOwnHorse: false),
            ),
            child: CommonImageView(
              url: mainImageUrl,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
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
                  runSpacing: 8,
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
}
