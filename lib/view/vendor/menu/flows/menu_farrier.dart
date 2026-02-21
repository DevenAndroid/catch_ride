import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/view/vendor/menu/flows/vendor_menu_base.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_farrier.dart';
import 'package:catch_ride/view/vendor/services/services_rates_farrier.dart';
import 'package:catch_ride/view/vendor/clients/past_clients_farrier.dart';
import 'package:catch_ride/view/vendor/compliance/operations_compliance_farrier.dart';
import 'package:catch_ride/view/vendor/bookings/flows/farrier_booking_screens.dart';

/// MenuFarrier — Vendor Menu for the Farrier service type
class MenuFarrierScreen extends StatelessWidget {
  const MenuFarrierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VendorMenuBase(
      serviceLabel: 'Farrier',
      serviceIcon: Icons.handyman_rounded,
      specialtyItems: [
        VendorMenuItem(
          icon: Icons.calendar_month_outlined,
          title: 'Upcoming Clients',
          subtitle: 'View your scheduled bookings',
          onTap: () => Get.to(() => const BookingListFarrierScreen()),
        ),
        VendorMenuItem(
          icon: Icons.access_time_filled_rounded,
          title: 'My Availability',
          subtitle: 'Manage farrier schedule & regions',
          onTap: () => Get.to(() => const AvailabilityFarrierScreen()),
        ),
        VendorMenuItem(
          icon: Icons.build_circle_outlined,
          title: 'Services & Rates',
          subtitle: 'Update shoeing and trimming prices',
          onTap: () => Get.to(() => const ServicesRatesFarrierScreen()),
        ),
        VendorMenuItem(
          icon: Icons.people_outline_rounded,
          title: 'Past Clients',
          subtitle: 'Booking history and coordination',
          onTap: () => Get.to(() => PastClientsFarrierScreen()),
        ),
        VendorMenuItem(
          icon: Icons.verified_user_outlined,
          title: 'Operations & Compliance',
          subtitle: 'Service status, insurance, and safety',
          onTap: () => Get.to(() => const OperationsComplianceFarrierScreen()),
        ),
      ],
    );
  }
}
