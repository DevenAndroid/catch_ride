// bodywork_booking_screens.dart
// All 6 booking screens for the BODYWORK service type

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_list_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_form_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_review_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_confirmed_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_denied_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_base.dart';

const _svc = VendorServiceConfig.bodywork;

/// BookingListBodywork — Vendor's list of upcoming bodywork services
class BookingListBodyworkScreen extends StatelessWidget {
  const BookingListBodyworkScreen({super.key});
  @override
  Widget build(BuildContext context) => const BookingListBase(service: _svc);
}

/// BookingsRequestBodywork — Trainer's form to request a bodyworker
class BookingsRequestBodyworkScreen extends StatelessWidget {
  final String? vendorName;
  const BookingsRequestBodyworkScreen({super.key, this.vendorName});
  @override
  Widget build(BuildContext context) =>
      BookingRequestFormBase(service: _svc, prefilledVendorName: vendorName);
}

/// BookingRequestReviewBodywork — Bodywork vendor reviews an incoming request
class BookingRequestReviewBodyworkScreen extends StatelessWidget {
  final VendorBooking booking;
  final bool acceptMode;
  const BookingRequestReviewBodyworkScreen({
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

/// BookingRequestConfirmedBodywork — Bodywork vendor confirms a booking request
class BookingRequestConfirmedBodyworkScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestConfirmedBodyworkScreen({
    super.key,
    required this.booking,
  });
  @override
  Widget build(BuildContext context) =>
      BookingConfirmedBase(booking: booking, service: _svc);
}

/// BookingRequestDeniedBodywork — Bodywork vendor denies a booking request
class BookingRequestDeniedBodyworkScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestDeniedBodyworkScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      BookingDeniedBase(booking: booking, service: _svc);
}

/// BookingBodywork — Full booking detail for a bodywork booking
class BookingBodyworkScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingBodyworkScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      BookingDetailBase(booking: booking, service: _svc);
}
