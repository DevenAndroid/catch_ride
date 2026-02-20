import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/view/vendor/menu/flows/vendor_menu_base.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_groom.dart';

/// MenuGroom — Vendor Menu for the Grooming service type
class MenuGroomScreen extends StatelessWidget {
  const MenuGroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VendorMenuBase(
      serviceLabel: 'Groomer',
      serviceIcon: Icons.cleaning_services_rounded,
      specialtyItems: [
        VendorMenuItem(
          icon: Icons.access_time_filled_rounded,
          title: 'My Availability',
          subtitle: 'Manage show schedule & service area',
          onTap: () => Get.to(() => const AvailabilityGroomScreen()),
        ),
        VendorMenuItem(
          icon: Icons.checklist_rounded,
          title: 'Service Checklist',
          subtitle: 'Full-day, half-day, show prep options',
          onTap: () =>
              Get.snackbar('Coming Soon', 'Service Checklist settings'),
        ),
      ],
    );
  }
}
