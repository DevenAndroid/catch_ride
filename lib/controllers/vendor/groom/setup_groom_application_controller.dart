import 'dart:io';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_application_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_application_view.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_application_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_application_view.dart';
import 'package:catch_ride/view/vendor/shipping/create_profile/shipping_application_view.dart';
import 'package:catch_ride/controllers/vendor/common_application_controller.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';

import '../../../utils/vendor_setup_application_payload.dart';
import '../../../view/vendor/vendor_application_submit_view.dart';

class SetupGroomApplicationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.put(ApiService());
  final authController = Get.find<AuthController>();

  final isLoadingTags = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDynamicTags();
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
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      photos.addAll(images.map((image) => File(image.path)));
    }
  }

  void removeImage(int index) {
    photos.removeAt(index);
  }


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

  final isSubmitting = false.obs;

  @override
  void onClose() {
    for (var ctrl in highlightsControllers) {
      ctrl.dispose();
    }
    otherDisciplineController.dispose();
    facebookController.dispose();
    instagramController.dispose();
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


    isSubmitting.value = true;
    try {
      final commonCtrl = Get.find<CommonApplicationController>();
      
      // Prepare Data (VendorModel preform-aligned keys + fields used by setupVendorService user sync)
      final applicationData = {
        'fullName': commonCtrl.fullNameController.text,
        'phone': authController.currentUser.value?.phone ?? '',
        'phoneNumber': authController.currentUser.value?.phone ?? '',
        'whyJoin': commonCtrl.joinCommunityController.text,
        'homeBase': vendorHomeBaseFromCommon(commonCtrl),
        'experience': experience.value,
        // VendorModel typo: desciplines
        'desciplines': selectedDisciplines.toList(),
        'otherDiscipline': otherDisciplineController.text,
        'typicalLevelOfHorses': selectedHorseLevels.toList(),
        'regionsCovered': selectedRegions.toList(),
        'professionalReferences': vendorProfessionalReferencesFromCommon(commonCtrl),
        'experienceHighlights': highlightsControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
        'facebookLink': facebookController.text,
        'instagramLink': instagramController.text,
      };

      // 3. Upload Photos
      final List<String> photoKeys = [];
      for (var photo in photos) {
        final key = await _uploadPhoto(photo);
        if (key != null) photoKeys.add(key);
      }
      applicationData['media'] = photoKeys;

      final profileData = <String, dynamic>{};

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
