import 'dart:io';
import 'package:catch_ride/view/vendor/groom/profile_create/grooming_details_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../view/vendor/braiding/profile_create/braiding_application_view.dart';
import '../../../view/vendor/braiding/profile_create/braiding_details_view.dart';

class GroomCompleteProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Basic Details
  final fullNameController = TextEditingController(text: 'Thomas Martin');
  final countryCode = '+1'.obs;
  final phoneNumberController = TextEditingController();
  final businessNameController = TextEditingController();
  final aboutController = TextEditingController();

  // Images
  final profileImage = Rxn<File>();
  final bannerImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> pickBannerImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      bannerImage.value = File(image.path);
    }
  }

  // Payment Methods
  final selectedPaymentMethods = <String>{}.obs;
  final otherPaymentController = TextEditingController();
  
  final List<Map<String, dynamic>> paymentOptions = [
    {'name': 'Venmo', 'icon': 'assets/images/venmo.png'}, // Placeholder paths
    {'name': 'Zelle', 'icon': 'assets/images/zelle.png'},
    {'name': 'Cash', 'icon': Icons.money},
    {'name': 'Credit Card', 'icon': Icons.credit_card},
    {'name': 'ACH/Bank Transfer', 'icon': Icons.account_balance},
    {'name': 'Other', 'icon': Icons.add},
  ];

  void togglePaymentMethod(String method) {
    if (selectedPaymentMethods.contains(method)) {
      selectedPaymentMethods.remove(method);
    } else {
      selectedPaymentMethods.add(method);
    }
  }

  // Experience Highlights
  final highlightInputController = TextEditingController();
  final highlights = <String>[].obs;

  void addHighlight() {
    if (highlightInputController.text.isNotEmpty) {
      highlights.add(highlightInputController.text);
      highlightInputController.clear();
    }
  }

  void removeHighlight(int index) {
    highlights.removeAt(index);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    businessNameController.dispose();
    aboutController.dispose();
    otherPaymentController.dispose();
    highlightInputController.dispose();
    super.onClose();
  }

  void submit() {
    Get.to(() => const BraidingDetailsView());
  }
}
