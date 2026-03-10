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
import 'package:catch_ride/view/vendor/vendor_details_view.dart';
import '../../../../controllers/booking_controller.dart';
import '../../../models/vendor_model.dart';

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
    {'name': 'Services', 'icon': 'assets/icons/vendor.svg', 'isSvg': true},
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

                // Reactive trigger for booking status changes
                final bookingController = Get.find<BookingController>();
                final _ = bookingController.bookings.length;

                final bool isVendors = controller.selectedDiscipline.value == 'Services';

                if (isVendors && controller.vendors.isEmpty) {
                  return const Center(
                    child: CommonText(
                      'No vendors available',
                      fontSize: AppTextSizes.size16,
                      color: AppColors.textSecondary,
                    ),
                  );
                }

                if (!isVendors && controller.horses.isEmpty) {
                  return const Center(
                    child: CommonText(
                      'No horses found',
                      fontSize: AppTextSizes.size16,
                      color: AppColors.textSecondary,
                    ),
                  );
                }

                if (isVendors) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.vendors.length,
                    itemBuilder: (context, index) {
                      final vendor = controller.vendors[index];
                      return _buildVendorCard(
                        vendor: vendor,
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
                      
                      final isRequested = Get.find<BookingController>().bookings.any((b) => b.horseId == horse.id && b.status.toLowerCase() == 'pending');
                      return GestureDetector(
                        onTap: () => Get.to(() => TrainerHorseDetailView(horse: horse)),
                        child: _buildPostCard(
                          name: horse.name,
                          imageUrl: horse.photo ?? AppConstants.dummyImageUrl,
                          height: 180 * heightFactor,
                          isRequested: isRequested,
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
                    
                    final isRequested = Get.find<BookingController>().bookings.any((b) => b.horseId == horse.id && b.status.toLowerCase() == 'pending');

                    return GestureDetector(
                      onTap: () => Get.to(() => TrainerHorseDetailView(horse: horse)),
                      child: _buildListViewCard(
                        name: horse.name,
                        discipline: horse.displayDiscipline,
                        venue: show?.showVenue ?? 'Unknown Venue',
                        dates: show != null ? '${show.startDate} - ${show.endDate}' : 'Availability not listed',
                        location: horse.location ?? 'Location not specified',
                        imageUrl: horse.photo ?? AppConstants.dummyImageUrl,
                        isRequested: isRequested,
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
          color: AppColors.cardColor,
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
    bool isRequested = false,
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
              if (isRequested)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const CommonText(
                    'Requested',
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
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
    bool isRequested = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
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
                          color: isRequested ? Colors.orange.shade50 : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CommonText(
                          isRequested ? 'Requested' : 'Lease',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isRequested ? Colors.orange : AppColors.textSecondary,
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
    required VendorModel vendor,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => VendorDetailsView(vendor: vendor)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Square Image with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: vendor.profilePhoto ?? AppConstants.dummyImageUrl,
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
                  const SizedBox(height: 4),
                  CommonText(
                    vendor.fullName,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      CommonText(
                        vendor.location ?? 'Wellington, FL',
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      CommonText(
                        vendor.serviceType,
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      CommonText(
                        vendor.serviceAvailability.isNotEmpty 
                          ? '${vendor.serviceAvailability.first.startDate} - ${vendor.serviceAvailability.first.endDate}'
                          : '10 Jan - 18 Jan 2026',
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
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
