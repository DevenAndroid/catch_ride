import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';
import 'package:catch_ride/view/vendor/profile_completed_view.dart';
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
  final travelOptions = ['Local Only', 'Regional', 'Nationwide', 'International'];
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
        
        // Find Clipping service from assigned services
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
        } else {
          // Fallback to vendor top level fields if not using the application-specific data yet
          location.value = vendor['city'] != null ? '${vendor['city']}, ${vendor['state']}, USA' : 'N/A';
          experience.value = vendor['experience'] != null ? '${vendor['experience']} years' : 'N/A';
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

      final body = {
        'servicesData': {
          'clipping': {
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
          }
        },
        'isProfileSetup': true,
        'isProfileCompleted': true,
      };

      final response = await apiService.putRequest('/vendors/$vendorId', body);
      if (response.statusCode == 200 && response.body['success'] == true) {
        final authController = Get.put(AuthController());
        await authController.updateUserMetadata();

        Get.offAll(() => const ProfileCompletedView(
          subtitle: 'Your clipping services are now live',
          destinationWidget: GroomBottomNav(),
        ));
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
