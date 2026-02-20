// shipping_booking_screens.dart
// All 6 booking screens for the SHIPPING service type

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_list_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_form_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_review_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_confirmed_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_denied_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_base.dart';

const _svc = VendorServiceConfig.shipping;

/// BookingListShipping — Vendor's list of upcoming shipping services
class BookingListShippingScreen extends StatelessWidget {
  const BookingListShippingScreen({super.key});
  @override
  Widget build(BuildContext context) => const BookingListBase(service: _svc);
}

/// BookingsRequestShipping — Trainer's form to request shipping
class BookingsRequestShippingScreen extends StatelessWidget {
  final String? vendorName;
  const BookingsRequestShippingScreen({super.key, this.vendorName});
  @override
  Widget build(BuildContext context) =>
      BookingRequestFormBase(service: _svc, prefilledVendorName: vendorName);
}

/// BookingRequestReviewShipping — Shipping vendor reviews an incoming request
class BookingRequestReviewShippingScreen extends StatelessWidget {
  final VendorBooking booking;
  final bool acceptMode;
  const BookingRequestReviewShippingScreen({
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

/// BookingRequestConfirmedShipping — Shipping vendor confirms a booking request
class BookingRequestConfirmedShippingScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestConfirmedShippingScreen({
    super.key,
    required this.booking,
  });
  @override
  Widget build(BuildContext context) =>
      BookingConfirmedBase(booking: booking, service: _svc);
}

/// BookingRequestDeniedShipping — Shipping vendor denies a booking request
class BookingRequestDeniedShippingScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestDeniedShippingScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      BookingDeniedBase(booking: booking, service: _svc);
}

/// BookingShipping — Full booking detail for a shipping booking
class BookingShippingScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingShippingScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      BookingDetailBase(booking: booking, service: _svc);
}
