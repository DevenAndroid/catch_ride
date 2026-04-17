import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/controllers/explore_controller.dart';
import 'package:catch_ride/view/trainer/home/search_filter_overlay.dart';
import 'package:catch_ride/view/trainer/home/filter_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:catch_ride/view/vendor/vendor_details_view.dart';
import 'package:catch_ride/widgets/horse_card.dart';
import '../../../../controllers/booking_controller.dart';
import '../../../models/horse_model.dart';
import '../../../models/vendor_model.dart';
import '../../../utils/date_util.dart';
import '../../../widgets/common_image_view.dart';

class TrainerExploreView extends StatefulWidget {
  const TrainerExploreView({super.key});

  @override
  State<TrainerExploreView> createState() => _TrainerExploreViewState();
}

class _TrainerExploreViewState extends State<TrainerExploreView> {
  final ExploreController controller = Get.put(ExploreController());
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'isSvg': false},

    {'name': 'Hunter', 'icon': 'assets/icons/hunter.svg', 'isSvg': true},
    {'name': 'Jumper', 'icon': "assets/icons/jumper.svg", 'isSvg': true},
    {
      'name': 'Equitation',
      'icon': 'assets/icons/equitation.svg',
      'isSvg': true,
    },
    {'name': 'Services', 'icon': 'assets/icons/vendor.svg', 'isSvg': true},
  ];
  @override
  void initState() {
    super.initState();
    controller.fetchHorses();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.fetchHorses(isLoadMore: true);
      }
    });
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilters(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await controller.fetchHorses();
                },
                child: Obx(() {
                  if (controller.isLoading.value && controller.horses.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Reactive trigger for booking status changes
                  final bookingController = Get.put(BookingController());
                  final _ = bookingController.bookings.length;

                  final bool isVendors =
                      controller.selectedDiscipline.value == 'Services';

                  if (!isVendors && controller.horses.isEmpty) {
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CommonText(
                              'No horses found',
                              fontSize: AppTextSizes.size16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (isVendors && controller.vendors.isEmpty) {
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 100),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CommonText(
                              'No service providers found',
                              fontSize: AppTextSizes.size16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200) {
                        controller.fetchHorses(isLoadMore: true);
                      }
                      // ALlow the scroll notification to bubble up to the RefreshIndicator
                      return false; 
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        if (isVendors && !controller.isSearchActive && controller.isGridView.value)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            sliver: SliverMasonryGrid.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              itemBuilder: (context, index) {
                                final vendor = controller.vendors[index];
                                return _buildMasonryVendorCard(vendor, index);
                              },
                              childCount: controller.vendors.length,
                            ),
                          )
                        else if (isVendors)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 12),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final vendor = controller.vendors[index];
                                  return _buildVendorCard(vendor: vendor);
                                },
                                childCount: controller.vendors.length,
                              ),
                            ),
                          )
                        else if (controller.isSearchActive)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 12),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final horse = controller.horses[index];
                                  final isRequested =
                                      Get.put(BookingController()).bookings.any(
                                            (b) =>
                                                b.horseId == horse.id &&
                                                b.status.toLowerCase() ==
                                                    'pending',
                                          );

                                  return HorseCard(
                                    horse: horse,
                                    isRequested: isRequested,
                                    onTap: () => Get.to(
                                      () => TrainerHorseDetailView(
                                          horse: horse),
                                    ),
                                  );
                                },
                                childCount: controller.horses.length,
                              ),
                            ),
                          )
                        else if (controller.isGridView.value)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            sliver: SliverMasonryGrid.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              itemBuilder: (context, index) {
                                final horse = controller.horses[index];
                                return _buildMasonryHorseCard(horse, index);
                              },
                              childCount: controller.horses.length,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final horse = controller.horses[index];
                                  final isRequested =
                                      Get.put(BookingController()).bookings.any(
                                            (b) =>
                                                b.horseId == horse.id &&
                                                b.status.toLowerCase() ==
                                                    'pending',
                                          );

                                  return HorseCard(
                                    horse: horse,
                                    isRequested: isRequested,
                                    onTap: () => Get.to(
                                      () => TrainerHorseDetailView(
                                          horse: horse),
                                    ),
                                  );
                                },
                                childCount: controller.horses.length,
                              ),
                            ),
                          ),
                        if (controller.isLoadMoreLoading.value)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      ],
                    ),
                  );
                }),
              ),
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
      child: Row(
        children: [
          Expanded(
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
                  () => const SearchFilterOverlay(),
                  fullscreenDialog: true,
                  opaque: false,
                ),
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.search_rounded,
                      size: 28,
                      color: Color(0xFF101828),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        String mainText = "How can we help you?";
                        String subText = "Search horses, services and circuits";

                        if (controller.isSearchActive) {
                          if (controller.showVenue.value.isNotEmpty) {
                            mainText = controller.showVenue.value;
                          } else if (controller.location.value.isNotEmpty) {
                            mainText = controller.location.value;
                          } else if (controller.searchQuery.value.isNotEmpty) {
                            mainText = controller.searchQuery.value;
                          }

                          if (controller.startDate.value != null &&
                              controller.endDate.value != null) {
                            subText = DateUtil.formatRange(
                              controller.startDate.value,
                              controller.endDate.value,
                            );
                          } else {
                            subText = "Refined Search";
                          }
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              mainText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF101828),
                            ),
                            CommonText(
                              subText,
                              fontSize: 12,
                              color: const Color(0xFF667085),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
             onTap: () {
               showModalBottomSheet(
                 context: context,
                 isScrollControlled: true,
                 backgroundColor: Colors.transparent,
                 builder: (context) => SizedBox(
                   height: MediaQuery.of(context).size.height * 0.85,
                   child: const FilterBottomSheet()
                 ),
               );
             },
             child: Container(
               padding: const EdgeInsets.all(8),
               child: const Icon(
                 Icons.tune_rounded,
                 size: 28,
                 color: Color(0xFF101828),
               )
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Obx(
      () => Container(
        height: 90,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_categories.length, (index) {
            final cat = _categories[index];
            final isSelected =
                controller.selectedDiscipline.value == cat['name'];

            return GestureDetector(
              onTap: () {
                controller.updateDiscipline(cat['name']);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEFF4FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: cat['isSvg']
                        ? SvgPicture.asset(
                            cat['icon'],
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF00083B),
                              BlendMode.srcIn,
                            ),
                          )
                        : Icon(
                            cat['icon'] as IconData,
                            size: 26,
                            color: const Color(0xFF00083B),
                          ),
                  ),
                  const SizedBox(height: 6),
                  CommonText(
                    cat['name'],
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF101828)
                        : const Color(0xFF667085),
                  ),
                  const SizedBox(height: 8),
                  if (isSelected)
                    Container(
                      width: 45,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B235E),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  else
                    const SizedBox(height: 3),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildVendorCard({required VendorModel vendor}) {
    return GestureDetector(
      onTap: () => Get.to(() => const VendorDetailsView(), arguments: {'id': vendor.id}),
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
              child: CommonImageView(
                url: vendor.profilePhoto,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                isUserImage: true,
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
                  if (vendor.location != null && vendor.location!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: CommonText(
                            vendor.location!,
                            fontSize: 14,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      CommonText(
                        vendor.serviceType.isEmpty ||
                                vendor.serviceType.toLowerCase() == 'other'
                            ? 'Service Provider'
                            : vendor.serviceType,
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (vendor.serviceAvailability.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        CommonText(
                          vendor.serviceAvailability.first.startDate ==
                                  vendor.serviceAvailability.first.endDate
                              ? (vendor.serviceAvailability.first.startDate ?? '')
                              : '${vendor.serviceAvailability.first.startDate ?? ''} - ${vendor.serviceAvailability.first.endDate ?? ''}',
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

  Widget _buildMasonryHorseCard(HorseModel horse, int index) {
    // Generate varying heights to create the masonry effect for 3 columns
    final double cardHeight = (index % 5 == 0)
        ? 260
        : (index % 4 == 0)
        ? 180
        : (index % 3 == 0)
        ? 240
        : (index % 2 == 0)
        ? 200
        : 220;

    return GestureDetector(
      onTap: () => Get.to(() => TrainerHorseDetailView(horse: horse)),
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CommonImageView(
                url: horse.images.isNotEmpty
                    ? horse.images[0]
                    : horse.photo,
                fit: BoxFit.cover,
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 32, 12, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Text(
                    horse.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasonryVendorCard(VendorModel vendor, int index) {
    // Generate varying heights to create the masonry effect for 3 columns
    final double cardHeight = (index % 5 == 0)
        ? 260
        : (index % 4 == 0)
        ? 180
        : (index % 3 == 0)
        ? 240
        : (index % 2 == 0)
        ? 200
        : 220;

    return GestureDetector(
      onTap: () => Get.to(() => const VendorDetailsView(), arguments: {'id': vendor.id}),
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CommonImageView(
                url: vendor.profilePhoto,
                fit: BoxFit.cover,
                isUserImage: true,
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 32, 12, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Text(
                    vendor.fullName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
