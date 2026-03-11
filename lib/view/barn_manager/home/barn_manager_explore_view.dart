import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/view/barn_manager/home/barn_manager_horse_detail_view.dart';
import 'package:catch_ride/controllers/explore_controller.dart';
import 'package:catch_ride/view/barn_manager/home/barn_manager_search_filter_overlay.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:catch_ride/view/barn_manager/vendor/barn_manager_vendor_details_view.dart';
import 'package:catch_ride/widgets/horse_card.dart';
import '../../../../controllers/booking_controller.dart';
import '../../../models/vendor_model.dart';
import '../../trainer/home/search_filter_overlay.dart';

class BarnManagerExploreView extends StatefulWidget {
  const BarnManagerExploreView({super.key});

  @override
  State<BarnManagerExploreView> createState() => _BarnManagerExploreViewState();
}

class _BarnManagerExploreViewState extends State<BarnManagerExploreView> {
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
                final bookingController = Get.put(BookingController());
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.horses.length,
                  itemBuilder: (context, index) {
                    final horse = controller.horses[index];
                    final isRequested = Get.find<BookingController>().bookings.any((b) => b.horseId == horse.id && b.status.toLowerCase() == 'pending');

                    return HorseCard(
                      horse: horse,
                      isRequested: isRequested,
                      onTap: () => Get.to(() => BarnManagerHorseDetailView(horse: horse)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFEAECF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => Get.to(
            () => const BarnManagerSearchFilterOverlay(),
            transition: Transition.fadeIn,
            fullscreenDialog: true,
            opaque: false,
          ),
          borderRadius: BorderRadius.circular(30),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search_rounded, size: 28, color: Color(0xFF101828)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CommonText(
                      "Bruce's Field",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828),
                    ),
                    CommonText(
                      "10 Jan - 18 Jan 2026",
                      fontSize: 12,
                      color: Color(0xFF667085),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Obx(() => Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
      ),
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
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEAEEFF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: cat['isSvg']
                      ? SvgPicture.asset(
                          cat['icon'],
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            isSelected ? const Color(0xFF00083B) : const Color(0xFF667085),
                            BlendMode.srcIn,
                          ),
                        )
                      : Icon(
                          cat['icon'] as IconData,
                          size: 24,
                          color: isSelected ? const Color(0xFF00083B) : const Color(0xFF667085),
                        ),
                ),
                const SizedBox(height: 6),
                CommonText(
                  cat['name'],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF101828) : const Color(0xFF667085),
                ),
                const SizedBox(height: 8),
                if (isSelected)
                  Container(
                    width: 40,
                    height: 2,
                    color: const Color(0xFF1B235E),
                  )
                else
                  const SizedBox(height: 2),
              ],
            ),
          );
        }),
      ),
    ));
  }

  Widget _buildVendorCard({
    required VendorModel vendor,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => BarnManagerVendorDetailsView(vendor: vendor)),
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
