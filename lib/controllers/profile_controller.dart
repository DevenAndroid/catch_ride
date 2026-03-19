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
  final Rx<UserModel?> viewedUser = Rx<UserModel?>(null);
  final Rx<UserModel?> linkedTrainerProfile = Rx<UserModel?>(null);
  final RxMap userData = <String, dynamic>{}.obs;
  final RxList<HorseModel> trainerHorses = <HorseModel>[].obs;
  final RxList<HorseModel> viewedUserHorses = <HorseModel>[].obs;
  final RxBool isLoading = false.obs;

  // Metadata Lists
  final RxList<String> allProgramTags = <String>[].obs;
  final RxList<String> allHorseShows = <String>[].obs; // List of names
  final RxList<Map<String, dynamic>> rawHorseShows =
      <Map<String, dynamic>>[].obs; // Full objects
  final RxList<String> allExperienceLevels = <String>[].obs;
  final RxList<Map<String, dynamic>> tagTypes = <Map<String, dynamic>>[].obs;
  final RxList<String> selectedTags = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile().then((_) {
      if ((user.value?.role == 'trainer' ||
              user.value?.role == 'barn_manager') &&
          user.value?.trainerProfileId != null) {
        fetchTrainerHorses();
      }
    });
    fetchMetadata();
  }

  Future<void> fetchTrainerHorses() async {
    try {
      final tId = user.value?.trainerProfileId;
      if (tId == null) return;

      final response = await _apiService.getRequest(
        AppUrls.horses,
        query: {'trainerId': tId, 'limit': '5'},
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        trainerHorses.assignAll(
          data.map((e) => HorseModel.fromJson(e)).toList(),
        );
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
        _apiService.getRequest(
          '${AppUrls.tagTypesWithValues}?category=Trainer',
        ),
      ]);

      if (results[0].statusCode == 200) {
        allProgramTags.assignAll(
          (results[0].body['data'] as List)
              .map((e) => e['name'] as String)
              .toList(),
        );
      }
      if (results[1].statusCode == 200) {
        final List data = results[1].body['data'] ?? [];
        allHorseShows.assignAll(data.map((e) => e['name'] as String).toList());
        rawHorseShows.assignAll(
          data.map((e) => e as Map<String, dynamic>).toList(),
        );
      }
      if (results[2].statusCode == 200) {
        allExperienceLevels.assignAll(
          (results[2].body['data'] as List)
              .map((e) => e['name'] as String)
              .toList(),
        );
      }
      if (results[3].statusCode == 200) {
        tagTypes.assignAll(
          (results[3].body['data'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList(),
        );
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

        // Fetch horses if trainer or barn manager
        if ((user.value?.role == 'trainer' ||
                user.value?.role == 'barn_manager') &&
            user.value?.trainerProfileId != null) {
          fetchTrainerHorses();
        }

        // Fetch full trainer profile if barn manager
        if (user.value?.role == 'barn_manager' &&
            user.value?.trainerProfileId != null) {
          fetchLinkedTrainerProfile(user.value!.trainerProfileId!);
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

  Future<void> fetchLinkedTrainerProfile(String trainerId) async {
    try {
      final response = await _apiService.getRequest(
        '${AppUrls.trainers}/$trainerId',
      );
      if (response.statusCode == 200) {
        final data = response.body['data'] ?? {};
        linkedTrainerProfile.value = UserModel(
          id: data['_id'] ?? '',
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          email: data['email'] ?? '',
          role: 'trainer',
          phone: data['phone'] ?? '',
          location: data['location'] ?? '',
          location2: data['location2'] ?? '',
          bio: data['bio'] ?? '',
          barnName: data['barnName'] ?? '',
          yearsExperience: data['yearsExperience'] ?? 0,
          avatar: data['profilePhoto'] ?? '',
          coverImage: data['coverImage'] ?? '',
          trainerProfileId: data['_id'],
          isProfileApprove: data['isProfileApprove'] ?? false,
          status: data['status'] ?? 'active',
          instagram: data['instagram'] ?? '',
          facebook: data['facebook'] ?? '',
          website: data['website'] ?? '',
          showCircuits:
              (data['horseShows'] as List?)
                  ?.map((e) => e['name'].toString())
                  .toList() ??
              [],
          horseShows:
              (data['horseShows'] as List?)
                  ?.map((e) => e['_id'].toString())
                  .toList() ??
              [],
          tags:
              (data['tags'] as List?)
                  ?.map((e) => e['_id'].toString())
                  .toList() ??
              [],
        );
        _logger.i('Linked trainer profile fetched successfully');
      }
    } catch (e) {
      _logger.e('Error fetching linked trainer profile: $e');
    }
  }

  Future<void> fetchPublicTrainerProfile(String trainerId) async {
    try {
      isLoading.value = true;
      viewedUser.value = null;
      viewedUserHorses.clear();

      final response = await _apiService.getRequest(
        '${AppUrls.trainers}/$trainerId',
      );

      if (response.statusCode == 200) {
        final data = response.body['data'] ?? {};

        // The /api/trainers/:id endpoint returns a Trainer object
        // We need to map it to a format the ProfileView can use, ideally UserModel
        final mappedUser = UserModel(
          id: data['_id'] ?? '',
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          email: data['email'] ?? '',
          role: 'trainer',
          phone: data['phone'] ?? '',
          location: data['location'] ?? '',
          location2: data['location2'] ?? '',
          bio: data['bio'] ?? '',
          barnName: data['barnName'] ?? '',
          yearsExperience: data['yearsExperience'] ?? 0,
          avatar: data['profilePhoto'] ?? '',
          coverImage: data['coverImage'] ?? '',
          trainerProfileId: data['_id'],
          isProfileApprove: data['isProfileApprove'] ?? false,
          status: data['status'] ?? 'active',
          instagram: data['instagram'] ?? '',
          facebook: data['facebook'] ?? '',
          website: data['website'] ?? '',
          showCircuits:
              (data['horseShows'] as List?)
                  ?.map((e) => e['name'].toString())
                  .toList() ??
              [],
          horseShows:
              (data['horseShows'] as List?)
                  ?.map((e) => e['_id'].toString())
                  .toList() ??
              [],
          tags:
              (data['tags'] as List?)
                  ?.map((e) => e['_id'].toString())
                  .toList() ??
              [],
        );

        viewedUser.value = mappedUser;

        // Fetch horses for this trainer
        final horseResponse = await _apiService.getRequest(
          AppUrls.horses,
          query: {'trainerId': trainerId, 'limit': '10'},
        );

        if (horseResponse.statusCode == 200) {
          final List horseData = horseResponse.body['data'] ?? [];
          viewedUserHorses.assignAll(
            horseData.map((e) => HorseModel.fromJson(e)).toList(),
          );
        }
      }
    } catch (e) {
      _logger.e('Error fetching public trainer profile: $e');
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
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      _logger.e('Error updating profile: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      final response = await _apiService.postRequest(
        AppUrls.uploadProfileImage,
        {
          'imageUrl': imageUrl,
          'type': type, // 'avatar' or 'cover'
        },
      );

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

  UserModel? get displayUser => viewedUser.value ?? user.value;

  // Helper getters for UI
  String get id => displayUser?.id ?? '';
  String get firstName => displayUser?.firstName ?? '';
  String get lastName => displayUser?.lastName ?? '';
  String get fullName => displayUser?.fullName ?? '';
  String get email => displayUser?.email ?? '';
  String get phone => displayUser?.phone ?? '';
  String get bio => displayUser?.bio ?? '';
  String get location => displayUser?.location ?? '';
  String get location2 => displayUser?.location2 ?? '';
  String get avatar => displayUser?.displayAvatar ?? '';
  String get coverImage => displayUser?.coverImage ?? '';
  String get role => displayUser?.role ?? 'user';
  String get status => displayUser?.status ?? 'active';
  bool get isApproved => displayUser?.isProfileApprove ?? false;
  bool get pushNotificationsEnabled =>
      displayUser?.pushNotificationsEnabled ?? true;
  bool get isActive => status.toLowerCase() == 'active';

  // Professional Data
  String get barnName => displayUser?.barnName ?? '';
  int get yearsExperience => displayUser?.yearsExperience ?? 0;
  List<String> get selectedProgramTags => displayUser?.programTags ?? [];
  List<String> get selectedHorseShows {
    UserModel? target = displayUser;
    // Only fall back to linked trainer if we're NOT viewing another user
    if (viewedUser.value == null &&
        user.value?.role == 'barn_manager' &&
        linkedTrainerProfile.value != null) {
      target = linkedTrainerProfile.value;
    }
    return target?.showCircuits ?? [];
  }

  List<String> get selectedHorseShowIds => displayUser?.horseShows ?? [];
  String get trainerId => displayUser?.trainerProfileId ?? '';
  String get yearsInIndustry => displayUser?.yearsInIndustry ?? '';
  String get linkedTrainerBarnName {
    if (user.value?.role == 'barn_manager') {
      return linkedTrainerProfile.value?.barnName ??
          user.value?.linkedTrainer?.barnName ??
          '';
    }
    return '';
  }

  String get specialization {
    if (role == 'trainer') return 'Professional Horse Trainer';
    if (role == 'service_provider') return 'Service Provider';
    if (role == 'barn_manager') return 'Barn Manager';
    return role.capitalizeFirst ?? '';
  }

  // Helper to group selected tags by their type name
  Map<String, List<String>> get groupedTrainerTags {
    final Map<String, List<String>> grouped = {};

    // For barn managers, show tags from linked trainer if viewing own profile
    UserModel? currentUser = displayUser;
    if (viewedUser.value == null &&
        user.value?.role == 'barn_manager' &&
        linkedTrainerProfile.value != null) {
      currentUser = linkedTrainerProfile.value;
    }

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

  Future<void> togglePushNotifications(bool enabled) async {
    try {
      final response = await _apiService.putRequest(
        AppUrls.toggleNotifications,
        {'enabled': enabled},
      );

      if (response.statusCode == 200) {
        // Update local user object
        if (user.value != null) {
          final updatedData = Map<String, dynamic>.from(userData);
          updatedData['pushNotificationsEnabled'] = enabled;
          userData.value = updatedData;
          user.value = UserModel.fromJson(updatedData);
        }
      } else {
        _logger.e('Failed to toggle notifications: ${response.statusText}');
      }
    } catch (e) {
      _logger.e('Error toggling push notifications: $e');
    }
  }
}
