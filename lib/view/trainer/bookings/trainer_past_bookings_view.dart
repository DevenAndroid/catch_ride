import 'package:catch_ride/utils/date_util.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:get/get.dart';
import '../../../constant/app_constants.dart';
import '../../../widgets/common_image_view.dart';
import '../../../widgets/common_text.dart';
import '../booking_request_view.dart';
import '../../vendor/booking_details_view.dart';

class TrainerPastBookingsView extends StatefulWidget {
  const TrainerPastBookingsView({super.key});

  @override
  State<TrainerPastBookingsView> createState() => _TrainerPastBookingsViewState();
}

class _TrainerPastBookingsViewState extends State<TrainerPastBookingsView> with SingleTickerProviderStateMixin {
  final BookingController bookingController = Get.put(BookingController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchData() {
    bookingController.fetchBookings(type: 'received', time: 'past');
    bookingController.fetchBookings(type: 'sent', time: 'past');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF344054),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Past Service & Trials',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF344054),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          indicatorWeight: 2,
          labelColor: Colors.black,
          unselectedLabelColor: const Color(0xFF98A2B3),
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            fontFamily: 'Outfit',
          ),
          tabs: const [
            Tab(text: 'Services'),
            Tab(text: 'Trials'),
          ],
        ),
      ),
      body: Obx(() {
        if (bookingController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final Map<String, BookingModel> uniqueMap = {};
        for (final b in bookingController.receivedBookings) {
          uniqueMap[b.id ?? ''] = b;
        }
        for (final b in bookingController.sentBookings) {
          uniqueMap[b.id ?? ''] = b;
        }
        
        final List<BookingModel> combinedBookings = uniqueMap.values.toList();

        // Sort by date (descending)
        combinedBookings.sort((a, b) => b.date.compareTo(a.date));

        final services = combinedBookings.where((b) => b.type != 'Trial').toList();
        final trials = combinedBookings.where((b) => b.type == 'Trial').toList();

        return TabBarView(
          controller: _tabController,
          children: [
            _buildBookingList(services),
            _buildBookingList(trials),
          ],
        );
      }),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            const CommonText(
              'No records found',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchData(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: bookings.length + 1,
        itemBuilder: (context, index) {
          if (index == bookings.length) {
            return const SizedBox(height: 120);
          }
          final booking = bookings[index];
          final status = (booking.status).toLowerCase();
          bool isCancelled = status == 'cancelled' || status == 'rejected' || status == 'declined';
          String displayStatus = isCancelled ? 'Cancelled' : 'Completed';
          String locationLabel = _locationLineForBooking(booking);

          return _buildBookingCard(
            booking: booking,
            status: displayStatus,
            locationLabel: locationLabel,
          );
        },
      ),
    );
  }

  String _locationLineForBooking(BookingModel booking) {
    final hl = booking.horseLocation;
    if (hl != null && hl.isNotEmpty && !_isServiceProviderBooking(booking)) {
      return hl;
    }
    return booking.location ?? '';
  }

  Widget _buildBookingCard({
    required BookingModel booking,
    required String status,
    required String locationLabel,
  }) {
    final isVendorBooking = _isServiceProviderBooking(booking);
    final profileController = Get.find<ProfileController>();

    return GestureDetector(
      onTap: () {
        if (isVendorBooking) {
          Get.to(() => BookingDetailsView(booking: booking))?.then((_) => _fetchData());
        } else {
          final bool isReceived = booking.trainerUserId == profileController.id || booking.trainerId == profileController.id;
          
          final String otherId = isReceived ? (booking.clientId ?? '') : (booking.trainerUserId ?? booking.trainerId ?? '');
          final String otherName = isReceived ? (booking.clientName ?? '') : (booking.trainerName ?? '');
          final String otherImage = isReceived ? (booking.clientImage ?? '') : (booking.trainerImage ?? '');
          final String myTeamId = isReceived ? (booking.trainerUserId ?? booking.trainerId ?? '') : (booking.clientId ?? '');

          Get.to(
            () => BookingRequestView(
              horseId: booking.horseId,
              fromBooking: true,
              bookingId: booking.id,
              bookingStatus: booking.status,
              otherId: otherId,
              otherName: otherName,
              otherImage: otherImage,
              myTeamId: myTeamId,
            ),
          )?.then((_) => _fetchData());
        }
      },
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
                      url: isVendorBooking
                          ? (profileController.user.value?.role == 'service_provider'
                              ? (booking.clientImage ?? booking.horseImage)
                              : (booking.vendorImage ?? booking.horseImage))
                          : booking.horseImage,
                      isUserImage: isVendorBooking,
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(booking.status),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: _getStatusTextColor(booking.status)
                                  .withValues(alpha: 0.2)),
                        ),
                        child: CommonText(
                          status,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusTextColor(booking.status),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CommonText(
                          isVendorBooking
                              ? (booking.vendorName ??
                                  booking.acceptedByName ??
                                  booking.trainerName ??
                                  'Service Provider')
                              : (booking.horseName ?? 'Horse Name'),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CommonText(
                              booking.type.capitalizeFirst ?? 'Trial',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  CommonText(
                    isVendorBooking
                        ? (booking.type.capitalizeFirst ?? 'Service')
                        : 'Trainer : ${booking.trainerName ?? ''}',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF98A2B3),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: CommonText(
                          locationLabel,
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
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF98A2B3),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: CommonText(
                          (booking.startDate != null) 
                            ? DateUtil.formatRange(booking.startDate, booking.endDate)
                            : DateUtil.formatRangeString(booking.date),
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (booking.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: booking.tags
                            .map(
                              (tag) => Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CommonText(
                                  tag,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3730A3),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isServiceProviderBooking(BookingModel booking) {
    if (booking.vendorBundleLines.isNotEmpty) return true;
    final vendorTypes = [
      'grooming',
      'braiding',
      'clipping',
      'farrier',
      'bodywork',
      'shipping',
      'transportation',
      'multi-service',
    ];
    return vendorTypes.contains(booking.type.toLowerCase());
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'confirmed':
      case 'accepted':
        return const Color(0xFFECFDF3); // Greenish
      case 'rejected':
      case 'declined':
      case 'cancelled':
        return const Color(0xFFFEF3F2); // Reddish
      case 'pending':
        return const Color(0xFFFFFAEB); // Yellowish
      default:
        return const Color(0xFFF2F4F7); // Grey
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'confirmed':
      case 'accepted':
        return const Color(0xFF067647); // Dark Green
      case 'rejected':
      case 'declined':
      case 'cancelled':
        return const Color(0xFFB42318); // Dark Red
      case 'pending':
        return const Color(0xFFB54708); // Dark Orange
      default:
        return const Color(0xFF344054); // Dark Grey
    }
  }
}
