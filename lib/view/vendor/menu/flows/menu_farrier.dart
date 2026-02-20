import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/view/vendor/menu/flows/vendor_menu_base.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_farrier.dart';

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
          icon: Icons.access_time_filled_rounded,
          title: 'My Availability',
          subtitle: 'Manage farrier schedule & regions',
          onTap: () => Get.to(() => const AvailabilityFarrierScreen()),
        ),
        VendorMenuItem(
          icon: Icons.build_circle_outlined,
          title: 'Services Offered',
          subtitle: 'Shoeing, trimming, corrective work',
          onTap: () => Get.snackbar('Coming Soon', 'Farrier Services settings'),
        ),
        VendorMenuItem(
          icon: Icons.verified_outlined,
          title: 'Certifications & Insurance',
          subtitle: 'AFA certification, liability docs',
          onTap: () => Get.snackbar('Coming Soon', 'Certifications upload'),
        ),
      ],
    );
  }
}
