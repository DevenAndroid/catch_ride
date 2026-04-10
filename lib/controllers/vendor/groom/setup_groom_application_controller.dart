import 'dart:io';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_application_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_application_view.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_application_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_application_view.dart';
import 'package:catch_ride/view/vendor/shipping/create_profile/shipping_application_view.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';

import '../../../view/vendor/vendor_application_submit_view.dart';

class SetupGroomApplicationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.put(ApiService());

  // Form Fields
  final fullNameController = TextEditingController();
  final joinCommunityController = TextEditingController();
  // Location
  final countryController = TextEditingController(text: 'USA');
  final states = <Map<String, dynamic>>[].obs;
  final cities = <Map<String, dynamic>>[].obs;
  
  final selectedState = Rxn<Map<String, dynamic>>();
  final selectedCity = Rxn<Map<String, dynamic>>();

  final isLoadingStates = false.obs;
  final isLoadingCities = false.obs;
  final isLoadingTags = false.obs;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.put(AuthController());
    fullNameController.text = authController.currentUser.value?.fullName ?? '';
    fetchStates();
    fetchDynamicTags();
  }

  Future<void> fetchStates() async {
    isLoadingStates.value = true;
    try {
      final Response response = await apiService.getRequest('/locations/states');
      if (response.statusCode == 200 && response.body['success'] == true) {
        states.value = List<Map<String, dynamic>>.from(response.body['data']);
      }
    } catch (e) {
      debugPrint('Error fetching states: $e');
    } finally {
      isLoadingStates.value = false;
    }
  }

  Future<void> fetchCities(String stateCode) async {
    isLoadingCities.value = true;
    selectedCity.value = null;
    cities.clear();
    try {
      final Response response = await apiService.getRequest('/locations/states/$stateCode/cities');
      if (response.statusCode == 200 && response.body['success'] == true) {
        cities.value = List<Map<String, dynamic>>.from(response.body['data']);
      }
    } catch (e) {
      debugPrint('Error fetching cities: $e');
    } finally {
      isLoadingCities.value = false;
    }
  }

  void onStateSelected(Map<String, dynamic> state) {
    selectedState.value = state;
    fetchCities(state['isoCode']);
  }

  void onCitySelected(Map<String, dynamic> city) {
    selectedCity.value = city;
  }
  
  Future<void> fetchDynamicTags() async {
    isLoadingTags.value = true;
    try {
      final Response response = await apiService.getRequest('/system-config/tag-types/with-values?category=Grooming');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List types = response.body['data'];
        
        // Populate Disciplines
        final disciplineType = types.firstWhereOrNull((t) => t['name'] == 'Disciplines');
        if (disciplineType != null) {
          disciplineOptions.value = List<String>.from(disciplineType['values'].map((v) => v['name']));
          if (!disciplineOptions.contains('Other')) disciplineOptions.add('Other');
        }

        // Populate Level of Horses
        final horseLevelType = types.firstWhereOrNull((t) => t['name'] == 'Typical Level of Horses');
        if (horseLevelType != null) {
          horseLevelOptions.value = List<String>.from(horseLevelType['values'].map((v) => v['name']));
        }
        // Populate Regions Covered
        final regionType = types.firstWhereOrNull((t) => t['name'] == 'Regions Covered');
        if (regionType != null) {
          regionOptions.value = List<String>.from(regionType['values'].map((v) => v['name']));
        }
      }
    } catch (e) {
      debugPrint('Error fetching tags: $e');
    } finally {
      isLoadingTags.value = false;
    }
  }

  // Experience
  final experience = RxnString();
  final List<String> experienceOptions = ['0-1', '2-4', '5-9', '10+'];

  // Disciplines
  final selectedDisciplines = <String>[].obs;
  final otherDisciplineController = TextEditingController();
  final disciplineOptions = <String>[].obs;

  // Level of Horses
  final selectedHorseLevels = <String>[].obs;
  final horseLevelOptions = <String>[].obs;

  // Regions
  final selectedRegions = <String>[].obs;
  final regionOptions = <String>[].obs;

  // Social Media
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();

  // Photos
  final photos = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      photos.add(File(image.path));
    }
  }

  void removeImage(int index) {
    photos.removeAt(index);
  }

  // Professional References
  final ref1FullNameController = TextEditingController();
  final ref1BusinessNameController = TextEditingController();
  final ref1RelationshipController = TextEditingController();

  final ref2FullNameController = TextEditingController();
  final ref2BusinessNameController = TextEditingController();
  final ref2RelationshipController = TextEditingController();

  // Experience Highlights
  final highlightsControllers = <TextEditingController>[TextEditingController()].obs;

  void addHighlight() {
    highlightsControllers.add(TextEditingController());
  }

  void removeHighlight(int index) {
    if (highlightsControllers.length > 1) {
      highlightsControllers[index].dispose();
      highlightsControllers.removeAt(index);
    } else {
      highlightsControllers[index].clear();
    }
  }

  // Checkboxes
  final is18OrOlder = false.obs;
  final agreeToTerms = false.obs;
  final confirmReferences = false.obs;
  final isSubmitting = false.obs;

  @override
  void onClose() {
    fullNameController.dispose();
    joinCommunityController.dispose();
    otherDisciplineController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    ref1FullNameController.dispose();
    ref1BusinessNameController.dispose();
    ref1RelationshipController.dispose();
    ref2FullNameController.dispose();
    ref2BusinessNameController.dispose();
    ref2RelationshipController.dispose();
    for (var ctrl in highlightsControllers) {
      ctrl.dispose();
    }
    countryController.dispose();
    super.onClose();
  }

  Future<String?> _uploadPhoto(File file) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': 'grooming',
      });
      final response = await apiService.postRequest('/upload?type=grooming', formData);
      if (response.statusCode == 200 && response.body['success'] == true) {
        return response.body['data']['filename'];
      }
    } catch (e) {
      debugPrint('Error uploading photo: $e');
    }
    return null;
  }

  Future<void> submitApplication() async {
    // 1. Basic Form Validation
    if (!(formKey.currentState?.validate() ?? false)) return;

    // 2. Custom Validation for Reactive selections (using "Please" as per rules)
    if (selectedState.value == null || selectedCity.value == null) {
      Get.snackbar('Missing Info', 'Please select your home base city and state', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (experience.value == null) {
      Get.snackbar('Missing Info', 'Please select your grooming experience level', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedDisciplines.isEmpty) {
      Get.snackbar('Missing Info', 'Please select at least one discipline', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedHorseLevels.isEmpty) {
      Get.snackbar('Missing Info', 'Please select the typical level of horses you handle', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedRegions.isEmpty) {
      Get.snackbar('Missing Info', 'Please select at least one region you cover', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (!is18OrOlder.value) {
      Get.snackbar('Age Verification', 'Please confirm that you are at least 18 years of age', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (!agreeToTerms.value) {
      Get.snackbar('Terms & Privacy', 'Please agree to the Terms of Service and Privacy Policy', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (!confirmReferences.value) {
      Get.snackbar('References', 'Please confirm that we may contact your professional references', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      final authController = Get.put(AuthController());
      // Prepare Data
      final applicationData = {
        'fullName': fullNameController.text,
        'phone': authController.currentUser.value?.phone ?? '', // Fallback to auth phone, but override with form if possible
        'phoneNumber': authController.currentUser.value?.phone ?? '', // Also included for backwards compat if needed
        'whyJoin': joinCommunityController.text,
        'homeBase': {
          'country': countryController.text,
          'state': selectedState.value?['name'],
          'city': selectedCity.value?['name'],
        },
        'experience': experience.value,
        'disciplines': selectedDisciplines.toList(),
        'otherDiscipline': otherDisciplineController.text,
        'horseLevels': selectedHorseLevels.toList(),
        'regions': selectedRegions.toList(),
        'references': [
          {
            'fullName': ref1FullNameController.text,
            'businessName': ref1BusinessNameController.text,
            'relationship': ref1RelationshipController.text,
          },
          {
            'fullName': ref2FullNameController.text,
            'businessName': ref2BusinessNameController.text,
            'relationship': ref2RelationshipController.text,
          }
        ],
        'highlights': highlightsControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
      };

      // 3. Upload Photos
      final List<String> photoKeys = [];
      for (var photo in photos) {
        final key = await _uploadPhoto(photo);
        if (key != null) photoKeys.add(key);
      }
      applicationData['media'] = photoKeys;

      final profileData = {
        'socialMedia': {
          'facebook': facebookController.text,
          'instagram': instagramController.text,
        }
      };

      final response = await apiService.postRequest('/vendors/setup-service', {
        'serviceType': 'Grooming',
        'applicationData': applicationData,
        'profileData': profileData,
      });

      if (response.statusCode == 200 && response.body['success'] == true) {
        // Update Local User State from server
        final authController = Get.put(AuthController());
        await authController.updateUserMetadata();

        Get.snackbar('Success', 'Your grooming application has been submitted successfully.', backgroundColor: Colors.green, colorText: Colors.white);

        // Handle Redirection
        final List<String> remaining = Get.arguments?['remainingServices'] as List<String>? ?? [];

        if (remaining.isNotEmpty) {
          final nextService = remaining.first;
          final nextRemaining = remaining.skip(1).toList();

          if (nextService == 'Braiding') {
            Get.off(() => const BraidingApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Clipping') {
            Get.off(() => const ClippingApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Bodywork') {
            Get.off(() => const BodyworkApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Farrier') {
            Get.off(() => const FarrierApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Shipping') {
            Get.off(() => const ShippingApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else {
            Get.offAll(() => const VendorApplicationSubmitView());
          }
        } else {
          Get.offAll(() => const VendorApplicationSubmitView());
        }
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Please try again later.', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Error submitting application: $e');
      Get.snackbar('Error', 'Please check your connection and try again.', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }
}
