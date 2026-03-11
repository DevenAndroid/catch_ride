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
import 'package:catch_ride/widgets/horse_card.dart';
import 'package:catch_ride/widgets/horse_card.dart';

class BarnManagerHorseListingView extends StatefulWidget {
  const BarnManagerHorseListingView({super.key});

  @override
  State<BarnManagerHorseListingView> createState() => _BarnManagerHorseListingViewState();
}

class _BarnManagerHorseListingViewState extends State<BarnManagerHorseListingView> {
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
                      return HorseCard(
                        horse: horse,
                        onTap: () => Get.to(() => BarnManagerHorseDetailView(horse: horse, isOwnHorse: false)),
                        trailing: PopupMenuButton<String>(
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.more_vert, color: AppColors.textPrimary, size: 24),
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
                                  Icon(Icons.calendar_month, size: 20, color: AppColors.textPrimary),
                                  SizedBox(width: 8),
                                  CommonText('Manage Availability', fontSize: 14),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: const [
                                  Icon(Icons.share, size: 20, color: AppColors.textPrimary),
                                  SizedBox(width: 8),
                                  CommonText('Share', fontSize: 14),
                                ],
                              ),
                            ),
                          ],
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

}
