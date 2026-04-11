import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';
import 'package:catch_ride/view/vendor/profile_completed_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_detail_view.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_details_view.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/grooming_details_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_details_view.dart';
import 'package:catch_ride/view/vendor/shipping/create_profile/shipping_details_view.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BraidingDetailsController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.find<ApiService>();

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

  void addBraidingService(String name) {
    if (name.isNotEmpty) {
      braidingServices.add({
        'name': name,
        'isSelected': true.obs,
        'price': TextEditingController(),
      });
      addServiceInputController.clear();
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
    fetchBraidingData();
  }

  Future<void> fetchBraidingData() async {
    isLoading.value = true;
    try {
      final response = await apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final vendor = response.body['data'];
        
        // Find Braiding service
        final List assignedServices = vendor['assignedServices'] ?? [];
        final braidingService = assignedServices.firstWhereOrNull((s) => s['serviceType'] == 'Braiding');

        if (braidingService != null && braidingService['application'] != null) {
          final applicationData = braidingService['application']['applicationData'] ?? {};
          
          final city = applicationData['homeBase']?['city'] ?? '';
          final state = applicationData['homeBase']?['state'] ?? '';
          location.value = city.isNotEmpty && state.isNotEmpty ? '$city, $state, USA' : 'N/A';
          
          experience.value = applicationData['experience'] != null ? '${applicationData['experience']} Years' : 'N/A';
          disciplines.assignAll(List<String>.from(applicationData['disciplines'] ?? []));
          horseLevels.assignAll(List<String>.from(applicationData['horseLevels'] ?? []));
          operatingRegions.assignAll(List<String>.from(applicationData['regions'] ?? []));
        } else {
          // Fallback to vendor level fields
          location.value = vendor['city'] != null ? '${vendor['city']}, ${vendor['state']}, USA' : 'N/A';
          experience.value = vendor['experience'] ?? 'N/A';
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
      final vendorId = vendorResponse.body['data']['_id'];

      // Merge with existing servicesData
      final Map<String, dynamic> existingServicesData = Map<String, dynamic>.from(vendorResponse.body['data']['servicesData'] ?? {});
      
      existingServicesData['braiding'] = {
        'services': braidingServices
            .where((s) => s['isSelected'].value == true)
            .map((s) => {
                  'name': s['name'],
                  'price': (s['price'] as TextEditingController).text,
                })
            .toList(),
        'travelPreferences': selectedTravel.toList(),
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
    addServiceInputController.dispose();
    super.onClose();
  }
}
