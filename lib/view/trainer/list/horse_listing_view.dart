import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/view/trainer/list/add_new_listing_view.dart';
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                          colorFilter: const ColorFilter.mode(Color(0xFF00083B), BlendMode.srcIn),
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
                              'Create a listing to share availability.',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFF667085), size: 24),
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
    final String mainImageUrl = horse.photo ?? AppConstants.dummyImageUrl;
    final String imageCount = horse.images.isNotEmpty ? "1 / ${horse.images.length}" : "1 / 1";
    final List<String> listingTypes = horse.listingTypes;
    final String postTitle = "${horse.name.isEmpty ? 'N/A' : horse.name} - ${horse.displayDiscipline.isEmpty ? 'N/A' : horse.displayDiscipline}";
    final String postDescription = (horse.description == null || horse.description!.isEmpty) ? "N/A" : horse.description!;
    final String location = (horse.location == null || horse.location!.isEmpty) ? "N/A" : horse.location!;

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
                  fallbackIcon: Icons.person,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        userName,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      CommonText(
                        timePosted,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showHorseActions(horse),
                  icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Image
          GestureDetector(
             onTap: () => Get.to(() => TrainerHorseDetailView(horse: horse, isOwnHorse: true)),
             child: Stack(
              children: [
                CommonImageView(
                  url: mainImageUrl,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                ),
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
                  children: listingTypes.map((type) => _buildTypeTag(type)).toList(),
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
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF6B7280)),
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

  void _showHorseActions(HorseModel horse) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.textPrimary),
              title: const CommonText('Edit Horse', fontSize: 16),
              onTap: () {
                Navigator.pop(context);
                // Edit logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: AppColors.textPrimary),
              title: const CommonText('Manage Availability', fontSize: 16),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => BarnManagerAvailabilityView(horse: horse));
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
              title: const CommonText('Share Listing', fontSize: 16),
              onTap: () {
                Navigator.pop(context);
                // Share logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
