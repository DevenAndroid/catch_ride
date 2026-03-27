import 'package:catch_ride/utils/date_util.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:get/get.dart';
import '../../../constant/app_constants.dart';
import '../../../widgets/common_image_view.dart';
import '../../../widgets/common_text.dart';

class TrainerPastBookingsView extends StatefulWidget {
  const TrainerPastBookingsView({super.key});

  @override
  State<TrainerPastBookingsView> createState() =>
      _TrainerPastBookingsViewState();
}

class _TrainerPastBookingsViewState extends State<TrainerPastBookingsView> {
  final BookingController bookingController = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    // Fetch only past bookings for the trainer
    bookingController.fetchBookings(type: 'received', time: 'past');
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
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Past Service & Trials',
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Obx(() {
        if (bookingController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final pastBookings = bookingController.receivedBookings
            .where((b) => b.status != 'pending')
            .toList();

        if (pastBookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 64,
                  color: AppColors.textSecondary.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                const CommonText(
                  'No past records found',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: pastBookings.length,
          itemBuilder: (context, index) {
            return _buildPastBookingCard(pastBookings[index]);
          },
        );
      }),
    );
  }

  Widget _buildPastBookingCard(BookingModel booking) {
    String displayStatus = booking.status.capitalizeFirst ?? booking.status;
    if (booking.status == 'confirmed' || booking.status == 'completed')
      displayStatus = 'Accepted';
    if (booking.status == 'cancelled') displayStatus = 'Canceled';
    if (booking.status == 'rejected') displayStatus = 'Rejected';

    Color statusColor = const Color(0xFF667085);
    Color statusBg = const Color(0xFFF2F4F7);

    if (booking.status == 'completed' || booking.status == 'confirmed') {
      statusColor = const Color(0xFF067647);
      statusBg = const Color(0xFFECFDF3);
    } else if (booking.status == 'cancelled' || booking.status == 'rejected') {
      statusColor = const Color(0xFFB42318);
      statusBg = const Color(0xFFFEF3F2);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 90,
              width: 90,
              child: CommonImageView(
                url: booking.horseImage,
              ),

            ),
          ),
          const SizedBox(width: 16),
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
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: CommonText(
                        displayStatus,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CommonText(
                  booking.type,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF131313).withOpacity(0.6),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF98A2B3),
                    ),
                    const SizedBox(width: 4),
                    CommonText(
                      DateUtil.formatDisplayDate(booking.date),
                      fontSize: 13,
                      color: const Color(0xFF667085),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CommonText(
                  'Client: ${booking.clientName ?? 'N/A'}',
                  fontSize: 13,
                  color: const Color(0xFF667085),
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
    );
  }
}
