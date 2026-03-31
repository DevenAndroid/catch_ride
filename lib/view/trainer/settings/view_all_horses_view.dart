import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/view/trainer/list/edit_horse_listing_view.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/horse_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';

class ViewAllHorsesView extends StatefulWidget {
  const ViewAllHorsesView({super.key});

  @override
  State<ViewAllHorsesView> createState() => _ViewAllHorsesViewState();
}

class _ViewAllHorsesViewState extends State<ViewAllHorsesView> {
  final HorseController horseController = Get.put(HorseController());
  final ProfileController profileController = Get.put(ProfileController());
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
      horseController.fetchHorses(refresh: refresh, ownerId: userId);
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'View all Horses',
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (horseController.isLoading.value &&
              horseController.horses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final displayHorses = horseController.horses;

          if (displayHorses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadHorses(),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount:
                  displayHorses.length +
                  (horseController.hasNextPage.value &&
                          horseController.horses.isNotEmpty
                      ? 1
                      : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == displayHorses.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final horse = displayHorses[index];
                return _buildPostCard(
                  horse: horse,
                  userName:
                      (horse.trainerName != null &&
                          horse.trainerName!.isNotEmpty)
                      ? horse.trainerName!
                      : profileController.fullName,
                  userAvatar:
                      (horse.trainerAvatar != null &&
                          horse.trainerAvatar!.isNotEmpty)
                      ? horse.trainerAvatar!
                      : profileController.avatar,
                  timePosted: '16 days ago',
                  mainImageUrl: horse.images.isNotEmpty
                      ? horse.images.first
                      : (horse.photo ?? ''),

                  imageCount: '1 / ${horse.images.length}',
                  tags: horse.listingTypes,
                  postTitle: horse.listingTitle ?? horse.name,
                  postDescription: horse.description ?? '',
                  location: horse.location ?? '',
                  isOwnHorse: true,
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🐴', style: TextStyle(fontSize: 72)),
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
              'List your horses and they will appear here.',
              fontSize: 14,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
              height: 1.6,
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
        Get.to(
          () => TrainerHorseDetailView(horse: horse, isOwnHorse: isOwnHorse),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
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
                    url: userAvatar,
                    height: 48,
                    width: 48,
                    shape: BoxShape.circle,
                    isUserImage: true,
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          userName,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 1),
                        CommonText(
                          timePosted,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                      IconButton(
                        onPressed: () {
                          Get.bottomSheet(
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.textPrimary,
                                    ),
                                    title: const CommonText(
                                      'Edit Listing',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onTap: () {
                                      Get.back();
                                      Get.to(
                                        () => EditHorseListingView(horse: horse),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                ],
              ),
            ),

            // Image
            Stack(
              children: [
                ClipRRect(
                  child: CommonImageView(
                    url: mainImageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
             /*   Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CommonText(
                      imageCount,
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),*/
              ],
            ),

            // Tags
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CommonText(
                            tag,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    postTitle,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  const SizedBox(height: 6),
                  CommonText(
                    postDescription,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
