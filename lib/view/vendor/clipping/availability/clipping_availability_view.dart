import 'package:catch_ride/view/vendor/groom/availability/availability_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClippingAvailabilityView extends StatefulWidget {
  const ClippingAvailabilityView({super.key});

  @override
  State<ClippingAvailabilityView> createState() => _ClippingAvailabilityViewState();
}

class _ClippingAvailabilityViewState extends State<ClippingAvailabilityView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(() => const AvailabilityView(initialTab: 'Clipping'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
