import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/view/vendor/menu/flows/vendor_menu_base.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_shipping.dart';

/// MenuShipping — Vendor Menu for the Shipping service type
class MenuShippingScreen extends StatelessWidget {
  const MenuShippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VendorMenuBase(
      serviceLabel: 'Shipper',
      serviceIcon: Icons.local_shipping_rounded,
      specialtyItems: [
        VendorMenuItem(
          icon: Icons.access_time_filled_rounded,
          title: 'My Availability',
          subtitle: 'Manage shipping routes & open dates',
          onTap: () => Get.to(() => const AvailabilityShippingScreen()),
        ),
        VendorMenuItem(
          icon: Icons.route_rounded,
          title: 'Routes & Regions',
          subtitle: 'Where you ship to and from',
          onTap: () => Get.snackbar('Coming Soon', 'Routes & Regions settings'),
        ),
        VendorMenuItem(
          icon: Icons.directions_car_filled_outlined,
          title: 'Rig & Capacity',
          subtitle: 'Trailer type and horse capacity',
          onTap: () => Get.snackbar('Coming Soon', 'Rig & Capacity settings'),
        ),
        VendorMenuItem(
          icon: Icons.verified_outlined,
          title: 'Insurance & DOT Docs',
          subtitle: 'Upload compliance documents',
          onTap: () => Get.snackbar('Coming Soon', 'Documents upload'),
        ),
      ],
    );
  }
}
