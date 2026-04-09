import 'dart:io';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/setup_groom_application_view.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_application_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_application_view.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_details_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_application_view.dart';
import 'package:catch_ride/view/vendor/vendor_application_submit_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';
import 'package:catch_ride/constant/app_colors.dart';

class BodyworkApplicationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.find<ApiService>();

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

  // Bodywork Provider Type
  final selectedProviderType = <String>[].obs;
  final providerTypeOptions = <String>[
    'PEMF (e.g. Magnawave)',
    'Massage / Myofascial',
    'Laser',
    'Acupuncturist',
    'Chiropractor',
    'Red Light Therapy',
    'Veterinary',
    'Other'
  ].obs;

  // Certification
  final selectedCertifications = <String>[].obs;
  final otherCertificationController = TextEditingController();
  final certificationOptions = <String>['AFA', 'BWFA', 'Other'].obs; // Will fetch from tags

  // Insurance
  final selectedInsurance = RxnString();
  final insuranceOptions = <String>[
    'Carries insurance',
    'Insurance details upon request',
    'Not currently insured'
  ].obs;
  final policyNumberController = TextEditingController();

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

  // References
  final ref1FullNameController = TextEditingController();
  final ref1BusinessNameController = TextEditingController();
  final ref1RelationshipController = TextEditingController();

  final ref2FullNameController = TextEditingController();
  final ref2BusinessNameController = TextEditingController();
  final ref2RelationshipController = TextEditingController();

  // Experience Highlights
  final highlightsControllers = <TextEditingController>[TextEditingController()].obs;

  // Experience level dropdown
  final experience = RxnString();
  final List<String> experienceOptions = List.generate(51, (index) => index.toString());

  // Checkboxes
  final is18OrOlder = false.obs;
  final agreeToTerms = false.obs;
  final confirmReferences = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();
    fullNameController.text = authController.currentUser.value?.fullName ?? '';
    fetchStates();
    fetchDynamicTags();
  }

  Future<void> fetchStates() async {
    isLoadingStates.value = true;
    try {
      final Response response = await apiService.getRequest('/locations/states');
      if (response.statusCode == 200 && response.body['success'] == true) {
        states.assignAll(List<Map<String, dynamic>>.from(response.body['data']));
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
        cities.assignAll(List<Map<String, dynamic>>.from(response.body['data']));
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
      final Response response = await apiService.getRequest('/system-config/tag-types/with-values?category=Bodywork');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List types = response.body['data'];
        
        // Populate Disciplines
        final disciplineType = types.firstWhereOrNull(
            (t) => t['name'] == 'Disciplines' || t['name'] == 'Discipline');
        if (disciplineType != null) {
          disciplineOptions.assignAll(List<String>.from(
              disciplineType['values'].map((v) => v['name'])));
          if (!disciplineOptions.contains('Other')) disciplineOptions.add('Other');
        }

        // Populate Level of Horses
        final horseLevelType = types.firstWhereOrNull((t) =>
            t['name'] == 'Typical Level of Horses' ||
            t['name'] == 'Typical Level of Horse');
        if (horseLevelType != null) {
          horseLevelOptions.assignAll(
              List<String>.from(horseLevelType['values'].map((v) => v['name'])));
        }

        // Populate Regions Covered
        final regionType = types.firstWhereOrNull(
            (t) => t['name'] == 'Regions Covered' || t['name'] == 'Region Covered');
        if (regionType != null) {
          regionOptions.assignAll(
              List<String>.from(regionType['values'].map((v) => v['name'])));
        }

        // Certification Options
        final certType = types.firstWhereOrNull(
            (t) => t['name'] == 'Certifications' || t['name'] == 'Certification');
        if (certType != null) {
          certificationOptions.assignAll(
              List<String>.from(certType['values'].map((v) => v['name'])));
        }
        
        debugPrint('Bodywork tags loaded: Disciplines(${disciplineOptions.length}), '
            'Levels(${horseLevelOptions.length}), Regions(${regionOptions.length}), '
            'Certs(${certificationOptions.length})');
      } else {
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
      disciplineOptions.assignAll(['Hunter / Jumper', 'Dressage', 'Eventing', 'Other']);
    }
    if (horseLevelOptions.isEmpty) {
      horseLevelOptions.assignAll(['Grand Prix', 'Young Horses', 'School Horses', 'Pony / Minis']);
    }
    if (regionOptions.isEmpty) {
      regionOptions.assignAll([
        'Texas (Split Rock / Texas Circuits)',
        'Florida (Wellington / Ocala / Gulf coast)',
        'Southwest (Thermal / AZ winter circuits)',
        'Southeast (Aiken / Tryon / Wills Park / Chatt Hills)',
      ]);
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      photos.add(File(image.path));
    }
  }

  void removeImage(int index) {
    photos.removeAt(index);
  }

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

  @override
  void onClose() {
    fullNameController.dispose();
    joinCommunityController.dispose();
    otherDisciplineController.dispose();
    otherCertificationController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    policyNumberController.dispose();
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
        'type': 'bodywork',
      });
      final response = await apiService.postRequest('/upload?type=bodywork', formData);
      if (response.statusCode == 200 && response.body['success'] == true) {
        return response.body['data']['filename'];
      }
    } catch (e) {
      debugPrint('Error uploading photo: $e');
    }
    return null;
  }

  Future<void> submitApplication() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (!is18OrOlder.value) {
      Get.snackbar('Age Verification', 'Please confirm that you are at least 18 years of age', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      return;
    }

    if (!agreeToTerms.value) {
      Get.snackbar('Terms & Privacy', 'Please agree to the Terms of Service and Privacy Policy', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      return;
    }

    if (!confirmReferences.value) {
      Get.snackbar('References', 'Please confirm that we may contact your professional references', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      return;
    }

    isSubmitting.value = true;
    try {
      final authController = Get.find<AuthController>();
      final applicationData = {
        'fullName': fullNameController.text,
        'phone': authController.currentUser.value?.phone ?? '', 
        'whyJoin': joinCommunityController.text,
        'providerType': selectedProviderType.toList(),
        'homeBase': {
          'country': countryController.text,
          'state': selectedState.value?['name'],
          'city': selectedCity.value?['name'],
        },
        'experience': experience.value,
        'insurance': {
          'status': selectedInsurance.value,
          'policyNumber': policyNumberController.text,
        },
        'certifications': selectedCertifications.toList(),
        'otherCertification': otherCertificationController.text,
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
        'serviceType': 'Bodywork',
        'applicationData': applicationData,
        'profileData': profileData,
      });

      if (response.statusCode == 200 && response.body['success'] == true) {
        await authController.updateUserMetadata();

        Get.to(() => const VendorApplicationSubmitView(), arguments: Get.arguments);
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Please try again later.', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      }
    } catch (e) {
      debugPrint('Error submitting application: $e');
      Get.snackbar('Error', 'Please check your connection and try again.', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
    } finally {
      isSubmitting.value = false;
    }
  }
}
