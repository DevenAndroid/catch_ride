import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/user_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final Logger _logger = Logger();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxMap userData = <String, dynamic>{}.obs; // Keeping for backward compatibility temporarily
  final RxBool isLoading = false.obs;

  // Metadata Lists
  final RxList<String> allProgramTags = <String>[].obs;
  final RxList<String> allHorseShows = <String>[].obs;
  final RxList<String> allExperienceLevels = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchMetadata();
  }

  Future<void> fetchMetadata() async {
    try {
      final results = await Future.wait([
        _apiService.getRequest(AppUrls.programTags),
        _apiService.getRequest(AppUrls.horseShows),
        _apiService.getRequest(AppUrls.experienceLevels),
      ]);

      if (results[0].statusCode == 200) {
        allProgramTags.assignAll((results[0].body['data'] as List).map((e) => e['name'] as String).toList());
      }
      if (results[1].statusCode == 200) {
        allHorseShows.assignAll((results[1].body['data'] as List).map((e) => e['name'] as String).toList());
      }
      if (results[2].statusCode == 200) {
        allExperienceLevels.assignAll((results[2].body['data'] as List).map((e) => e['name'] as String).toList());
      }
    } catch (e) {
      _logger.e('Error fetching metadata: $e');
    }
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getRequest(AppUrls.profile);
      
      if (response.statusCode == 200) {
        final data = response.body['data'] ?? {};
        userData.value = data;
        user.value = UserModel.fromJson(data);
        _logger.i('Profile fetched successfully: ${user.value?.email}');
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
      // Use completeProfile endpoint as it handles role-specific data synchronization
      final response = await _apiService.putRequest(AppUrls.completeProfile, data);
      
      if (response.statusCode == 200) {
        await fetchProfile(); // Refresh local data
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
  String get id => user.value?.id ?? '';
  String get firstName => user.value?.firstName ?? '';
  String get lastName => user.value?.lastName ?? '';
  String get fullName => user.value?.fullName ?? '';
  String get email => user.value?.email ?? '';
  String get phone => user.value?.phone ?? '';
  String get bio => user.value?.bio ?? '';
  String get location => user.value?.location ?? '';
  String get avatar => user.value?.displayAvatar ?? '';
  String get coverImage => user.value?.coverImage ?? '';
  String get role => user.value?.role ?? 'user';
  
  // Professional Data
  String get barnName => user.value?.barnName ?? '';
  int get yearsExperience => user.value?.yearsExperience ?? 0;
  List<String> get selectedProgramTags => user.value?.programTags ?? [];
  List<String> get selectedHorseShows => user.value?.showCircuits ?? [];
  String get trainerId => user.value?.trainerProfileId ?? '';

  String get specialization {
    if (role == 'trainer') return 'Professional Horse Trainer';
    if (role == 'service_provider') return 'Service Provider';
    if (role == 'barn_manager') return 'Barn Manager';
    return role.capitalizeFirst ?? '';
  }
}
