import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        _logger.d('No auth token found, skipping profile fetch');
        return;
      }

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

  Future<String?> uploadRawFile(String filePath) async {
    try {
      final formData = FormData({
        'media': MultipartFile(filePath, filename: filePath.split('/').last),
      });

      final response = await _apiService.postRequest(AppUrls.upload, formData);

      if (response.statusCode == 200) {
        return response.body['data']['url'];
      } else {
        _logger.e('File upload failed: ${response.statusText}');
        return null;
      }
    } catch (e) {
      _logger.e('Error in uploadRawFile: $e');
      return null;
    }
  }

  Future<bool> uploadImage(String filePath, String type) async {
    try {
      isLoading.value = true;
      
      // 1. Upload to general media storage
      final imageUrl = await uploadRawFile(filePath);
      if (imageUrl == null) return false;

      // 2. Link URL to profile
      final response = await _apiService.postRequest(AppUrls.uploadProfileImage, {
        'imageUrl': imageUrl,
        'type': type, // 'avatar' or 'cover'
      });
      
      if (response.statusCode == 200) {
        await fetchProfile(); // Refresh local data
        return true;
      } else {
        _logger.e('Failed to link image to profile: ${response.statusText}');
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
  String get firstName => userData['firstName'] ?? '';
  String get lastName => userData['lastName'] ?? '';
  String get fullName => "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}".trim();
  String get email => userData['email'] ?? '';
  String get phone => userData['phone'] ?? '';
  String get bio => userData['bio'] ?? '';
  String get location => userData['location'] ?? '';
  String get avatar => userData['avatar'] ?? userData['photo'] ?? '';
  String get coverImage => userData['coverImage'] ?? '';
  String get role => userData['role'] ?? 'user';
  
  // Professional Data
  Map<String, dynamic>? get trainerData => userData['trainerId'];
  Map<String, dynamic>? get vendorData => userData['vendorId'];
  Map<String, dynamic>? get barnManagerData => userData['barnManagerId'];

  String get barnName {
    if (role == 'trainer') return trainerData?['barnName'] ?? '';
    if (role == 'barn_manager') return barnManagerData?['barnName'] ?? '';
    return '';
  }

  String get specialization {
    if (role == 'trainer') return trainerData?['specialization'] ?? 'Professional Horse Trainer';
    if (role == 'service_provider') return vendorData?['serviceType'] ?? 'Service Provider';
    if (role == 'barn_manager') return 'Barn Manager';
    return role.capitalizeFirst ?? '';
  }

  int get yearsExperience {
    if (role == 'trainer') return trainerData?['yearsExperience'] ?? 0;
    if (role == 'service_provider') return vendorData?['yearsExperience'] ?? 0;
    return 0;
  }
}
