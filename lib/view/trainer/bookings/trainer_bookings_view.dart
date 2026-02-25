import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';

class TrainerBookingsView extends StatefulWidget {
  const TrainerBookingsView({super.key});

  @override
  State<TrainerBookingsView> createState() => _TrainerBookingsViewState();
}

class _TrainerBookingsViewState extends State<TrainerBookingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilterIndex = 0; // 0: Accepted, 1: Rejected, 2: Completed

  final List<String> _filters = ['Accepted', 'Rejected', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          AppStrings.bookings,
          color: AppColors.textPrimary,
          fontSize: AppTextSizes.size22,
          fontWeight: FontWeight.bold,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              Container(color: AppColors.border, height: 1),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.textPrimary,
                indicatorWeight: 2,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: AppTextSizes.size16,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: AppTextSizes.size16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: AppStrings.received),
                  Tab(text: AppStrings.sent),
                ],
              ),
              Container(color: AppColors.border, height: 1),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildReceivedTab(),
            const Center(
              child: CommonText(
                AppStrings.sentBookings,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedTab() {
    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: CommonText(
                          _filters[index],
                          fontSize: AppTextSizes.size14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildBookingCard(
                name: 'Moonshadow',
                trainer: 'Emily Johnson',
                location: 'Cypress, CA, United States',
                date: '15 Mar - 20 Mar 2026',
                type: 'For Sale',
                status: 'Accepted',
                imageUrl: AppConstants.dummyImageUrl,
              ),
              const SizedBox(height: 12),
              _buildBookingCard(
                name: 'Starfire',
                trainer: 'Mark Lee',
                location: 'Tampa, FL, United States',
                date: '01 Apr - 07 Apr 2026',
                type: 'For Lease',
                status: 'Accepted',
                imageUrl: AppConstants.dummyImageUrl,
              ),
              const SizedBox(height: 12),
              _buildBookingCard(
                name: 'Whirlwind',
                trainer: 'Sarah Brown',
                location: 'Dallas, TX, United States',
                date: '10 May - 15 May 2026',
                type: 'Trail',
                status: 'Accepted',
                imageUrl: AppConstants.dummyImageUrl,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard({
    required String name,
    required String trainer,
    required String location,
    required String date,
    required String type,
    required String status,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const TrainerHorseDetailView(fromBooking: true),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badge
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 105,
                width: 105,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CommonImageView(url: imageUrl),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CommonText(
                          status,
                          fontSize: AppTextSizes.size12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CommonText(
                          name,
                          fontSize: AppTextSizes.size16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tabBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CommonText(
                          type,
                          fontSize: AppTextSizes.size12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CommonText(
                    'Trainer : $trainer',
                    fontSize: AppTextSizes.size14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CommonText(
                          location,
                          fontSize: AppTextSizes.size12,
                          color: AppColors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CommonText(
                          date,
                          fontSize: AppTextSizes.size12,
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
      ),
    );
  }
}
