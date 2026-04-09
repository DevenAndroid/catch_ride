import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../view/vendor/braiding/profile_create/braiding_details_view.dart';
import '../../../view/vendor/clipping/profile_create/clipping_detail_view.dart';
import '../../../view/vendor/bodywork/create_profile/bodywork_details_view.dart';
import '../../../view/vendor/farrier/create_profile/farrier_details_view.dart';
import '../../../view/vendor/shipping/create_profile/shipping_details_view.dart';
import '../../../view/vendor/profile_completed_view.dart';

class GroomingDetailsController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.find<ApiService>();

  // Grooming Services
  final groomingServicesList = <String>[
  ].obs;
  final selectedGroomingServices = <String>{}.obs;
  final addServiceInputController = TextEditingController();
  final addServicePriceInputController = TextEditingController();

  void toggleGroomingService(String service) {
    if (selectedGroomingServices.contains(service)) {
      selectedGroomingServices.remove(service);
    } else {
      selectedGroomingServices.add(service);
    }
  }

  void addGroomingService(String name) {
    if (name.isNotEmpty && !groomingServicesList.contains(name)) {
      groomingServicesList.add(name);
      selectedGroomingServices.add(name);
      addServiceInputController.clear();
    }
  }

  // Deprecated Pricing-based services (keeping for now to avoid breaking other logic if any, but clean up eventually)
  final groomingServices = <Map<String, dynamic>>[].obs;

  void removeGroomingService(int index) {
    groomingServices.removeAt(index);
  }

  // Rate Section
  final dailyRateController = TextEditingController();
  final weeklyRateController = TextEditingController();
  final weeklyRateDays = 5.obs; // 5 or 6
  final monthlyRateController = TextEditingController();
  final monthlyRateDays = 5.obs; // 5 or 6

  // Show & Barn Support
  final supportOptions = [
    'Show Grooming',
    'Monthly Jobs',
    'Fill in Daily Grooming Support',
    'Weekly Jobs',
    'Seasonal Jobs',
    'Travel Jobs',
  ];
  final selectedSupport = <String>{}.obs;

  void toggleSupport(String item) {
    if (selectedSupport.contains(item)) {
      selectedSupport.remove(item);
    } else {
      selectedSupport.add(item);
    }
  }

  // Horse Handling
  final handlingOptions = ['Lunging', 'Flat Riding (exercise only)'];
  final selectedHandling = <String>{}.obs;

  void toggleHandling(String item) {
    if (selectedHandling.contains(item)) {
      selectedHandling.remove(item);
    } else {
      selectedHandling.add(item);
    }
  }

  final additionalServices = <Map<String, dynamic>>[
  ].obs;

  void addAdditionalService(String name, String price) {
    if (name.isNotEmpty && !additionalServices.any((s) => s['name'] == name)) {
      additionalServices.add({
        'name': name,
        'price': TextEditingController(text: price),
        'isSelected': true.obs,
      });
      addServiceInputController.clear();
      addServicePriceInputController.clear();
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

  // Pre-filled / Read-only
  final location = 'N/A'.obs;
  final experience = 'N/A'.obs;
  final disciplinesSelected = <String>[].obs;
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
    fetchGroomingData();
  }

  Future<void> fetchGroomingData() async {
    isLoading.value = true;
    try {
      final response = await apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final vendor = response.body['data'];
        
        // Find Grooming service
        final List assignedServices = vendor['assignedServices'] ?? [];
        final groomingService = assignedServices.firstWhereOrNull((s) => s['serviceType'] == 'Grooming');

        if (groomingService != null && groomingService['application'] != null) {
          final applicationData = groomingService['application']['applicationData'] ?? {};
          
          final city = applicationData['homeBase']?['city'] ?? '';
          final state = applicationData['homeBase']?['state'] ?? '';
          location.value = city.isNotEmpty && state.isNotEmpty ? '$city, $state, USA' : 'N/A';
          
          experience.value = applicationData['experience'] != null ? '${applicationData['experience']} Years' : 'N/A';
          disciplinesSelected.assignAll(List<String>.from(applicationData['disciplines'] ?? []));
          horseLevels.assignAll(List<String>.from(applicationData['horseLevels'] ?? []));
          operatingRegions.assignAll(List<String>.from(applicationData['regions'] ?? []));
        } else {
          // Fallback to vendor level fields if service level not found
          location.value = vendor['city'] != null ? '${vendor['city']}, ${vendor['state']}, USA' : 'N/A';
          experience.value = vendor['experience'] ?? 'N/A';
        }
      }
    } catch (e) {
      debugPrint('Error fetching grooming data: $e');
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
          'grooming': {
            'rates': {
              'daily': dailyRateController.text,
              'weekly': {
                'price': weeklyRateController.text,
                'days': weeklyRateDays.value,
              },
              'monthly': {
                'price': monthlyRateController.text,
                'days': monthlyRateDays.value,
              },
            },
            'services': selectedGroomingServices.toList(),
            'capabilities': {
              'support': selectedSupport.toList(),
              'handling': selectedHandling.toList(),
            },
            'additionalServices': additionalServices
                .where((s) => s['isSelected'].value == true)
                .map((s) => {
                      'name': s['name'],
                      'price': (s['price'] as TextEditingController).text,
                    })
                .toList(),
            'cancellationPolicy': {
              'policy': cancellationPolicy.value,
              'isCustom': isCustomCancellation.value,
              'customText': customCancellationController.text,
            },
            'travelPreferences': selectedTravel.toList(),
            'isProfileCompleted': true,
          }
        },
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

          if (nextService == 'Braiding') {
            Get.off(() => const BraidingDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Clipping') {
            Get.off(() => const ClippingDetailView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Farrier') {
            Get.off(() => const FarrierDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Bodywork') {
            Get.off(() => const BodyworkDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Shipping') {
            Get.off(() => const ShippingDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else {
             Get.offAll(() => const ProfileCompletedView(subtitle: 'Your grooming services are now live', destinationWidget: GroomBottomNav()));
          }
        } else {
          Get.offAll(() => const ProfileCompletedView(subtitle: 'Your grooming services are now live', destinationWidget: GroomBottomNav()));
        }
      } else {
        final errorMsg = response.body['message'] ?? 'Failed to update grooming profile';
        Get.snackbar('Error', errorMsg, backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong. Please try again.', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    dailyRateController.dispose();
    weeklyRateController.dispose();
    monthlyRateController.dispose();
    addServicePriceInputController.dispose();
    customCancellationController.dispose();
    for (var service in groomingServices) {
      (service['dailyPrice'] as TextEditingController).dispose();
      (service['weeklyPrice'] as TextEditingController).dispose();
      (service['monthlyPrice'] as TextEditingController).dispose();
    }
    for (var service in additionalServices) {
      (service['price'] as TextEditingController).dispose();
    }
    super.onClose();
  }
}
