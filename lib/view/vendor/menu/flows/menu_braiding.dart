import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/view/vendor/menu/flows/vendor_menu_base.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_braiding.dart';

/// MenuBraiding — Vendor Menu for the Braiding service type
class MenuBraidingScreen extends StatelessWidget {
  const MenuBraidingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VendorMenuBase(
      serviceLabel: 'Braider',
      serviceIcon: Icons.auto_awesome_rounded,
      specialtyItems: [
        VendorMenuItem(
          icon: Icons.access_time_filled_rounded,
          title: 'My Availability',
          subtitle: 'Manage braiding schedule & shows',
          onTap: () => Get.to(() => const AvailabilityBraidingScreen()),
        ),
        VendorMenuItem(
          icon: Icons.format_list_bulleted_rounded,
          title: 'Braid Styles Offered',
          subtitle: 'Running, button, French braids, etc.',
          onTap: () => Get.snackbar('Coming Soon', 'Braid Styles settings'),
        ),
      ],
    );
  }
}
