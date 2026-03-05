import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/controllers/explore_controller.dart';
import 'package:catch_ride/view/trainer/home/search_filter_overlay.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrainerExploreView extends StatefulWidget {
  const TrainerExploreView({super.key});

  @override
  State<TrainerExploreView> createState() => _TrainerExploreViewState();
}

class _TrainerExploreViewState extends State<TrainerExploreView> {
  final ExploreController controller = Get.put(ExploreController());
  bool _isGridView = false;
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'isSvg': false},
    {'name': 'Hunter', 'icon': 'assets/icons/hunter.svg', 'isSvg': true},
    {'name': 'Jumper', 'icon': 'assets/icons/jumper.svg', 'isSvg': true},
    {'name': 'Equitation', 'icon': 'assets/icons/equitation.svg', 'isSvg': true},
    {'name': 'Vendors', 'icon': 'assets/icons/vendor.svg', 'isSvg': true},
  ];

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

                final bool isVendors = controller.selectedDiscipline.value == 'Vendors';

                if (isVendors) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5, // Dummy vendor count for now
                    itemBuilder: (context, index) {
                      return _buildVendorCard(
                        name: 'Ria Gabriela',
                        location: 'Wellington, FL',
                        specialties: 'Shipping, Braider',
                        dates: '10 Jan - 18 Jan 2026',
                        imageUrl: AppConstants.dummyImageUrl,
                      );
                    },
                  );
                }

                if (_isGridView) {
                  return MasonryGridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: controller.horses.length,
                    itemBuilder: (context, index) {
                      final horse = controller.horses[index];
                      final heightFactor = (index % 3 == 0) ? 1.5 : (index % 2 == 0) ? 1.2 : 1.0;
                      
                      return GestureDetector(
                        onTap: () => Get.to(() => TrainerHorseDetailView(horse: horse)),
                        child: _buildPostCard(
                          name: horse.name,
                          imageUrl: horse.photo ?? AppConstants.dummyImageUrl,
                          height: 180 * heightFactor,
                        ),
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.horses.length,
                  itemBuilder: (context, index) {
                    final horse = controller.horses[index];
                    final show = horse.showAvailability.isNotEmpty ? horse.showAvailability.first : null;
                    return GestureDetector(
                      onTap: () => Get.to(() => TrainerHorseDetailView(horse: horse)),
                      child: _buildListViewCard(
                        name: horse.name,
                        discipline: horse.displayDiscipline,
                        venue: show?.showVenue ?? 'Unknown Venue',
                        dates: show != null ? '${show.startDate} - ${show.endDate}' : 'Availability not listed',
                        location: horse.location ?? 'Location not specified',
                        imageUrl: horse.photo ?? AppConstants.dummyImageUrl,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(); // No header in the new UI design
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.to(
                () => const SearchFilterOverlay(),
                transition: Transition.fadeIn,
                fullscreenDialog: true,
                opaque: false,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 28,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => Get.to(
                  () => const SearchFilterOverlay(),
                  transition: Transition.fadeIn,
                  fullscreenDialog: true,
                  opaque: false,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CommonText(
                      "How can we help you?",
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    CommonText(
                      "Search horses, vendors and circuits",
                      fontSize: AppTextSizes.size12,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Obx(() => SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_categories.length, (index) {
          final cat = _categories[index];
          final isSelected = controller.selectedDiscipline.value == cat['name'];
          
          return GestureDetector(
            onTap: () {
              controller.updateDiscipline(cat['name']);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: cat['isSvg']
                          ? SvgPicture.asset(
                              cat['icon'],
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                isSelected ? AppColors.primary : AppColors.textSecondary,
                                BlendMode.srcIn,
                              ),
                            )
                          : Icon(
                              cat['icon'] as IconData,
                              size: 24,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CommonText(
                  cat['name'],
                  fontSize: AppTextSizes.size12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        }),
      ),
    ));
  }

  Widget _buildPostCard({
    required String name,
    required String imageUrl,
    required double height,
  }) {
    return Container(
      height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.5),
              ],
              stops: const [0.7, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                name,
                color: Colors.white,
                fontSize: AppTextSizes.size14,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
    );
  }
 Widget _buildListViewCard({
    required String name,
    required String discipline,
    required String venue,
    required String dates,
    required String location,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontFamily: 'Outfit',
                            ),
                            children: [
                              TextSpan(text: name),
                              TextSpan(
                                text: ' • $discipline',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const CommonText(
                          'Lease',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CommonText(
                    'Venue - $venue',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CommonText(
                          dates,
                          fontSize: 12,
                          maxLines: 1,
                          color: AppColors.textSecondary,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CommonText(
                          location,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
 Widget _buildVendorCard({
    required String name,
    required String location,
    required String specialties,
    required String dates,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: CachedNetworkImageProvider(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  name,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    CommonText(
                      location,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.stars_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    CommonText(
                      specialties,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    CommonText(
                      dates,
                      fontSize: 14,
                      color: AppColors.textSecondary,
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
}
