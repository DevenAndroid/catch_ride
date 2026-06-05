import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/system_config_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:catch_ride/controllers/vendor/common_application_controller.dart';
import 'package:catch_ride/view/vendor/vendor_application_submit_view.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/setup_groom_application_view.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_application_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_application_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_application_view.dart';
import 'package:catch_ride/view/vendor/shipping/create_profile/shipping_application_view.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/utils/vendor_setup_application_payload.dart';

class BodyworkApplicationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.find<ApiService>();
  final authController = Get.find<AuthController>();

  final isLoadingTags = false.obs;



  // Insurance
  final selectedInsurance = RxnString();
  final insuranceOptions = <String>[
    'Carries Insurance',
    'Insurance available upon request',
    'Not currently insured'
  ].obs;
  final insuranceFile = Rxn<File>();
  final insuranceExpiry = RxnString();

  // Disciplines
  final selectedDisciplines = <String>[].obs;
  final disciplineOptions = <String>[].obs;
  final otherDisciplineController = TextEditingController();

  // Modality Offered
  final selectedModalities = <String>[].obs;
  final modalityOptions = <String>[].obs;
  final otherModalityController = TextEditingController();

  // Level of Horses
  final selectedHorseLevels = <String>[].obs;
  final horseLevelOptions = <String>[].obs;

  // Regions
  final selectedRegions = <String>[].obs;
  final regionOptions = <String>[].obs;

  // Social Media
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();


  // policy number
  final policyNumberController = TextEditingController();

  // Photos
  final photos = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  // Certifications
  final certificates = <File>[].obs;


  // Experience Highlights
  final highlightsControllers = <TextEditingController>[TextEditingController()].obs;

  // Experience level dropdown
  final experience = RxnString();
  final List<String> experienceOptions = ['0-1', '2-4', '5-9', '10+'];


  // Professional Standards
  final confirmSupportiveBodywork = false.obs;
  final confirmReferToVet = false.obs;
  final confirmVetApproval = false.obs;
  final confirmWithinScope = false.obs;

  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDynamicTags();
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
        final modalityOptionsType= types.firstWhereOrNull((t) =>
        t['name'] == 'Modality Offered' ||
            t['name'] == 'Modality Offered');
        if (modalityOptionsType != null) {
          modalityOptions.assignAll(
              List<String>.from(modalityOptionsType['values'].map((v) => v['name'])));
        }


        // Use Global Regions API
        final systemConfig = Get.find<SystemConfigController>();
        if (systemConfig.regions.isEmpty) await systemConfig.fetchRegions();
        regionOptions.assignAll(systemConfig.regionNames);
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
    
    if (modalityOptions.isEmpty) {
      modalityOptions.assignAll(['Sports Massage', 'Myofascial Release', 'PEMF', 'Chiropractic', 'Acupuncture', 'Other']);
    }
  }

  Future<void> pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      certificates.add(File(result.files.single.path!));
    }
  }

  void removeCertificate(int index) {
    certificates.removeAt(index);
  }

  Future<void> pickInsuranceDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      insuranceFile.value = File(result.files.single.path!);
    }
  }

  void pickInsuranceExpiry(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      insuranceExpiry.value = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      photos.addAll(images.map((image) => File(image.path)));
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
    for (var ctrl in highlightsControllers) {
      ctrl.dispose();
    }
    otherDisciplineController.dispose();
    otherModalityController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    policyNumberController.dispose();
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

  Future<String?> _uploadCertificate(File file) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': 'certification',
      });
      final response = await apiService.postRequest('/upload?type=certification', formData);
      if (response.statusCode == 200 && response.body['success'] == true) {
        return response.body['data']['filename'];
      }
    } catch (e) {
      debugPrint('Error uploading certificate: $e');
    }
    return null;
  }

  Future<void> submitApplication() async {
    if (!(formKey.currentState?.validate() ?? false)) return;


    if (!confirmSupportiveBodywork.value || !confirmReferToVet.value || !confirmVetApproval.value || !confirmWithinScope.value) {
      Get.snackbar('Professional Standards', 'Please confirm all Professional Standards and Scope conditions', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      return;
    }

    isSubmitting.value = true;
    try {
      final commonCtrl = Get.find<CommonApplicationController>();

      final List<String> photoKeys = [];
      for (var photo in photos) {
        final key = await _uploadPhoto(photo);
        if (key != null) photoKeys.add(key);
      }

      final List<String> certificateKeys = [];
      for (var cert in certificates) {
        final key = await _uploadCertificate(cert);
        if (key != null) certificateKeys.add(key);
      }

      final List<String> insuranceFileKeys = [];
      if (insuranceFile.value != null) {
        final key = await _uploadCertificate(insuranceFile.value!);
        if (key != null) insuranceFileKeys.add(key);
      }

      final applicationData = <String, dynamic>{
        'fullName': commonCtrl.fullNameController.text,
        'phone': authController.currentUser.value?.phone ?? '',
        'whyJoin': commonCtrl.joinCommunityController.text,
        'homeBase': vendorHomeBaseFromCommon(commonCtrl),
        'experience': experience.value,
        'modalityOffered': selectedModalities.toList(),
        'otherModality': otherModalityController.text,
        'desciplines': selectedDisciplines.toList(),
        'otherDiscipline': otherDisciplineController.text,
        'typicalLevelOfHorses': selectedHorseLevels.toList(),
        'regionsCovered': selectedRegions.map((regionName) {
        final systemConfig = Get.find<SystemConfigController>();
        final regionObj = systemConfig.regions.firstWhereOrNull(
            (r) => (r['region'] ?? r['label'] ?? r['name'] ?? '').toString() == regionName);
        return regionObj != null ? regionObj['_id'].toString() : regionName;
      }).toList(),
        'professionalReferences': vendorProfessionalReferencesFromCommon(commonCtrl),
        'experienceHighlights': highlightsControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
        'facebookLink': facebookController.text,
        'instagramLink': instagramController.text,
        'certification': certificateKeys,
        'insurance': {
          'file': insuranceFileKeys,
          'insuranceStatus': selectedInsurance.value ?? '',
          'expirationDate': insuranceExpiry.value ?? '',
        },
        'media': photoKeys,
        'standards': {
          'provideSupportiveBodywork': confirmSupportiveBodywork.value,
          'refertoVet': confirmReferToVet.value,
          'vetApprovalRequired': confirmVetApproval.value,
          'operateWithinScope': confirmWithinScope.value,
        },
      };

      final profileData = <String, dynamic>{};

      final response = await apiService.postRequest('/vendors/setup-service', {
        'serviceType': 'Bodywork',
        'applicationData': applicationData,
        'profileData': profileData,
      });

      if (response.statusCode == 200 && response.body['success'] == true) {
        await authController.updateUserMetadata();

        final List<String> remaining = Get.arguments?['remainingServices'] as List<String>? ?? [];
        if (remaining.isNotEmpty) {
          final nextService = remaining.first;
          final nextRemaining = remaining.skip(1).toList();

          if (nextService == 'Grooming') {
            Get.off(() => const SetupGroomApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Braiding') {
            Get.off(() => const BraidingApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Clipping') {
            Get.off(() => const ClippingApplicationView(), arguments: {'remainingServices': nextRemaining});
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
