// groom_booking_screens.dart
// All 6 booking screens for the GROOM service type

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_list_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_form_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_review_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_confirmed_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_denied_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_base.dart';

const _svc = VendorServiceConfig.groom;

/// BookingListGroom — Vendor's list of upcoming grooming services
class BookingListGroomScreen extends StatelessWidget {
  const BookingListGroomScreen({super.key});
  @override
  Widget build(BuildContext context) => const BookingListBase(service: _svc);
}

/// BookingsRequestGroom — Trainer's form to request a groom
class BookingsRequestGroomScreen extends StatelessWidget {
  final String? vendorName;
  final VendorBooking? existingBooking;

  const BookingsRequestGroomScreen({
    super.key,
    this.vendorName,
    this.existingBooking,
  });

  @override
  Widget build(BuildContext context) => BookingRequestFormBase(
    service: _svc,
    prefilledVendorName: vendorName,
    existingBooking: existingBooking,
  );
}

/// BookingRequestReviewGroom — Groom vendor reviews an incoming request
class BookingRequestReviewGroomScreen extends StatelessWidget {
  final VendorBooking booking;
  final bool acceptMode;
  const BookingRequestReviewGroomScreen({
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

/// BookingRequestConfirmedGroom — Groom confirms a booking request
class BookingRequestConfirmedGroomScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestConfirmedGroomScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      BookingConfirmedBase(booking: booking, service: _svc);
}

/// BookingRequestDeniedGroom — Groom denies a booking request
class BookingRequestDeniedGroomScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestDeniedGroomScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      BookingDeniedBase(booking: booking, service: _svc);
}

/// BookingGroom — Full booking detail for a grooming booking
class BookingGroomScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingGroomScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) => BookingDetailBase(
    booking: booking,
    service: _svc,
    onEditReservation: () =>
        Get.to(() => BookingsRequestGroomScreen(existingBooking: booking)),
  );
}
