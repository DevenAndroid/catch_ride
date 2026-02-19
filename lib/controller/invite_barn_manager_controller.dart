import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InviteBarnManagerController extends GetxController {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final RxBool canBookServices = true.obs;
  final RxBool canManageAvailability = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void sendInvite() {
    // Basic validation
    if (emailController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter an email address');
      return;
    }

    // API Simulation: Send Invite
    // await api.inviteBarnManager(email, permissions);

    Get.back(); // Close screen
    Get.snackbar('Success', 'Invitation sent to ${emailController.text}');
  }
}
