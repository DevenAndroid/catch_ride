import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/controllers/vendor/bodywork/bodywork_application_controller.dart';
import 'package:catch_ride/view/vendor/vendor_application_submit_view.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/setup_groom_application_view.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_application_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_application_view.dart';
import 'package:catch_ride/view/vendor/complete_profile_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_application_view.dart';

class BodyworkDetailsController extends GetxController {
  final apiService = Get.find<ApiService>();

  // Data from Application (Read-only for details view)
  final location = ''.obs;
  final experience = ''.obs;
  final disciplines = <String>[].obs;
  final horseLevels = <String>[].obs;
  final regionsCovered = <String>[].obs;

  // Services
  final services = <Map<String, dynamic>>[
    {'name': 'Equine massage', 'isSelected': false, 'rates': {'30': '', '45': '', '60': '', '90': ''}},
    {'name': 'Myofascial release', 'isSelected': false, 'rates': {'30': '', '45': '', '60': '', '90': ''}},
    {'name': 'PEMF', 'isSelected': false, 'rates': {'30': '', '45': '', '60': '', '90': ''}},
    {'name': 'Chiropractic', 'isSelected': false, 'rates': {'30': '', '45': '', '60': '', '90': ''}},
    {'name': 'Acupuncture', 'isSelected': false, 'rates': {'30': '', '45': '', '60': '', '90': ''}},
    {'name': 'Laser therapy', 'isSelected': false, 'rates': {'30': '', '45': '', '60': '', '90': ''}},
    {'name': 'Red Light', 'isSelected': false, 'rates': {'30': '', '45': '', '60': '', '90': ''}},
  ].obs;

  // Certifications
  final certifications = <File>[].obs;
  
  // Insurance
  final selectedInsurance = 'Not currently insured'.obs;
  final insuranceDocument = Rxn<File>();
  final expirationDate = Rxn<DateTime>();
  final insuranceOptions = ['Carries Insurance', 'Insurance available upon request', 'Not currently insured'];

  // Travel Preferences
  final selectedTravel = <String>[].obs;
  final travelOptions = ['Local Only', 'Regional', 'Nationwide', 'International'];

  // Cancellation Policy
  final selectedCancellationPolicy = RxnString();
  final isCustomPolicy = false.obs;
  final cancellationOptions = ['24 Hour Notice', '48 Hour Notice', 'Flexible', 'Strict'];

  final isLoading = false.obs;
  final isDataLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchBodyworkData();
  }

  Future<void> fetchBodyworkData() async {
    isDataLoading.value = true;
    try {
      final response = await apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final vendor = response.body['data'];
        final List assignedServices = vendor['assignedServices'] ?? [];
        final bodyworkService = assignedServices.firstWhere((s) => s['serviceType'] == 'Bodywork', orElse: () => null);

        if (bodyworkService != null && bodyworkService['application'] != null) {
          final applicationData = bodyworkService['application']['applicationData'] ?? {};
          
          final city = applicationData['homeBase']?['city'] ?? '';
          final state = applicationData['homeBase']?['state'] ?? '';
          if (city.isNotEmpty && state.isNotEmpty) {
            location.value = '$city, $state, USA';
          }
          
          if (applicationData['experience'] != null) {
            experience.value = '${applicationData['experience']} years';
          }
          
          disciplines.assignAll(List<String>.from(applicationData['disciplines'] ?? []));
          horseLevels.assignAll(List<String>.from(applicationData['horseLevels'] ?? []));
          regionsCovered.assignAll(List<String>.from(applicationData['regions'] ?? []));
        }
      }
    } catch (e) {
      debugPrint('Error fetching bodywork data: $e');
    } finally {
      isDataLoading.value = false;
    }
  }

  Future<void> pickCertification() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      certifications.add(File(file.path));
    }
  }

  Future<void> pickInsuranceDoc() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      insuranceDocument.value = File(file.path);
    }
  }

  void removeCertification(int index) {
    certifications.removeAt(index);
  }

  Future<void> selectExpirationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      expirationDate.value = picked;
    }
  }

  Future<void> submitDetails() async {
    isLoading.value = true;
    try {
      // Simulate API call for saving detailed service data
      await Future.delayed(const Duration(seconds: 1));
      
      Get.snackbar('Success', 'Bodywork details saved successfully.', backgroundColor: AppColors.successPrimary, colorText: AppColors.cardColor);

      // Handle Redirection to next service or success screen
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
        } else {
          Get.offAll(() => const CompleteProfileView());
        }
      } else {
        Get.offAll(() => const CompleteProfileView());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit details');
    } finally {
      isLoading.value = false;
    }
  }
}
