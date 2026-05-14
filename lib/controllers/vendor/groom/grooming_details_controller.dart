import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';
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

  /// Must match labels in [GroomingDetailsView] cancellation dropdown.
  static const List<String> cancellationPolicyOptions = [
    'Flexible (24+ hrs)',
    'Moderate (48+ hrs)',
    'Strict (72+ hrs)',
  ];

  // Grooming Services
  final groomingServicesList = <String>[
    'Grooming & Turnout',
    'Wrapping & Bandaging',
    'Stall Upkeep & Daily Care',
    'Show Prep (Non Braiding)',
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
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty && !groomingServicesList.contains(trimmedName)) {
      groomingServicesList.add(trimmedName);
      selectedGroomingServices.add(trimmedName);
      addServiceInputController.clear();
    }
  }

  // Deprecated Pricing-based services
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
  final handlingOptions = ['Lunging', 'Flat Riding (Exercise Only)', 'Stallion'];
  final selectedHandling = <String>{}.obs;

  void toggleHandling(String item) {
    if (selectedHandling.contains(item)) {
      selectedHandling.remove(item);
    } else {
      selectedHandling.add(item);
    }
  }

  final additionalServices = <Map<String, dynamic>>[

    {
      'name': 'Hunter Braiding Mane',
      'price': TextEditingController(), // Default empty as in image placeholder
      'isSelected': false.obs,
    },
    {
      'name': 'Jumper Braiding',
      'price': TextEditingController(), // Default empty as in image placeholder
      'isSelected': false.obs,
    },
    {
      'name': 'Dressage Braiding',
      'price': TextEditingController(), // Default empty as in image placeholder
      'isSelected': false.obs,
    },
    {
      'name': 'Hunter Mane + Tail',
      'price': TextEditingController(), // Default empty as in image placeholder
      'isSelected': false.obs,
    },
    {
      'name': 'Hunter Tail Only',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Fullbody Clip',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Hunter Clip',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Trace Clip',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Custom Clip',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
  ].obs;

  void addAdditionalService(String name, String price) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty && !additionalServices.any((s) => s['name'] == trimmedName)) {
      additionalServices.add({
        'name': trimmedName,
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
  // Summary Data (Read-only -> Editable)
  final location = 'N/A'.obs;
  final experience = RxnString();
  final experienceOptions = ['0-1', '2-4', '5-9', '10+'];

  final disciplinesSelected = <String>[].obs;
  final disciplineOptions = <String>[].obs;

  final horseLevels = <String>[].obs;
  final horseLevelOptions = <String>[].obs;

  final operatingRegions = <String>[].obs;
  final regionOptions = <String>[].obs;

  void toggleDiscipline(String disc) {
    if (disciplinesSelected.contains(disc)) {
      disciplinesSelected.remove(disc);
    } else {
      disciplinesSelected.add(disc);
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

  // Cancellation Policy
  final cancellationPolicy = RxnString();
  final isCustomCancellation = false.obs;
  final customCancellationController = TextEditingController();

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroomingData();
  }

  Future<void> fetchGroomingData() async {
    isLoading.value = true;
    try {
      // Fetch options from system config
      final tagResponse = await apiService.getRequest(
        '/system-config/tag-types/with-values?category=Grooming',
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
        
        final servicesData = vendor['servicesData'] ?? {};
        final groomingData = servicesData['grooming'];

        if (groomingData != null) {
          final applicationData = groomingData['applicationData'] ?? {};
          
          final city = applicationData['homeBase']?['city'] ?? vendor['city'] ?? '';
          final state = applicationData['homeBase']?['state'] ?? vendor['state'] ?? '';
          location.value = city.isNotEmpty && state.isNotEmpty ? '$city, $state, USA' : 'N/A';
          
          experience.value = applicationData['experience']?.toString();
          disciplinesSelected.assignAll(List<String>.from(applicationData['disciplines'] ?? []));
          horseLevels.assignAll(List<String>.from(applicationData['horseLevels'] ?? []));
          operatingRegions.assignAll(List<String>.from(applicationData['regions'] ?? []));

          if (groomingData['travelPreferences'] != null) {
            selectedTravel.assignAll(List<String>.from(groomingData['travelPreferences']));
          }
          
          if (groomingData['cancellationPolicy'] != null) {
            final cp = groomingData['cancellationPolicy'];
            isCustomCancellation.value = cp['isCustom'] ?? false;
            customCancellationController.text =
                cp['customText']?.toString() ?? '';
            final raw = cp['policy']?.toString().trim() ?? '';
            // API often sends policy: "" — DropdownButton requires null or an exact items[] value
            if (!isCustomCancellation.value &&
                raw.isNotEmpty &&
                cancellationPolicyOptions.contains(raw)) {
              cancellationPolicy.value = raw;
            } else {
              cancellationPolicy.value = null;
            }
          }
        } else {
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
      final vendor = vendorResponse.body['data'];
      final vendorId = vendorResponse.body['data']['_id']?? vendorResponse.body['data']['id'];
      
      // Merge with existing servicesData to prevent clearing other services (Braiding, Clipping, etc.)
      final Map<String, dynamic> existingServicesData = Map<String, dynamic>.from(vendor['servicesData'] ?? {});
      
      // Update applicationData with new selections
      final Map<String, dynamic> updatedApplicationData = Map<String, dynamic>.from(vendorResponse.body['data']['servicesData']?['grooming']?['applicationData'] ?? {});
      updatedApplicationData['experience'] = experience.value;
      updatedApplicationData['disciplines'] = disciplinesSelected.toList();
      updatedApplicationData['horseLevels'] = horseLevels.toList();
      updatedApplicationData['regions'] = operatingRegions.toList();

      // Update ONLY the grooming part of servicesData
      final Map<String, dynamic> existingGroomingData = Map<String, dynamic>.from(existingServicesData['grooming'] ?? {});
      existingServicesData['grooming'] = {
        ...existingGroomingData,
        'applicationData': updatedApplicationData,
        'rates': {
          'daily': dailyRateController.text.replaceAll(',', ''),
          'weekly': {
            'price': weeklyRateController.text.replaceAll(',', ''),
            'days': weeklyRateDays.value,
          },
          'monthly': {
            'price': monthlyRateController.text.replaceAll(',', ''),
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
                  'price': (s['price'] as TextEditingController).text.replaceAll(',', ''),
                })
            .toList(),
        'cancellationPolicy': {
          'policy': cancellationPolicy.value,
          'isCustom': isCustomCancellation.value,
          'customText': customCancellationController.text,
        },
        'travelPreferences': selectedTravel.toList(),
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
