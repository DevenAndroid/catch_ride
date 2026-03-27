import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SetupGroomApplicationController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Form Fields
  final fullNameController = TextEditingController();
  final joinCommunityController = TextEditingController();
  
  // Location
  final cityController = TextEditingController();
  final stateProvinceController = TextEditingController();
  final countryController = TextEditingController();

  // Experience
  final experience = RxnString();
  final List<String> experienceOptions = [
    '0-1 years',
    '1-3 years',
    '3-5 years',
    '5+ years',
    '10+ years',
  ];

  // Disciplines
  final selectedDisciplines = <String>[].obs;
  final otherDisciplineController = TextEditingController();
  final List<String> disciplineOptions = [
    'Grooming',
    'Hunter Jumper',
    'Dressage',
    'Other',
  ];

  // Level of Horses
  final selectedHorseLevels = <String>[].obs;
  final List<String> horseLevelOptions = [
    '4/5/6/7',
    '8/9/10', // Example based on screenshot
    'Grand Prix',
    'Young Horses',
  ];

  // Regions
  final selectedRegions = <String>[].obs;
  final List<String> regionOptions = [
    'Northwest (Hamp)',
    'Florida (Wellington - Ocala - Gulf coast)',
    'Southwest (Hamp/NJ/Union Brown)',
    'Southeast (Aiken / Tryon / Wills Park / Chatt Hills)',
  ];

  // Social Media
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();

  // Photos
  final photos = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      photos.add(File(image.path));
    }
  }

  void removeImage(int index) {
    photos.removeAt(index);
  }

  // Professional References
  final ref1FullNameController = TextEditingController();
  final ref1BusinessNameController = TextEditingController();
  final ref1RelationshipController = TextEditingController();

  final ref2FullNameController = TextEditingController();
  final ref2BusinessNameController = TextEditingController();
  final ref2RelationshipController = TextEditingController();

  // Experience Highlights
  final highlightsController = TextEditingController();
  final highlightsList = <String>[].obs;

  void addHighlight() {
    if (highlightsController.text.isNotEmpty) {
      highlightsList.add(highlightsController.text);
      highlightsController.clear();
    }
  }

  // Checkboxes
  final is18OrOlder = false.obs;
  final agreeToTerms = false.obs;
  final confirmReferences = false.obs;

  @override
  void onClose() {
    fullNameController.dispose();
    joinCommunityController.dispose();
    cityController.dispose();
    stateProvinceController.dispose();
    countryController.dispose();
    otherDisciplineController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    ref1FullNameController.dispose();
    ref1BusinessNameController.dispose();
    ref1RelationshipController.dispose();
    ref2FullNameController.dispose();
    ref2BusinessNameController.dispose();
    ref2RelationshipController.dispose();
    highlightsController.dispose();
    super.onClose();
  }

  void submitApplication() {
    if (formKey.currentState!.validate()) {
      if (!is18OrOlder.value || !agreeToTerms.value) {
        Get.snackbar(
          'Incomplete',
          'Please agree to the terms and privacy policy.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      // Submit logic
      Get.snackbar(
        'Success',
        'Your application has been submitted successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}
