import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/view/trainer/list/edit_horse_listing_view.dart';
import 'package:catch_ride/view/barn_manager/barn_manager_availability_view.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/horse_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/utils/date_util.dart';

class TrainerActiveHorsesView extends StatefulWidget {
  final String? trainerId;
  const TrainerActiveHorsesView({super.key, this.trainerId});

  @override
  State<TrainerActiveHorsesView> createState() => _TrainerActiveHorsesViewState();
}

class _TrainerActiveHorsesViewState extends State<TrainerActiveHorsesView> {
  // Use a tagged controller to isolate active horse data from the main management list
  final HorseController horseController = Get.put(HorseController(), tag: 'active_listings');
  final ProfileController profileController = Get.find<ProfileController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tId = widget.trainerId ?? profileController.trainerId;
      
      // If the controller is empty or belongs to a different trainer, fetch
      if (horseController.horses.isEmpty || 
          horseController.horses.any((h) => h.trainerId != tId)) {
        horseController.horses.clear();
        horseController.isLoading.value = true;
        _loadHorses(refresh: true);
      } else {
        // Data is already there and correct for this trainer: show instantly!
        // (Optional: background refresh)
        _loadHorses(refresh: true);
      }
    });
  }

  Future<void> _loadHorses({bool refresh = true}) async {
    final tId = widget.trainerId ?? profileController.trainerId;
    if (tId.isNotEmpty) {
      await horseController.fetchHorses(
        refresh: refresh, 
        trainerId: tId,
        isActive: true,
      );
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
          'Available Horses',
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (horseController.isLoading.value && horseController.horses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (horseController.horses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadHorses(),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                final bool isOwnHorse = widget.trainerId == null || widget.trainerId == profileController.user.value?.trainerProfileId;

                return _buildPostCard(
                  horse: horse,
                  userName: (horse.trainerName != null && horse.trainerName!.isNotEmpty)
                      ? horse.trainerName!
                      : profileController.fullName,
                  userAvatar: (horse.trainerAvatar != null && horse.trainerAvatar!.isNotEmpty)
                      ? horse.trainerAvatar!
                      : profileController.avatar,
                  timePosted: DateUtil.getTimeAgo(horse.createdAt),
                  mainImageUrl: horse.images.isNotEmpty ? horse.images.first : (horse.photo ?? ''),
                  imageCount: '1 / ${horse.images.length}',
                  tags: horse.listingTypes,
                  postTitle: horse.listingTitle ?? horse.name,
                  postDescription: horse.description ?? '',
                  location: horse.location ?? '',
                  isOwnHorse: isOwnHorse,
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: CommonText(
          'No horses available at the moment.',
          fontSize: 14,
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
          height: 1.6,
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
    final userRole = profileController.user.value?.role;
    final horseTrainerId = horse.trainerId;
    final profileTrainerId = profileController.trainerId;
    final bool isHorseOwner = horseTrainerId != null && horseTrainerId == profileTrainerId;
    final bool isTrainerOwner = isHorseOwner && userRole == 'trainer';
    final bool isBarnManagerTeam = isHorseOwner && userRole == 'barn_manager';

    return GestureDetector(
      onTap: () {
        Get.to(() => TrainerHorseDetailView(horse: horse, isOwnHorse: isOwnHorse));
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(right: 0),
              child: Row(
                children: [
                  CommonImageView(
                    url: userAvatar,
                    height: 48,
                    width: 48,
                    shape: BoxShape.circle,
                    isUserImage: false,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CommonText(
                                userName,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: horse.isActive ? const Color(0xFFECFDF3) : const Color(0xFFFEF3F2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: CommonText(
                                horse.isActive ? 'Active' : 'Inactive',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: horse.isActive ? const Color(0xFF027A48) : const Color(0xFFB42318),
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
                  if (isTrainerOwner || isBarnManagerTeam)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert, color: AppColors.textPrimary, size: 22),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Get.to(() => EditHorseListingView(horse: horse));
                        } else if (value == 'availability') {
                          await Get.to(() => BarnManagerAvailabilityView(horse: horse));
                          _loadHorses();
                        } else if (value == 'active') {
                          final success = await horseController.toggleHorseActive(horse.id!, !horse.isActive);
                          if (success) {
                            Get.snackbar('Success', 'Horse status updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
                            _loadHorses();
                          }
                        } else if (value == 'delete') {
                          _confirmDelete(horse);
                        }
                      },
                      itemBuilder: (context) => [
                        if (isTrainerOwner) ...[
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
                                  horse.isActive ? Icons.visibility_off : Icons.visibility,
                                  size: 20,
                                  color: horse.isActive ? Colors.orange : Colors.green,
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
                        if (isBarnManagerTeam)
                          PopupMenuItem(
                            value: 'availability',
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined, size: 20),
                                const SizedBox(width: 8),
                                const CommonText('Edit Availability', fontSize: 14),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),

            // Image
            ClipRRect(
              child: CommonImageView(
                url: mainImageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                isUserImage: false,
              ),
            ),

            // Tags
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(6)),
                    child: CommonText(tag, fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
                  )).toList(),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(postTitle, fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.3),
                  const SizedBox(height: 4),
                  CommonText(postDescription, fontSize: 14, color: AppColors.textSecondary, height: 1.5, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top:2),
                        child: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 16),
                      ),
                      const SizedBox(width: 4),
                      Flexible(child: CommonText(location, fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
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
        title: const CommonText('Delete Listing', fontSize: 18, fontWeight: FontWeight.bold),
        content: CommonText('Are you sure you want to delete ${horse.name}? This action cannot be undone.', fontSize: 14),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const CommonText('Cancel', color: AppColors.textSecondary)),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await horseController.deleteHorse(horse.id!);
              if (success) {
                Get.snackbar('Deleted', 'Horse listing has been removed', backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: const CommonText('Delete', color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
