// shipping_booking_screens.dart
// All 6 booking screens for the SHIPPING service type - Specialized implementation

import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';

// Import specialized implementations
import 'package:catch_ride/view/vendor/bookings/flows/bookings_list_shipping.dart'
    as list;
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_shipping.dart'
    as request;
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_review_shipping.dart'
    as review;
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_shipping.dart'
    as detail;
import 'package:catch_ride/view/vendor/bookings/flows/booking_result_shipping.dart'
    as result;

/// BookingListShipping — Vendor's list of upcoming shipping services
class BookingListShippingScreen extends StatelessWidget {
  const BookingListShippingScreen({super.key});
  @override
  Widget build(BuildContext context) => const list.BookingsListShippingScreen();
}

/// BookingsRequestShipping — Trainer's form to request shipping
class BookingsRequestShippingScreen extends StatelessWidget {
  final String? vendorName;
  const BookingsRequestShippingScreen({super.key, this.vendorName});
  @override
  Widget build(BuildContext context) =>
      request.BookingsRequestShippingScreen(vendorName: vendorName);
}

/// BookingRequestReviewShipping — Shipping vendor reviews an incoming request
class BookingRequestReviewShippingScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestReviewShippingScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      review.BookingRequestReviewShippingScreen(booking: booking);
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
      result.BookingResultShippingScreen(booking: booking, isConfirmed: true);
}

/// BookingRequestDeniedShipping — Shipping vendor denies a booking request
class BookingRequestDeniedShippingScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingRequestDeniedShippingScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      result.BookingResultShippingScreen(booking: booking, isConfirmed: false);
}

/// BookingShipping — Full booking detail for a shipping booking
class BookingShippingScreen extends StatelessWidget {
  final VendorBooking booking;
  const BookingShippingScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) =>
      detail.BookingShippingDetailScreen(booking: booking);
}
