import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/utils/vendor_travel_preference_payload.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';
import 'package:catch_ride/view/vendor/profile_completed_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_detail_view.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_details_view.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/grooming_details_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_details_view.dart';
import 'package:catch_ride/view/vendor/shipping/create_profile/shipping_details_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/system_config_controller.dart';

class BraidingDetailsController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.find<ApiService>();

  /// Must match labels in [BraidingDetailsView] cancellation dropdown.
  static const List<String> cancellationPolicyOptions = [
    'Flexible (24+ hrs)',
    'Moderate (48+ hrs)',
    'Strict (72+ hrs)',
  ];

  // Core Braiding Services
  final braidingServices = <Map<String, dynamic>>[
    {'name': 'Hunter Mane & Tail', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Hunter Mane Only', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Hunter Tail Only', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Jumper Braids', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Dressage Braids', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Mane Pull / Clean Up', 'isSelected': false.obs, 'price': TextEditingController()},
  ].obs;

  final addServiceInputController = TextEditingController();
  final addServicePriceController = TextEditingController();

  void addBraidingService(String name, String price) {
    if (name.isNotEmpty) {
      final newPriceController = TextEditingController();
      if (price.isNotEmpty) {
        newPriceController.text = price;
      }
      braidingServices.add({
        'name': name,
        'isSelected': true.obs,
        'price': newPriceController,
      });
      addServiceInputController.clear();
      addServicePriceController.clear();
    }
  }

  // Travel Preferences
  final travelOptions = ['Local Only', 'Regional', 'Nationwide', 'International'];
  final selectedTravel = <String>{}.obs;

  void toggleTravel(String item) {
    if (selectedTravel.contains(item)) {
      selectedTravel.remove(item);
    } else {
      selectedTravel.add(item);
    }
  }

  // Summary Data (Read-only -> Editable)
  final location = 'N/A'.obs;
  final experience = RxnString();
  final experienceOptions = ['0-1', '2-4', '5-9', '10+'];

  final disciplines = <String>[].obs;
  final disciplineOptions = <String>[].obs;
  final otherDisciplineController = TextEditingController();

  final horseLevels = <String>[].obs;
  final horseLevelOptions = <String>[].obs;

  final operatingRegions = <String>[].obs;
  final regionOptions = <String>[].obs;

  void toggleDiscipline(String disc) {
    if (disciplines.contains(disc)) {
      disciplines.remove(disc);
    } else {
      disciplines.add(disc);
    }
  }

  void toggleHorseLevel(String level) {
    if (horseLevels.contains(level)) {
      horseLevels.remove(level);
    } else {
      horseLevels.add(level);
    }
  }

  void toggleRegion(String region) {
    if (operatingRegions.contains(region)) {
      operatingRegions.remove(region);
    } else {
      operatingRegions.add(region);
    }
  }

  final isLoading = false.obs; // For initial fetching
  final isSubmitting = false.obs; // For form submission

  // Cancellation Policy
  final cancellationPolicy = RxnString();
  final isCustomCancellation = false.obs;
  final customCancellationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchBraidingData();
  }

  Future<void> fetchBraidingData() async {
    isLoading.value = true;
    try {
      // Fetch options from system config
      final tagResponse = await apiService.getRequest(
        '/system-config/tag-types/with-values?category=Braiding',
      );
      if (tagResponse.statusCode == 200 &&
          tagResponse.body['success'] == true) {
        final List types = tagResponse.body['data'];

        // Populate Disciplines
        final disciplineType = types.firstWhereOrNull(
          (t) => t['name'] == 'Disciplines',
        );
        if (disciplineType != null) {
          final values = List<String>.from(
            disciplineType['values'].map((v) => v['name']),
          );
          if (!values.contains('Other')) values.add('Other');
          disciplineOptions.value = values;
        }

        // Populate Level of Horses
        final horseLevelType = types.firstWhereOrNull(
          (t) => t['name'] == 'Typical Level of Horses',
        );
        if (horseLevelType != null) {
          horseLevelOptions.value = List<String>.from(
            horseLevelType['values'].map((v) => v['name']),
          );
        }

      }
      // Use SystemConfigController for regions (single source of truth)
      final systemConfig = Get.find<SystemConfigController>();
      if (systemConfig.regions.isEmpty) await systemConfig.fetchRegions();
      regionOptions.assignAll(systemConfig.regionNames);
      final response = await apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final vendor = response.body['data'];
        
        final servicesData = vendor['servicesData'] ?? {};
        final applicationData = servicesData['Braiding'] ?? servicesData['braiding']?['applicationData'] ?? {};
        
        final city = applicationData['homeBase']?['city'] ?? vendor['city'] ?? '';
        final state = applicationData['homeBase']?['state'] ?? vendor['state'] ?? '';
        location.value = city.isNotEmpty && state.isNotEmpty ? '$city, $state, USA' : '';
        
        experience.value = applicationData['experience']?.toString();
        
        // Decode: separate known-option chips from the custom "Other" text.
        // The array stores only real values — 'Other' is never saved, only the typed text is.
        final rawDiscs = List<String>.from(applicationData['disciplines'] ?? []);
        final knownOpts = Set<String>.from(disciplineOptions);
        final standardDiscs = rawDiscs.where((d) => knownOpts.contains(d)).toList();
        final customEntry = rawDiscs.firstWhereOrNull((d) => !knownOpts.contains(d));
        if (customEntry != null) {
          // Restore 'Other' chip as selected and fill the text field
          disciplines.assignAll([...standardDiscs, 'Other']);
          otherDisciplineController.text = customEntry;
        } else {
          disciplines.assignAll(standardDiscs);
          otherDisciplineController.text = '';
        }
        horseLevels.assignAll(List<String>.from(applicationData['horseLevels'] ?? []));
        final List rawRegions = applicationData['regions'] ?? applicationData['regionsCovered'] ?? [];
        final List<String> regionNames = rawRegions.map((r) {
          final rStr = r.toString();
          final regionObj = systemConfig.regions.firstWhereOrNull((reg) => reg['_id'].toString() == rStr);
          if (regionObj != null) {
            return (regionObj['region'] ?? regionObj['label'] ?? regionObj['name'] ?? rStr).toString();
          }
          return rStr;
        }).toList();
        operatingRegions.assignAll(regionNames);
        
        final braidingData = servicesData['braiding'] ?? {};
        if (braidingData['travelPreferences'] != null) {
          selectedTravel.assignAll(
            VendorTravelPreferencePayload.groomBraidLabelsFromApiList(
              List<dynamic>.from(braidingData['travelPreferences']),
            ),
          );
        }

        final cancellationPolicyData = braidingData['cancellationPolicy'];
        if (cancellationPolicyData != null) {
          isCustomCancellation.value =
              cancellationPolicyData['isCustom'] ?? false;
          customCancellationController.text =
              cancellationPolicyData['customText']?.toString() ?? '';
          final raw =
              cancellationPolicyData['policy']?.toString().trim() ?? '';
          if (!isCustomCancellation.value &&
              raw.isNotEmpty &&
              cancellationPolicyOptions.contains(raw)) {
            cancellationPolicy.value = raw;
          } else {
            cancellationPolicy.value = null;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching braiding data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submit() async {
    isSubmitting.value = true;
    try {
      final vendorResponse = await apiService.getRequest('/vendors/me');
      if (vendorResponse.statusCode != 200 || vendorResponse.body['success'] != true) {
        Get.snackbar('Error', 'Failed to fetch vendor details', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
        return;
      }
      final vendorId = vendorResponse.body['data']['_id']?? vendorResponse.body['data']['id'];

      // Merge with existing servicesData
      final Map<String, dynamic> existingServicesData = Map<String, dynamic>.from(vendorResponse.body['data']['servicesData'] ?? {});
      
      // Update applicationData with new selections
      final Map<String, dynamic> updatedApplicationData = Map<String, dynamic>.from(vendorResponse.body['data']['servicesData']?['braiding']?['applicationData'] ?? {});
      updatedApplicationData['experience'] = experience.value;
      // Save: strip the 'Other' sentinel — only add the typed text to the array.
      final customText = otherDisciplineController.text.trim();
      final discsToSave = disciplines.where((d) => d != 'Other').toList();
      if (customText.isNotEmpty) discsToSave.add(customText);
      updatedApplicationData['disciplines'] = discsToSave;
      updatedApplicationData['horseLevels'] = horseLevels.toList();
      final systemConfig = Get.find<SystemConfigController>();
      updatedApplicationData['regions'] = operatingRegions.map((name) {
        final r = systemConfig.regions.firstWhereOrNull(
            (r) => (r['region'] ?? r['label'] ?? r['name'] ?? '').toString() == name);
        return r != null ? r['_id'].toString() : name;
      }).toList();

      existingServicesData['braiding'] = {
        'applicationData': updatedApplicationData,
        'services': braidingServices
            .where((s) => s['isSelected'].value == true)
            .map((s) => {
                  'name': s['name'],
                  'price': (s['price'] as TextEditingController).text.replaceAll(',', ''),
                })
            .toList(),
        'travelPreferences':
            VendorTravelPreferencePayload.groomBraidTravelToApi(selectedTravel.toList()),
        'cancellationPolicy': {
          'policy': cancellationPolicy.value,
          'isCustom': isCustomCancellation.value,
          'customText': customCancellationController.text,
        },
      };

      final body = {
        'servicesData': existingServicesData,
        'isProfileSetup': true,
      };

      final response = await apiService.putRequest('/vendors/me', body);
      if (response.statusCode == 200 && response.body['success'] == true) {
        final authController = Get.find<AuthController>();
        await authController.updateUserMetadata();

        final List<String> remaining = Get.arguments?['remainingServices'] as List<String>? ?? [];
        if (remaining.isNotEmpty) {
          final nextService = remaining.first;
          final nextRemaining = remaining.skip(1).toList();

          if (nextService == 'Clipping') {
            Get.off(() => const ClippingDetailView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Grooming') {
            Get.off(() => const GroomingDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Farrier') {
            Get.off(() => const FarrierDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Bodywork') {
            Get.off(() => const BodyworkDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Shipping') {
            Get.off(() => const ShippingDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else {
             Get.offAll(() => const ProfileCompletedView(subtitle: 'Your braiding services are now live', destinationWidget: GroomBottomNav()));
          }
        } else {
          Get.offAll(() => const ProfileCompletedView(subtitle: 'Your braiding services are now live', destinationWidget: GroomBottomNav()));
        }
      } else {
        final errorMsg = response.body['message'] ?? 'Failed to update braiding profile';
        Get.snackbar('Error', errorMsg, backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      }
    } catch (e) {
      debugPrint('Error submitting braiding details: $e');
      Get.snackbar('Error', 'An unexpected error occurred', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    for (var service in braidingServices) {
      (service['price'] as TextEditingController).dispose();
    }
    customCancellationController.dispose();
    otherDisciplineController.dispose();
    addServiceInputController.dispose();
    addServicePriceController.dispose();
    super.onClose();
  }
}
