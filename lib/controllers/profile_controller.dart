import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/user_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../models/horse_model.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());
  final Logger _logger = Logger();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxMap userData = <String, dynamic>{}.obs; // Keeping for backward compatibility temporarily
  final RxList<HorseModel> trainerHorses = <HorseModel>[].obs;
  final RxBool isLoading = false.obs;

  // Metadata Lists
  final RxList<String> allProgramTags = <String>[].obs;
  final RxList<String> allHorseShows = <String>[].obs;
  final RxList<String> allExperienceLevels = <String>[].obs;
  final RxList<Map<String, dynamic>> tagTypes = <Map<String, dynamic>>[].obs;
  final RxList<String> selectedTags = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile().then((_) {
      if (user.value?.role == 'trainer' && user.value?.trainerProfileId != null) {
        fetchTrainerHorses();
      }
    });
    fetchMetadata();
  }

  Future<void> fetchTrainerHorses() async {
    try {
      final tId = user.value?.trainerProfileId;
      if (tId == null) return;

      final response = await _apiService.getRequest(AppUrls.horses, query: {
        'trainerId': tId,
        'limit': '5'
      });

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        trainerHorses.assignAll(data.map((e) => HorseModel.fromJson(e)).toList());
      }
    } catch (e) {
      _logger.e('Error fetching trainer horses: $e');
    }
  }

  Future<void> fetchMetadata() async {
    try {
      final results = await Future.wait([
        _apiService.getRequest(AppUrls.programTags),
        _apiService.getRequest('${AppUrls.horseShows}?limit=100'),
        _apiService.getRequest(AppUrls.experienceLevels),
        _apiService.getRequest('${AppUrls.tagTypesWithValues}?category=Trainer'),
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
      if (results[3].statusCode == 200) {
        tagTypes.assignAll((results[3].body['data'] as List).map((e) => e as Map<String, dynamic>).toList());
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
        
        // Fetch horses if trainer
        if (user.value?.role == 'trainer' && user.value?.trainerProfileId != null) {
          fetchTrainerHorses();
        }
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
      // PUT /profile — handles all field updates AND syncs trainer/vendor/barn-manager record
      final response = await _apiService.putRequest(AppUrls.profile, data);
      
      if (response.statusCode == 200) {
        await fetchProfile(); // Refresh local data
        return true;
      } else {
        String message = response.body?['message'] ?? 'Update failed';
        _logger.e('Update failed: $message');
        Get.snackbar('Error', message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
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
  String get location2 => user.value?.location2 ?? '';
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

  // Helper to group selected tags by their type name
  Map<String, List<String>> get groupedTrainerTags {
    final Map<String, List<String>> grouped = {};
    final currentUser = user.value;
    if (currentUser == null || tagTypes.isEmpty) return grouped;

    final userTagIds = currentUser.tags;
    
    // Group selected values by their tag type
    for (var type in tagTypes) {
      final String typeName = type['name'] ?? 'General';
      final List values = type['values'] ?? [];
      
      final List<String> selectedInThisType = [];
      for (var val in values) {
        final String valId = val['_id'] ?? '';
        final String valName = val['name'] ?? '';
        
        if (userTagIds.contains(valId)) {
          selectedInThisType.add(valName);
        }
      }
      
      if (selectedInThisType.isNotEmpty) {
        grouped[typeName] = selectedInThisType;
      }
    }
    
    return grouped;
  }

  List<String> get disciplines {
    final grouped = groupedTrainerTags;
    return grouped['Discipline'] ?? grouped['Disciplines'] ?? [];
  }
}
