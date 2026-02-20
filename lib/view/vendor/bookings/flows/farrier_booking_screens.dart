// farrier_booking_screens.dart
// All 6 booking screens for the FARRIER service type

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_list_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_form_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_review_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_confirmed_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_denied_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_base.dart';

const _svc = VendorServiceConfig.farrier;

/// BookingListFarrier — Vendor's list of upcoming farrier services
class BookingListFarrierScreen extends StatelessWidget {
  const BookingListFarrierScreen({super.key});
  @override
  Widget build(BuildContext context) => const BookingListBase(service: _svc);
}

/// BookingsRequestFarrier — Trainer's form to request a farrier
class BookingsRequestFarrierScreen extends StatelessWidget {
  final String? vendorName;
  const BookingsRequestFarrierScreen({super.key, this.vendorName});
  @override
  Widget build(BuildContext context) =>
      BookingRequestFormBase(service: _svc, prefilledVendorName: vendorName);
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
      BookingDetailBase(booking: booking, service: _svc);
}
