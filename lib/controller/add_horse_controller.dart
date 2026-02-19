import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddHorseController extends GetxController {
  var currentStep = 0.obs;
  var videoUploaded = false.obs;

  // Text Controllers
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final heightController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final ageController = TextEditingController();
  final disciplineController = TextEditingController();
  final locationController = TextEditingController();

  // Selections
  var listingType = 'Sale'.obs;
  var selectedDiscipline = ''.obs;

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    } else {
      // Publish Logic
      Get.back();
      Get.snackbar('Success', 'Horse listed successfully!');
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    breedController.dispose();
    heightController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    ageController.dispose();
    disciplineController.dispose();
    locationController.dispose();
    super.onClose();
  }
}
