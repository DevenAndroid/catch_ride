import 'dart:io';

import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/vendor/vendor_application_submit_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_application_view.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/setup_groom_application_view.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_application_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_application_view.dart';
import 'package:catch_ride/view/vendor/shipping/create_profile/shipping_application_view.dart';
import 'package:catch_ride/controllers/vendor/common_application_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';

class BraidingApplicationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.put(ApiService());

  final isLoadingTags = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDynamicTags();
  }


  Future<void> fetchDynamicTags() async {
    isLoadingTags.value = true;
    try {
      final Response response = await apiService.getRequest('/system-config/tag-types/with-values?category=Braiding');
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
      } else {
        // Fallback to defaults from screenshot if API fails
        _setFallbackOptions();
      }
    } catch (e) {
      _setFallbackOptions();
      debugPrint('Error fetching tags: $e');
    } finally {
      isLoadingTags.value = false;
    }
  }

  void _setFallbackOptions() {
    if (disciplineOptions.isEmpty) {
      disciplineOptions.value = ['Jumper', 'Dressage', 'Eventing', 'Hunter', 'Other'];
    }
    if (horseLevelOptions.isEmpty) {
      horseLevelOptions.value = ['Grand Prix', 'FEI / International', 'A/AA Circuit', 'Young Horses'];
    }
    if (regionOptions.isEmpty) {
      regionOptions.value = [
        'Texas (Split Rock / Texas Circuits)',
        'Florida (Wellington - Ocala - Gulf coast)',
        'Southwest (Thermal / AZ winter circuits)',
        'Southeast (Aiken / Tryon / Wills Park / Chatt Hills)',
      ];
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
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      photos.addAll(images.map((image) => File(image.path)));
    }
  }

  void removeImage(int index) {
    photos.removeAt(index);
  }




  final isSubmitting = false.obs;

  @override
  void onClose() {
    otherDisciplineController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    super.onClose();
  }

  Future<String?> _uploadPhoto(File file) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': 'braiding',
      });
      final response = await apiService.postRequest('/upload?type=braiding', formData);
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


    if (experience.value == null) {
      Get.snackbar('Missing Info', 'Please select your braiding experience level', backgroundColor: Colors.red, colorText: Colors.white);
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


    isSubmitting.value = true;
    try {
      final authController = Get.put(AuthController());
      final commonCtrl = Get.find<CommonApplicationController>();
      
      // Prepare Data
      final applicationData = {
        'fullName': commonCtrl.fullNameController.text,
        'phone': authController.currentUser.value?.phone ?? '', 
        'whyJoin': commonCtrl.joinCommunityController.text,
        'homeBase': {
          'country': commonCtrl.countryController.text,
          'state': commonCtrl.selectedState.value?['name'],
          'city': commonCtrl.selectedCity.value?['name'],
        },
        'experience': experience.value,
        'disciplines': selectedDisciplines.toList(),
        'otherDiscipline': otherDisciplineController.text,
        'horseLevels': selectedHorseLevels.toList(),
        'regions': selectedRegions.toList(),
        'references': [
          {
            'fullName': commonCtrl.ref1FullNameController.text,
            'businessName': commonCtrl.ref1BusinessNameController.text,
            'relationship': commonCtrl.ref1RelationshipController.text,
            'phone': commonCtrl.ref1PhoneController.text,
          },
          {
            'fullName': commonCtrl.ref2FullNameController.text,
            'businessName': commonCtrl.ref2BusinessNameController.text,
            'relationship': commonCtrl.ref2RelationshipController.text,
            'phone': commonCtrl.ref2PhoneController.text,
          }
        ],
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
        'serviceType': 'Braiding',
        'applicationData': applicationData,
        'profileData': profileData,
      });

      if (response.statusCode == 200 && response.body['success'] == true) {
        // Update Local User State from server
        final authController = Get.put(AuthController());
        await authController.updateUserMetadata();

        Get.snackbar('Success', 'Your braiding application has been submitted successfully.', backgroundColor: Colors.green, colorText: Colors.white);

        final List<String> remaining = Get.arguments?['remainingServices'] as List<String>? ?? [];
        if (remaining.isNotEmpty) {
          final nextService = remaining.first;
          final nextRemaining = remaining.skip(1).toList();

          if (nextService == 'Grooming') {
            Get.off(() => const SetupGroomApplicationView(), arguments: {'remainingServices': nextRemaining});
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
