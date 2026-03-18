import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SettingsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final Logger _logger = Logger();

  final RxBool isLoading = false.obs;
  final RxList activeSessions = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveSessions();
  }

  Future<void> fetchActiveSessions() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getRequest(AppUrls.sessions);
      if (response.statusCode == 200) {
        activeSessions.assignAll(response.body['data'] ?? []);
      }
    } catch (e) {
      _logger.e('Error fetching sessions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> terminateSession(String token) async {
    try {
      final response = await _apiService.deleteRequest(
        '${AppUrls.terminateSession}$token',
      );
      if (response.statusCode == 200) {
        await fetchActiveSessions();
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error terminating session: $e');
      return false;
    }
  }

  Future<bool> toggle2FA(bool enabled) async {
    try {
      final response = await _apiService.postRequest(AppUrls.toggle2FA, {
        'enabled': enabled,
      });
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Two-Factor Authentication ${enabled ? 'enabled' : 'disabled'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error toggling 2FA: $e');
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      isLoading.value = true;
      final response = await _apiService.putRequest(AppUrls.changePassword, {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Password changed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.body?['message'] ?? 'Failed to change password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      _logger.e('Error changing password: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteAccount(String userId) async {
    try {
      isLoading.value = true;
      final response = await _apiService.deleteRequest(
        '${AppUrls.deleteAccount}$userId',
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error deleting account: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
