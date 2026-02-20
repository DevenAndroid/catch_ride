// clipping_booking_screens.dart
// All 6 booking screens for the CLIPPING service type

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_list_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_form_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_review_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_confirmed_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_denied_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_base.dart';

const _svc = VendorServiceConfig.clipping;

/// BookingListClipping — Vendor's list of upcoming clipping services
class BookingListClippingScreen extends StatelessWidget {
  const BookingListClippingScreen({super.key});
  @override
  Widget build(BuildContext context) => const BookingListBase(service: _svc);
}

/// BookingsRequestClipping — Trainer's form to request clipping
class BookingsRequestClippingScreen extends StatelessWidget {
  final String? vendorName;
  const BookingsRequestClippingScreen({super.key, this.vendorName});
  @override
  Widget build(BuildContext context) =>
      BookingRequestFormBase(service: _svc, prefilledVendorName: vendorName);
}

/// BookingRequestReviewClipping — Clipper reviews an incoming request
class BookingRequestReviewClippingScreen extends StatelessWidget {
  final VendorBooking booking;
  final bool acceptMode;
  const BookingRequestReviewClippingScreen({
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

/// BookingClipping — Full booking detail for a clipping booking
class BookingClippingScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingClippingScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      BookingDetailBase(booking: booking, service: _svc);
}
