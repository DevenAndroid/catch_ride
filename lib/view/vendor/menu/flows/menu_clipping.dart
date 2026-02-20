import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/view/vendor/menu/flows/vendor_menu_base.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_clipping.dart';

/// MenuClipping — Vendor Menu for the Clipping service type
class MenuClippingScreen extends StatelessWidget {
  const MenuClippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VendorMenuBase(
      serviceLabel: 'Clipper',
      serviceIcon: Icons.content_cut_rounded,
      specialtyItems: [
        VendorMenuItem(
          icon: Icons.access_time_filled_rounded,
          title: 'My Availability',
          subtitle: 'Manage clipping schedule & travel area',
          onTap: () => Get.to(() => const AvailabilityClippingScreen()),
        ),
        VendorMenuItem(
          icon: Icons.tune_rounded,
          title: 'Clip Styles Offered',
          subtitle: 'Full body, trace, hunter clip, etc.',
          onTap: () => Get.snackbar('Coming Soon', 'Clip Styles settings'),
        ),
      ],
    );
  }
}
