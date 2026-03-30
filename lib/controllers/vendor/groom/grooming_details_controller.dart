import 'package:catch_ride/view/vendor/profile_completed_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroomingDetailsController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Grooming Services
  final groomingServicesList = <String>[
    'Grooming & Turnout',
    'Wrapping & Bandaging',
    'Stall Upkeep & Daily Care',
    'Show Prep (non Braiding)',
  ].obs;
  final addSkillInputController = TextEditingController();
  final selectedGroomingServices = <String>{}.obs;

  void toggleGroomingService(String service) {
    if (selectedGroomingServices.contains(service)) {
      selectedGroomingServices.remove(service);
    } else {
      selectedGroomingServices.add(service);
    }
  }

  // Rate Section
  final dailyRateController = TextEditingController();
  final weeklyRateController = TextEditingController();
  final weeklyRateDays = 5.obs; // 5 or 6
  final monthlyRateController = TextEditingController();
  final monthlyRateDays = 5.obs; // 5 or 6

  // Show & Barn Support
  final supportOptions = [
    'Show Grooming',
    'Monthly Jobs',
    'Fill in Daily Grooming Support',
    'Weekly Jobs',
    'Seasonal Jobs',
    'Travel Jobs',
  ];
  final selectedSupport = <String>{}.obs;

  void toggleSupport(String item) {
    if (selectedSupport.contains(item)) {
      selectedSupport.remove(item);
    } else {
      selectedSupport.add(item);
    }
  }

  // Horse Handling
  final handlingOptions = ['Lunging', 'Flat Riding (exercise only)'];
  final selectedHandling = <String>{}.obs;

  void toggleHandling(String item) {
    if (selectedHandling.contains(item)) {
      selectedHandling.remove(item);
    } else {
      selectedHandling.add(item);
    }
  }

  // Additional Services
  final additionalServices = <Map<String, dynamic>>[
    {'name': 'Body Clipping', 'price': TextEditingController(text: '150'), 'isSelected': true.obs},
    {'name': 'Trace Clipping', 'price': TextEditingController(text: '75'), 'isSelected': false.obs},
    {'name': 'Tacking & Untacking', 'price': TextEditingController(text: '20'), 'isSelected': false.obs},
  ].obs;

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

  // Pre-filled / Read-only (Mock data for UI)
  final location = 'Denver, Colorado, USA'.obs;
  final experience = '4 years'.obs;
  final disciplinesSelected = ['Grooming', 'Hunter/Jumper', 'Dressage'].obs;
  final horseLevels = ['A/AA Circuit', 'Grand Prix', 'Young horses', 'FEI'].obs;
  final operatingRegions = [
    'Florida (Wellington - Ocala - Gulf coast)',
    'Southwest (Hamp/NJ/Union Brown)',
    'Southeast (Aiken / Tryon / Wills Park / Chatt Hills)',
  ].obs;

  // Cancellation Policy
  final cancellationPolicy = RxnString();
  final isCustomCancellation = false.obs;

  void addSkill(String skill) {
    if (skill.isNotEmpty && !groomingServicesList.contains(skill)) {
      groomingServicesList.add(skill);
      addSkillInputController.clear();
    }
  }

  void submit() {
    Get.to(() => const ProfileCompletedView(subtitle: 'Your grooming services are now live',));
  }

  @override
  void onClose() {
    dailyRateController.dispose();
    weeklyRateController.dispose();
    monthlyRateController.dispose();
    addSkillInputController.dispose();
    for (var service in additionalServices) {
      (service['price'] as TextEditingController).dispose();
    }
    super.onClose();
  }
}
