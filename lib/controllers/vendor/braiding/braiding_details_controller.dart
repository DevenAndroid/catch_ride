
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';
import 'package:catch_ride/view/vendor/profile_completed_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BraidingDetailsController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Core Braiding Services
  final braidingServices = <Map<String, dynamic>>[
    {'name': 'Hunter Mane Only', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Hunter Tail Only', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Jumper Braids', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Dressage Braids', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Mane Pull / Clean Up', 'isSelected': false.obs, 'price': TextEditingController()},
  ].obs;

  final addServiceInputController = TextEditingController();

  void addBraidingService(String name) {
    if (name.isNotEmpty) {
      braidingServices.add({
        'name': name,
        'isSelected': true.obs,
        'dayPrice': TextEditingController(),
        'weekPrice': TextEditingController(),
        'monthPrice': TextEditingController(),
      });
      addServiceInputController.clear();
    }
  }

  // Travel Preferences
  final travelOptions = ['Local Only', 'Regional', 'Nationwide', 'International'];
  final selectedTravel = <String>{}.obs;

  void toggleTravel(String item) {
    if (selectedTravel.contains(item)) {
      selectedTravel.remove(item);
    } else {
      selectedTravel.add(item);
    }
  }

  // Read-only mock data for UI
  final location = 'Denver, Colorado, USA'.obs;
  final experience = '4 years'.obs;
  final disciplines = ['Eventing', 'Hunter/Jumper', 'Dressage'].obs;
  final horseLevels = ['A/AA Circuit', 'Grand Prix', 'Young horses', 'FEI'].obs;
  final operatingRegions = [
    'Florida (Wellington - Ocala - Gulf Coast)',
    'Southwest (Thermal - AZ winter circuit)',
    'Southeast (Aiken - Tryon - Wills Park - Chatt Hills)',
  ].obs;

  // Cancellation Policy
  final cancellationPolicy = RxnString();
  final isCustomCancellation = false.obs;

  void submit() {
    Get.offAll(() => const ProfileCompletedView(
          subtitle: 'Your braiding services are now live',
          destinationWidget: GroomBottomNav(),
        ));
  }

  @override
  void onClose() {
    for (var service in braidingServices) {
      (service['price'] as TextEditingController).dispose();
    }
    addServiceInputController.dispose();
    super.onClose();
  }
}
