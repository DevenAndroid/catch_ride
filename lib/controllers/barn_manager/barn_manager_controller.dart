import 'package:get/get.dart';
import '../../constant/app_urls.dart';
import '../../services/api_service.dart';
import '../profile_controller.dart';

import 'package:flutter/material.dart';

class BarnManagerController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());

  var isLoading = false.obs;

  Future<bool> inviteBarnManager(String email) async {
    try {
      isLoading.value = true;
      final response = await _apiService.postRequest(
        AppUrls.inviteBarnManager,
        {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfile();
        }
        return true;
      } else {
        String errorMsg = 'Failed to send invitation';
        if (response.body is Map && response.body['message'] != null) {
          errorMsg = response.body['message'];
        }
        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: const Color(0xFFF04438),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: const Color(0xFFF04438),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> removeBarnManager() async {
    try {
      isLoading.value = true;
      final response = await _apiService.postRequest(
        AppUrls.removeBarnManager,
        {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (Get.isRegistered<ProfileController>()) {
          await Get.find<ProfileController>().fetchProfile();
        }
        return true;
      } else {
        String errorMsg = 'Failed to remove barn manager';
        if (response.body is Map && response.body['message'] != null) {
          errorMsg = response.body['message'];
        }
        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: const Color(0xFFF04438),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: const Color(0xFFF04438),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
