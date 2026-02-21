// farrier_booking_screens.dart
// All 6 booking screens for the FARRIER service type

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_list_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_form_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_review_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_confirmed_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_denied_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_farrier.dart';

import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

const _svc = VendorServiceConfig.farrier;

/// BookingListFarrier — Vendor's list of upcoming farrier services
class BookingListFarrierScreen extends StatelessWidget {
  const BookingListFarrierScreen({super.key});
  @override
  Widget build(BuildContext context) => const BookingListBase(service: _svc);
}

/// BookingsRequestFarrier — Trainer's form to request a farrier with detailed availability view
class BookingsRequestFarrierScreen extends StatelessWidget {
  final String? vendorName;
  const BookingsRequestFarrierScreen({super.key, this.vendorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Farrier'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Availability Header (Visible to Trainers during request)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppColors.deepNavy.withOpacity(0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.event_available,
                        color: AppColors.deepNavy,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vendor Availability',
                        style: AppTextStyles.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _availabilityBlock('Mon-Fri (Full Day)', 'Ocala, Wellington'),
                  _availabilityBlock(
                    'Mar 15 - Apr 15 (Mornings)',
                    'Tryon, Lexington',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Note: "Must align with existing route in Wellington."',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            // The actual form
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height,
              ), // simple nesting
              child: BookingRequestFormBase(
                service: _svc,
                prefilledVendorName: vendorName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _availabilityBlock(String time, String locs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.successGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$time: ',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
                children: [
                  TextSpan(
                    text: locs,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// BookingRequestReviewFarrier — Farrier reviews an incoming request
class BookingRequestReviewFarrierScreen extends StatelessWidget {
  final VendorBooking booking;
  final bool acceptMode;
  const BookingRequestReviewFarrierScreen({
    super.key,
    required this.booking,
    this.acceptMode = false,
  });
  @override
  Widget build(BuildContext context) => BookingRequestReviewBase(
    booking: booking,
    service: _svc,
    acceptMode: acceptMode,
  );
}

/// BookingRequestConfirmedFarrier — Farrier confirms a booking request
class BookingRequestConfirmedFarrierScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestConfirmedFarrierScreen({
    super.key,
    required this.booking,
  });
  @override
  Widget build(BuildContext context) =>
      BookingConfirmedBase(booking: booking, service: _svc);
}

/// BookingRequestDeniedFarrier — Farrier denies a booking request
class BookingRequestDeniedFarrierScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestDeniedFarrierScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      BookingDeniedBase(booking: booking, service: _svc);
}

/// BookingFarrier — Full booking detail for a farrier booking
class BookingFarrierScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingFarrierScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      BookingDetailFarrierView(booking: booking);
}
