import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:get/get.dart';

class TrainerBookingsView extends StatefulWidget {
  const TrainerBookingsView({super.key});

  @override
  State<TrainerBookingsView> createState() => _TrainerBookingsViewState();
}

class _TrainerBookingsViewState extends State<TrainerBookingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilterIndex = 0; 

  final BookingController bookingController = Get.put(BookingController());
  final ProfileController profileController = Get.find<ProfileController>();

  final List<String> _filters = ['Accepted', 'Rejected', 'Pending', 'Canceled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_onTabChanged);
    _loadBookings();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadBookings();
    }
  }

  void _loadBookings() {
    final statusStr = _filters[_selectedFilterIndex];
    
    if (_tabController.index == 0) {
      // Received
      bookingController.fetchBookings(type: 'received', status: statusStr == 'Accepted' ? 'confirmed' : (statusStr == 'Canceled' ? 'cancelled' : statusStr.toLowerCase()));
    } else {
      // Sent
      bookingController.fetchBookings(type: 'sent', status: statusStr == 'Accepted' ? 'confirmed' : (statusStr == 'Canceled' ? 'cancelled' : statusStr.toLowerCase()));
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: CommonText(
            AppStrings.bookings,
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.secondary,
                indicatorWeight: 3,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Received'),
                  Tab(text: 'Sent'),
                ],
              ),
              Container(color: AppColors.border.withValues(alpha: 0.5), height: 1),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterSection(),
          
          Expanded(
            child: Obx(() {
              if (bookingController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (bookingController.bookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const CommonText(
                        'No bookings found',
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                );
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingsList(bookingController.receivedBookings),
                  _buildBookingsList(bookingController.sentBookings),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: List.generate(_filters.length, (index) {
            final isSelected = _selectedFilterIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilterIndex = index;
                  });
                  _loadBookings();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondary : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : AppColors.border,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: CommonText(
                      _filters[index],
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<BookingModel> bookings) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bookings.length + 1, // +1 for the bottom padding
      itemBuilder: (context, index) {
        if (index == bookings.length) {
          return const SizedBox(height: 120);
        }

        final booking = bookings[index];
        String displayStatus = booking.status.capitalizeFirst ?? booking.status;
        if (booking.status == 'confirmed') displayStatus = 'Accepted';
        if (booking.status == 'cancelled') displayStatus = 'Canceled';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildBookingCard(
            booking: booking,
            status: displayStatus,
          ),
        );
      },
    );
  }

  Widget _buildBookingCard({
    required BookingModel booking,
    required String status,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => TrainerHorseDetailView(
        horseId: booking.horseId,
        fromBooking: true,
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image with badge
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CommonImageView(
                      url: booking.horseName == 'Golden Hour' 
                          ? 'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'
                          : 'https://images.unsplash.com/photo-1598974357801-cbca100e65d3?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFABEFC6)),
                        ),
                        child: CommonText(
                          status,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF067647),
                        ),
                      ),
                    ),
                  ],
                ),
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
                        child: CommonText(
                          booking.horseName ?? 'Horse Name',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const CommonText(
                          'Trial',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CommonText(
                    'Trainer : ${booking.trainerName ?? 'Emily Johnson'}',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF98A2B3)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: CommonText(
                          booking.horseName == 'Golden Hour' 
                              ? 'Cypress, CA, United States' 
                              : 'Tampa, FL, United States',
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 15, color: Color(0xFF98A2B3)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: CommonText(
                          booking.date,
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
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
