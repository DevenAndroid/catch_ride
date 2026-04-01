import 'dart:io';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditVendorProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Basic Details Section
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final businessNameController = TextEditingController();
  final aboutController = TextEditingController();
  final RxString profilePhotoUrl = ''.obs;
  final RxString coverImageUrl = ''.obs;
  final Rxn<File> newProfileImage = Rxn<File>();
  final Rxn<File> newCoverImage = Rxn<File>();

  // Payment Methods
  final RxList<String> paymentOptions = <String>['Venmo', 'Zelle', 'Cash', 'Credit Card', 'ACH/Bank Transfer', 'Other'].obs;
  final RxList<String> selectedPayments = <String>[].obs;

  // Experience Highlights
  final RxList<TextEditingController> highlightControllers = <TextEditingController>[].obs;

  // Grooming Tab - Home Base
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController(text: 'USA');

  // Grooming Tab - Experience & Choices
  final RxnString experience = RxnString();
  final List<String> experienceOptions = List.generate(51, (index) => index.toString());
  
  final RxList<String> disciplineOptions = <String>['Eventing', 'Hunter/Jumper', 'Dressage', 'Other'].obs;
  final RxList<String> selectedDisciplines = <String>[].obs;
  final otherDisciplineController = TextEditingController();

  final RxList<String> horseLevelOptions = <String>['AAAA Circuit', 'FEI', 'Grand Prix', 'Young horses'].obs;
  final RxList<String> selectedHorseLevels = <String>[].obs;

  final RxList<String> regionOptions = <String>[].obs;
  final RxList<String> selectedRegions = <String>[].obs;

  // Social Media
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();

  // Additional Grooming Sections
  final RxList<String> supportOptions = <String>['Show Grooming', 'Monthly Jobs', 'Fill in Daily Grooming Support', 'Weekly Jobs', 'Seasonal Jobs', 'Travel Jobs'].obs;
  final RxList<String> selectedSupport = <String>[].obs;

  final RxList<String> handlingOptions = <String>['Lunging', 'Flat Riding (exercise only)'].obs;
  final RxList<String> selectedHandling = <String>[].obs;

  final RxList<String> additionalSkillsOptions = <String>['Braiding', 'Clipping'].obs;
  final RxList<String> selectedAdditionalSkills = <String>[].obs;

  final RxList<String> travelOptions = <String>['Local Only', 'Regional', 'Nationwide', 'International'].obs;
  final RxList<String> selectedTravel = <String>[].obs;

  // Cancellation
  final RxnString cancellationPolicy = RxnString();
  final RxBool isCustomCancellation = false.obs;

  // Photos
  final RxList<String> existingPhotos = <String>[].obs;
  final RxList<File> newPhotos = <File>[].obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
    fetchDynamicTags();
  }

  Future<void> fetchProfileData() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final data = response.body['data'];
        
        // Basic Details
        fullNameController.text = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
        phoneController.text = data['phone'] ?? '';
        businessNameController.text = data['businessName'] ?? '';
        aboutController.text = data['bio'] ?? '';
        profilePhotoUrl.value = data['profilePhoto'] ?? '';
        coverImageUrl.value = data['coverImage'] ?? '';
        
        selectedPayments.assignAll(List<String>.from(data['paymentMethods'] ?? []));
        
        final List<String> loadedHighlights = List<String>.from(data['highlights'] ?? []);
        if (loadedHighlights.isEmpty) {
          highlightControllers.assignAll([TextEditingController()]);
        } else {
          highlightControllers.assignAll(loadedHighlights.map((h) => TextEditingController(text: h)).toList());
        }

        // Service level data
        final List assignedServices = data['assignedServices'] ?? [];
        final groomingService = assignedServices.firstWhereOrNull((s) => s['serviceType'] == 'Grooming');

        if (groomingService != null) {
          final profileData = groomingService['profile']?['profileData'] ?? {};
          final appData = groomingService['application']?['applicationData'] ?? {};

          // Home Base
          cityController.text = appData['homeBase']?['city'] ?? '';
          stateController.text = appData['homeBase']?['state'] ?? '';
          countryController.text = appData['homeBase']?['country'] ?? 'USA';

          experience.value = appData['experience']?.toString();
          selectedDisciplines.assignAll(List<String>.from(appData['disciplines'] ?? []));
          otherDisciplineController.text = appData['otherDiscipline'] ?? '';
          selectedHorseLevels.assignAll(List<String>.from(appData['horseLevels'] ?? []));
          selectedRegions.assignAll(List<String>.from(appData['regions'] ?? []));
          
          facebookController.text = profileData['socialMedia']?['facebook'] ?? '';
          instagramController.text = profileData['socialMedia']?['instagram'] ?? '';
          
          selectedSupport.assignAll(List<String>.from(profileData['capabilities']?['support'] ?? []));
          selectedHandling.assignAll(List<String>.from(profileData['capabilities']?['handling'] ?? []));
          selectedAdditionalSkills.assignAll(List<String>.from(profileData['additionalSkills'] ?? []));
          selectedTravel.assignAll(List<String>.from(profileData['travelPreferences'] ?? []));
          
          cancellationPolicy.value = profileData['cancellationPolicy']?['policy'];
          isCustomCancellation.value = profileData['cancellationPolicy']?['isCustom'] ?? false;
          
          existingPhotos.assignAll(List<String>.from(profileData['media'] ?? []));
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDynamicTags() async {
    try {
      final response = await _apiService.getRequest('/system-config/tag-types/with-values?category=Grooming');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List types = response.body['data'];
        
        final disciplineType = types.firstWhereOrNull((t) => t['name'] == 'Disciplines');
        if (disciplineType != null) {
          disciplineOptions.assignAll(List<String>.from(disciplineType['values'].map((v) => v['name'])));
          if (!disciplineOptions.contains('Other')) disciplineOptions.add('Other');
        }

        final horseLevelType = types.firstWhereOrNull((t) => t['name'] == 'Typical Level of Horses');
        if (horseLevelType != null) {
          horseLevelOptions.assignAll(List<String>.from(horseLevelType['values'].map((v) => v['name'])));
        }

        final regionType = types.firstWhereOrNull((t) => t['name'] == 'Regions Covered');
        if (regionType != null) {
          regionOptions.assignAll(List<String>.from(regionType['values'].map((v) => v['name'])));
        }
      }
    } catch (e) {
      debugPrint('Error fetching tags: $e');
    }
  }

  // Actions
  void togglePayment(String method) {
    if (selectedPayments.contains(method)) {
      selectedPayments.remove(method);
    } else {
      selectedPayments.add(method);
    }
  }

  void addHighlight() => highlightControllers.add(TextEditingController());
  void removeHighlight(int index) => highlightControllers.removeAt(index);

  void toggleDiscipline(String disc) {
    if (selectedDisciplines.contains(disc)) {
      selectedDisciplines.remove(disc);
    } else {
      selectedDisciplines.add(disc);
    }
  }

  void toggleHorseLevel(String level) {
    if (selectedHorseLevels.contains(level)) {
      selectedHorseLevels.remove(level);
    } else {
      selectedHorseLevels.add(level);
    }
  }

  void toggleRegion(String region) {
    if (selectedRegions.contains(region)) {
      selectedRegions.remove(region);
    } else {
      selectedRegions.add(region);
    }
  }

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) newProfileImage.value = File(image.path);
  }

  Future<void> pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) newCoverImage.value = File(image.path);
  }

  Future<void> addGroomingPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) newPhotos.add(File(image.path));
  }

  void removeExistingPhoto(int index) => existingPhotos.removeAt(index);
  void removeNewPhoto(int index) => newPhotos.removeAt(index);

  Future<String?> _uploadFile(File file, String type) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': type,
      });
      final response = await _apiService.postRequest('/upload?type=$type', formData);
      if (response.statusCode == 200 && response.body['success'] == true) {
        return response.body['data']['filename'];
      }
    } catch (e) {
      debugPrint('Error uploading $type: $e');
    }
    return null;
  }

  Future<void> saveProfile() async {
    isSaving.value = true;
    try {
      // 1. Upload new images if any
      String? profilePhoto = profilePhotoUrl.value;
      if (newProfileImage.value != null) {
        profilePhoto = await _uploadFile(newProfileImage.value!, 'profile');
      }

      String? coverImage = coverImageUrl.value;
      if (newCoverImage.value != null) {
        coverImage = await _uploadFile(newCoverImage.value!, 'profile');
      }

      final List<String> groomingMedia = [...existingPhotos];
      for (var f in newPhotos) {
        final key = await _uploadFile(f, 'grooming');
        if (key != null) groomingMedia.add(key);
      }

      // 2. Prepare Payload
      final vendorPayload = {
        'firstName': fullNameController.text.split(' ').first,
        'lastName': fullNameController.text.contains(' ') ? fullNameController.text.split(' ').skip(1).join(' ') : '',
        'phone': phoneController.text,
        'businessName': businessNameController.text,
        'bio': aboutController.text,
        'profilePhoto': profilePhoto,
        'coverImage': coverImage,
        'paymentMethods': selectedPayments.toList(),
        'highlights': highlightControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
      };

      final groomingPayload = {
        'servicesData': {
          'grooming': {
            'applicationData': {
              'homeBase': {
                'city': cityController.text,
                'state': stateController.text,
                'country': countryController.text,
              },
              'experience': experience.value,
              'disciplines': selectedDisciplines.toList(),
              'otherDiscipline': otherDisciplineController.text,
              'horseLevels': selectedHorseLevels.toList(),
              'regions': selectedRegions.toList(),
              'media': groomingMedia,
            },
            'profileData': {
              'socialMedia': {
                'facebook': facebookController.text,
                'instagram': instagramController.text,
              },
              'capabilities': {
                'support': selectedSupport.toList(),
                'handling': selectedHandling.toList(),
              },
              'additionalSkills': selectedAdditionalSkills.toList(),
              'travelPreferences': selectedTravel.toList(),
              'cancellationPolicy': {
                'policy': cancellationPolicy.value,
                'isCustom': isCustomCancellation.value,
              },
              'media': groomingMedia,
            }
          }
        }
      };

      // 3. Update Vendor Profile
      final vendorResponse = await _apiService.putRequest('/vendors/profile', vendorPayload);
      if (vendorResponse.statusCode != 200) throw 'Failed to update vendor basic profile';

      // 4. Update Grooming Service Profile
      final vendorId = _authController.currentUser.value?.id; // Assuming ID is accessible
      // If vendorId is null, we fetch again or use /vendors/me logic
      final meResponse = await _apiService.getRequest('/vendors/me');
      final realVendorId = meResponse.body['data']['_id'];

      final serviceResponse = await _apiService.putRequest('/vendors/$realVendorId', groomingPayload);
      
      if (serviceResponse.statusCode == 200) {
        _authController.currentUser.refresh();
        Get.back();
        Get.snackbar('Success', 'Profile updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        throw serviceResponse.body['message'] ?? 'Failed to update grooming details';
      }

    } catch (e) {
      debugPrint('Save error: $e');
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }
}
