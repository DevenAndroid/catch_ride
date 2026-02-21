// braiding_booking_screens.dart
// All 6 booking screens for the BRAIDING service type

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_list_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_braiding.dart'
    as booking_req;
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_review_braiding.dart'
    as booking_rev;
import 'package:catch_ride/view/vendor/bookings/flows/booking_confirmed_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_denied_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_braiding.dart'
    as booking_det;

const _svc = VendorServiceConfig.braiding;

/// BookingListBraider — Vendor's list of upcoming braiding services
class BookingListBraiderScreen extends StatelessWidget {
  const BookingListBraiderScreen({super.key});
  @override
  Widget build(BuildContext context) => const BookingListBase(service: _svc);
}

/// BookingsRequestBraiding — Trainer's form to request a braider
class BookingsRequestBraidingScreen extends StatelessWidget {
  final String? vendorName;
  const BookingsRequestBraidingScreen({super.key, this.vendorName});
  @override
  Widget build(BuildContext context) =>
      booking_req.BookingsRequestBraidingScreen(vendorName: vendorName);
}

/// BookingRequestReviewBraider — Braider reviews an incoming request
class BookingRequestReviewBraiderScreen extends StatelessWidget {
  final VendorBooking booking;
  final bool acceptMode;
  const BookingRequestReviewBraiderScreen({
    super.key,
    required this.booking,
    this.acceptMode = false,
  });
  @override
  Widget build(BuildContext context) =>
      booking_rev.BookingRequestReviewBraiderScreen(
        booking: booking,
        acceptMode: acceptMode,
      );
}

/// BookingRequestConfirmedBraider — Braider confirms a booking request
class BookingRequestConfirmedBraiderScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestConfirmedBraiderScreen({
    super.key,
    required this.booking,
  });
  @override
  Widget build(BuildContext context) =>
      BookingConfirmedBase(booking: booking, service: _svc);
}

/// BookingRequestDeniedBraider — Braider denies a booking request
class BookingRequestDeniedBraiderScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestDeniedBraiderScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      BookingDeniedBase(booking: booking, service: _svc);
}

/// BookingBraider — Full booking detail for a braiding booking
class BookingBraiderScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingBraiderScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      booking_det.BookingBraiderScreen(booking: booking);
}
