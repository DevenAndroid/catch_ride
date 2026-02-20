import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/view/vendor/menu/flows/vendor_menu_base.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_bodywork.dart';

/// MenuBodywork — Vendor Menu for the Bodywork service type
class MenuBodyworkScreen extends StatelessWidget {
  const MenuBodyworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VendorMenuBase(
      serviceLabel: 'Bodyworker',
      serviceIcon: Icons.spa_rounded,
      specialtyItems: [
        VendorMenuItem(
          icon: Icons.access_time_filled_rounded,
          title: 'My Availability',
          subtitle: 'Manage appointment schedule & travel',
          onTap: () => Get.to(() => const AvailabilityBodyworkScreen()),
        ),
        VendorMenuItem(
          icon: Icons.healing_rounded,
          title: 'Modalities Offered',
          subtitle: 'Massage, chiro, acupuncture, etc.',
          onTap: () => Get.snackbar('Coming Soon', 'Modalities settings'),
        ),
        VendorMenuItem(
          icon: Icons.verified_outlined,
          title: 'Certifications',
          subtitle: 'Upload & manage your credentials',
          onTap: () => Get.snackbar('Coming Soon', 'Certifications upload'),
        ),
      ],
    );
  }
}
