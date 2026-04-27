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
import 'package:catch_ride/utils/date_util.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHorses();
    });
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
      horseController.fetchHorses(refresh: refresh, ownerId: userId);
    } else {
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
          if ((horseController.isLoading.value || profileController.isLoading.value) &&
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
                  timePosted: DateUtil.getTimeAgo(horse.createdAt),
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
           // const Text('🐴', style: TextStyle(fontSize: 72)),
         //   const SizedBox(height: 20),
         //    const CommonText(
         //      'Your stable is empty!',
         //      fontSize: 22,
         //      fontWeight: FontWeight.bold,
         //      color: AppColors.textPrimary,
         //      textAlign: TextAlign.center,
         //    ),
         //    const SizedBox(height: 12),
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
                        Row(
                          children: [
                            CommonText(
                              userName,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
                        const SizedBox(height: 1),
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
                      size: 22,
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
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: CommonText(
                            tag,
                            fontSize: 11,
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

  void _confirmDelete(HorseModel horse) {
    Get.dialog(
      AlertDialog(
        title: const CommonText(
          'Delete Listing',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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
            child: const CommonText(
              'Delete',
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
