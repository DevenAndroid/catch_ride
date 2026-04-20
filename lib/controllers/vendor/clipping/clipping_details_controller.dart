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
  final addServicePriceController = TextEditingController();

  void addClippingService(String name, String price) {
    if (name.isNotEmpty) {
      clippingServices.add({
        'name': name,
        'isSelected': true.obs,
        'price': TextEditingController(text: price),
      });
      addServiceInputController.clear();
      addServicePriceController.clear();
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
    travelFees[option] = {
      'type': type,
      'price': price,
      'notes': notes,
    };
  }

  void removeTravelPreference(String option) {
    travelFees.remove(option);
  }

  // Pre-filled / Read-only info from Application
  final location = 'N/A'.obs;
  final experience = 'N/A'.obs;
  final disciplines = <String>[].obs;
  final horseLevels = <String>[].obs;
  final operatingRegions = <String>[].obs;
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
          
          experience.value = applicationData['experience'] != null ? '${applicationData['experience']} years' : 'N/A';
          disciplines.assignAll(List<String>.from(applicationData['disciplines'] ?? []));
          horseLevels.assignAll(List<String>.from(applicationData['horseLevels'] ?? []));
          operatingRegions.assignAll(List<String>.from(applicationData['regions'] ?? []));
        }

        // 2. Restore saved Services & Rates from servicesData
        final servicesData = vendor['servicesData']?['clipping'];
        if (servicesData != null) {
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

          // 4. Restore Cancellation Policy
          final cancelData = servicesData['cancellationPolicy'];
          if (cancelData != null) {
            cancellationPolicy.value = cancelData['policy'];
            isCustomCancellation.value = cancelData['isCustom'] ?? false;
            customCancellationController.text = cancelData['customText'] ?? '';
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
      
      existingServicesData['clipping'] = {
        'services': [
          ...clippingServices
            .where((s) => s['isSelected'].value == true)
            .map((s) => {
                  'name': s['name'],
                  'price': (s['price'] as TextEditingController).text,
                }),
          ...addOnServices
            .where((s) => s['isSelected'].value == true)
            .map((s) => {
                  'name': s['name'],
                  'price': (s['price'] as TextEditingController).text,
                })
        ],
        'travelPreferences': travelFees.entries.map((e) => {
          'region': e.key,
          'feeStructure': e.value,
        }).toList(),
        'cancellationPolicy': {
          'policy': cancellationPolicy.value,
          'isCustom': isCustomCancellation.value,
          'customText': customCancellationController.text,
        },
        'isProfileCompleted': true,
      };

      final body = {
        'servicesData': existingServicesData,
        'isProfileSetup': true,
        'isProfileCompleted': true,
      };

      final response = await apiService.putRequest('/vendors/$vendorId', body);
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
    addServicePriceController.dispose();
    travelFeePriceController.dispose();
    travelFeeNotesController.dispose();
    super.onClose();
  }
}
