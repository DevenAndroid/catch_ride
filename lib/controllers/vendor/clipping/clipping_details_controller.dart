import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';
import 'package:catch_ride/view/vendor/profile_completed_view.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_details_view.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/grooming_details_view.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_details_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_details_view.dart';
import 'package:catch_ride/view/vendor/shipping/create_profile/shipping_details_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant/app_colors.dart';

class ClippingDetailsController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.put(ApiService());

  static const List<String> cancellationPolicyOptions = [
    'Flexible (24+ hrs)',
    'Moderate (48+ hrs)',
    'Strict (72+ hrs)',
  ];

  // Core Clipping Services
  final clippingServices = <Map<String, dynamic>>[
    {'name': 'Full Body Clip', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Hunter Clip', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Trace Clip', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Bib Clip', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Irish Clip', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Touch Ups', 'isSelected': false.obs, 'price': TextEditingController()},
  ].obs;

  // Add-Ons
  final addOnServices = <Map<String, dynamic>>[
    {'name': 'Bath & Clip Prep', 'isSelected': false.obs, 'price': TextEditingController()},
    {'name': 'Show Clean Up (Face, ears, legs, fetlocks)', 'isSelected': false.obs, 'price': TextEditingController()},
  ].obs;

  final addServiceInputController = TextEditingController();

  void addClippingService(String name) {
    if (name.isNotEmpty) {
      clippingServices.add({
        'name': name,
        'isSelected': true.obs,
        'price': TextEditingController(),
      });
      addServiceInputController.clear();
    }
  }

  // Travel Preferences
  final travelOptions = ['Local Only', 'Regional',];
  final travelFees = <String, Map<String, dynamic>>{}.obs;

  // Temporary controllers for Travel Fee Bottom Sheet
  final travelFeePriceController = TextEditingController();
  final travelFeeNotesController = TextEditingController();
  final selectedTravelFeeType = 'No travel fee'.obs;

  void updateTravelFee(String option, String type, String price, String notes) {
    if (type == 'No travel fee') {
      travelFees.remove(option);
    } else {
      travelFees[option] = {
        'type': type,
        'price': price,
        'notes': notes,
      };
    }
    travelFees.refresh();
  }

  void removeTravelPreference(String option) {
    travelFees.remove(option);
  }

  // Summary Data (Read-only -> Editable)
  final location = 'N/A'.obs;
  final experience = RxnString();
  final experienceOptions = ['0-1', '2-4', '5-9', '10+'];

  final disciplines = <String>[].obs;
  final disciplineOptions = <String>[].obs;

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
    fetchClippingData();
  }

  Future<void> fetchClippingData() async {
    isLoading.value = true;
    try {
      // Fetch options from system config
      final tagResponse = await apiService.getRequest(
        '/system-config/tag-types/with-values?category=Clipping',
      );
      if (tagResponse.statusCode == 200 &&
          tagResponse.body['success'] == true) {
        final List types = tagResponse.body['data'];

        // Populate Disciplines
        final disciplineType = types.firstWhereOrNull(
          (t) => t['name'] == 'Disciplines',
        );
        if (disciplineType != null) {
          disciplineOptions.value = List<String>.from(
            disciplineType['values'].map((v) => v['name']),
          );
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

        // Populate Regions Covered
        final regionType = types.firstWhereOrNull(
          (t) => t['name'] == 'Regions Covered',
        );
        if (regionType != null) {
          regionOptions.value = List<String>.from(
            regionType['values'].map((v) => v['name']),
          );
        }
      }
      final response = await apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final vendor = response.body['data'];

        // 1. Find Clipping application data for base info
        final List assignedServices = vendor['assignedServices'] ?? [];
        final clippingService = assignedServices.firstWhereOrNull((s) => s['serviceType'] == 'Clipping');

        if (clippingService != null && clippingService['application'] != null) {
          final applicationData = clippingService['application']['applicationData'] ?? {};

          final city = applicationData['homeBase']?['city'] ?? '';
          final state = applicationData['homeBase']?['state'] ?? '';
          final country = applicationData['homeBase']?['country'] ?? 'USA';
          location.value = city.isNotEmpty && state.isNotEmpty ? '$city, $state, $country' : 'N/A';
          
          experience.value = applicationData['experience']?.toString();
          disciplines.assignAll(List<String>.from(applicationData['disciplines'] ?? []));
          horseLevels.assignAll(List<String>.from(applicationData['horseLevels'] ?? []));
          operatingRegions.assignAll(List<String>.from(applicationData['regions'] ?? []));
        }

        // 2. Restore saved Services & Rates from servicesData
        final servicesData = vendor['servicesData']?['clipping'];
        if (servicesData != null) {


          final applicationData = servicesData['applicationData'] ?? {};

          final city = applicationData['homeBase']?['city'] ?? '';
          final state = applicationData['homeBase']?['state'] ?? '';
          final country = applicationData['homeBase']?['country'] ?? 'USA';
          location.value = city.isNotEmpty && state.isNotEmpty ? '$city, $state, $country' : 'N/A';

          experience.value = applicationData['experience']?.toString();
          disciplines.assignAll(List<String>.from(applicationData['disciplines'] ?? []));
          horseLevels.assignAll(List<String>.from(applicationData['horseLevels'] ?? []));
          operatingRegions.assignAll(List<String>.from(applicationData['regions'] ?? []));

          final List savedServices = servicesData['services'] ?? [];
          
          // Helper to update a service list
          void updateServiceList(RxList<Map<String, dynamic>> targetList, List savedItems) {
            for (var saved in savedItems) {
              final name = saved['name'];
              final price = saved['price'].toString();
              
              // Find if it exists in our default list
              final existingIndex = targetList.indexWhere((s) => s['name'] == name);
              if (existingIndex != -1) {
                targetList[existingIndex]['isSelected'].value = true;
                (targetList[existingIndex]['price'] as TextEditingController).text = price;
              } else {
                // Add as a custom service
                targetList.add({
                  'name': name,
                  'isSelected': true.obs,
                  'price': TextEditingController(text: price),
                });
              }
            }
          }

          // We don't know which were add-ons or core from the DB easily 
          // unless we save them separately, but for now we can match against names.
          // Separate previously saved into core and add-ons by checking our default lists
          final coreNames = ['Full Body Clip', 'Hunter Clip', 'Trace Clip', 'Bib Clip', 'Irish Clip', 'Touch Ups'];
          
          final savedCore = savedServices.where((s) => coreNames.contains(s['name'])).toList();
          final savedOthers = savedServices.where((s) => !coreNames.contains(s['name'])).toList();

          // Update Core
          for (var saved in savedCore) {
            final existing = clippingServices.firstWhereOrNull((s) => s['name'] == saved['name']);
            if (existing != null) {
              existing['isSelected'].value = true;
              (existing['price'] as TextEditingController).text = saved['price'].toString();
            }
          }

          // Update/Add Add-ons or custom
          for (var saved in savedOthers) {
            final existingAddon = addOnServices.firstWhereOrNull((s) => s['name'] == saved['name']);
            if (existingAddon != null) {
              existingAddon['isSelected'].value = true;
              (existingAddon['price'] as TextEditingController).text = saved['price'].toString();
            } else {
              // It's either a custom add-on or a custom core service
              // Add to core if generic, else add-on? Let's keep it simple: if not in default core, add to add-ons
              addOnServices.add({
                'name': saved['name'],
                'isSelected': true.obs,
                'price': TextEditingController(text: saved['price'].toString()),
              });
            }
          }

          // 3. Restore Travel Preferences
          final List travelPrefs = servicesData['travelPreferences'] ?? [];
          for (var pref in travelPrefs) {
            final region = pref['region'];
            final feeStructure = pref['feeStructure'];
            if (region != null && feeStructure != null) {
              travelFees[region] = Map<String, dynamic>.from(feeStructure);
            }
          }

          // 4. Restore Cancellation Policy (empty API policy must be null for DropdownButton)
          final cancelData = servicesData['cancellationPolicy'];
          if (cancelData != null) {
            isCustomCancellation.value = cancelData['isCustom'] ?? false;
            customCancellationController.text =
                cancelData['customText']?.toString() ?? '';
            final raw = cancelData['policy']?.toString().trim() ?? '';
            if (!isCustomCancellation.value &&
                raw.isNotEmpty &&
                cancellationPolicyOptions.contains(raw)) {
              cancellationPolicy.value = raw;
            } else {
              cancellationPolicy.value = null;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching clipping data: $e');
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
      final vendorId = vendorResponse.body['data']['_id'];

      // Merge with existing servicesData
      final Map<String, dynamic> existingServicesData = Map<String, dynamic>.from(vendorResponse.body['data']['servicesData'] ?? {});
      
      // Update applicationData with new selections
      final Map<String, dynamic> updatedApplicationData = Map<String, dynamic>.from(vendorResponse.body['data']['servicesData']?['clipping']?['applicationData'] ?? {});
      updatedApplicationData['experience'] = experience.value;
      updatedApplicationData['disciplines'] = disciplines.toList();
      updatedApplicationData['horseLevels'] = horseLevels.toList();
      updatedApplicationData['regions'] = operatingRegions.toList();

      existingServicesData['clipping'] = {
        'applicationData': updatedApplicationData,
        'services': [
          ...clippingServices
            .where((s) => s['isSelected'].value == true)
            .map((s) => {
                  'name': s['name'],
                  'price': (s['price'] as TextEditingController).text.replaceAll(',', ''),
                }),
          ...addOnServices
            .where((s) => s['isSelected'].value == true)
            .map((s) => {
                  'name': s['name'],
                  'price': (s['price'] as TextEditingController).text.replaceAll(',', ''),
                })
        ],
        'travelPreferences': travelFees.entries.map((e) => {
          'region': e.key,
          'feeStructure': {
            ...e.value,
            'price': e.value['price']?.toString().replaceAll(',', ''),
          },
        }).toList(),
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
        final authController = Get.put(AuthController());
        await authController.updateUserMetadata();

        final List<String> remaining = Get.arguments?['remainingServices'] as List<String>? ?? [];
        if (remaining.isNotEmpty) {
          final nextService = remaining.first;
          final nextRemaining = remaining.skip(1).toList();

          if (nextService == 'Grooming') {
            Get.off(() => const GroomingDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Braiding') {
            Get.off(() => const BraidingDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Farrier') {
            Get.off(() => const FarrierDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Bodywork') {
            Get.off(() => const BodyworkDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Shipping') {
            Get.off(() => const ShippingDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else {
             Get.offAll(() => const ProfileCompletedView(subtitle: 'Your clipping services are now live', destinationWidget: GroomBottomNav()));
          }
        } else {
          Get.offAll(() => const ProfileCompletedView(subtitle: 'Your clipping services are now live', destinationWidget: GroomBottomNav()));
        }
      } else {
        final errorMsg = response.body['message'] ?? 'Failed to update clipping profile';
        Get.snackbar('Error', errorMsg, backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      }
    } catch (e) {
      debugPrint('Error submitting clipping details: $e');
      Get.snackbar('Error', 'An unexpected error occurred', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    for (var service in clippingServices) {
      (service['price'] as TextEditingController).dispose();
    }
    for (var service in addOnServices) {
      (service['price'] as TextEditingController).dispose();
    }
    customCancellationController.dispose();
    addServiceInputController.dispose();
    travelFeePriceController.dispose();
    travelFeeNotesController.dispose();
    super.onClose();
  }
}
