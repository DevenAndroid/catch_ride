// clipping_booking_screens.dart
// All 6 booking screens for the CLIPPING service type

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_confirmed_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_denied_base.dart';

// Export the custom clipping-specific UI flows
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_clipping.dart';
export 'package:catch_ride/view/vendor/bookings/flows/booking_request_clipping.dart';
export 'package:catch_ride/view/vendor/bookings/flows/booking_request_review_clipping.dart';
export 'package:catch_ride/view/vendor/bookings/flows/booking_detail_clipping.dart';

const _svc = VendorServiceConfig.clipping;

/// BookingListClipping — Vendor's list of upcoming clipping services
class BookingListClippingScreen extends StatelessWidget {
  const BookingListClippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Requirements: Upcoming only, vendor specific only, links to bookingclipping
    final upcomingList = mockVendorBookings
        .where(
          (b) =>
              b.serviceType == VendorServiceConfig.clipping.type &&
              b.status == BookingStatus.confirmed,
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upcoming Bookings'),
        centerTitle: true,
        automaticallyImplyLeading: false, // In indexed stack
      ),
      body: upcomingList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 60,
                    color: AppColors.grey300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming bookings',
                    style: AppTextStyles.titleMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: upcomingList.length,
              itemBuilder: (context, index) {
                final b = upcomingList[index];
                return GestureDetector(
                  onTap: () => Get.to(() => BookingClippingScreen(booking: b)),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request from ${b.clientName}',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(b.location, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          '1 Horses, 2 Services',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// BookingRequestConfirmedClipping — Clipper confirms a booking request
class BookingRequestConfirmedClippingScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestConfirmedClippingScreen({
    super.key,
    required this.booking,
  });
  @override
  Widget build(BuildContext context) =>
      BookingConfirmedBase(booking: booking, service: _svc);
}

/// BookingRequestDeniedClipping — Clipper denies a booking request
class BookingRequestDeniedClippingScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestDeniedClippingScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      BookingDeniedBase(booking: booking, service: _svc);
}
