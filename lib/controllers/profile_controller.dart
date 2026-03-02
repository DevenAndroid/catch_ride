import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final Logger _logger = Logger();

  final RxMap userData = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getRequest(AppUrls.profile);
      
      if (response.statusCode == 200) {
        userData.value = response.body['data'] ?? {};
        _logger.i('Profile fetched successfully: ${userData['email']}');
      } else {
        _logger.e('Failed to fetch profile: ${response.statusText}');
      }
    } catch (e) {
      _logger.e('Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await _apiService.putRequest(AppUrls.profile, data);
      
      if (response.statusCode == 200) {
        return true;
      } else {
        String message = response.body?['message'] ?? 'Update failed';
        _logger.e('Update failed: $message');
        return false;
      }
    } catch (e) {
      _logger.e('Error updating profile: $e');
      Get.snackbar('Error', 'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadImage(String filePath, String type) async {
    try {
      isLoading.value = true;
      final formData = FormData({
        'image': MultipartFile(filePath, filename: 'profile_image.jpg'),
        'type': type, // 'avatar' or 'cover'
      });

      final response = await _apiService.postRequest(AppUrls.uploadProfileImage, formData);
      
      if (response.statusCode == 200) {
        return true;
      } else {
        _logger.e('Failed to upload image: ${response.statusText}');
        return false;
      }
    } catch (e) {
      _logger.e('Error uploading image: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Helper getters for UI
  String get fullName => "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}".trim();
  String get email => userData['email'] ?? '';
  String get phone => userData['phone'] ?? '';
  String get bio => userData['bio'] ?? '';
  String get location => userData['location'] ?? '';
  String get avatar => userData['avatar'] ?? userData['photo'] ?? '';
  String get coverImage => userData['coverImage'] ?? '';
}
