import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_details_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_detail_view.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/grooming_details_view.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_details_view.dart';
import 'package:catch_ride/view/vendor/shipping/create_profile/shipping_details_view.dart';
import 'package:catch_ride/view/vendor/profile_completed_view.dart';

class FarrierDetailsController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.find<ApiService>();

  final addServiceInputController = TextEditingController();
  final addServicePriceController = TextEditingController();

  // Farrier Services (Default to unselected and empty price)
  final farrierServices = <Map<String, dynamic>>[
    {'name': 'Trimming', 'price': TextEditingController(), 'isSelected': false.obs},
    {'name': 'Front Shoes', 'price': TextEditingController(), 'isSelected': false.obs},
    {'name': 'Hind Shoes', 'price': TextEditingController(), 'isSelected': false.obs},
    {'name': 'Full Set', 'price': TextEditingController(), 'isSelected': false.obs},
    {'name': 'Corrosion Protection...', 'price': TextEditingController(), 'isSelected': false.obs},
    {'name': 'Glue-on Shoes', 'price': TextEditingController(), 'isSelected': false.obs},
    {'name': 'Specialty Shoes (Force...)', 'price': TextEditingController(), 'isSelected': false.obs},
    {'name': 'Barefoot / Natural Incl...', 'price': TextEditingController(), 'isSelected': false.obs},
  ].obs;

  void addService(String name, {bool isAddOn = false}) {
    if (isAddOn) {
      addOns.add({
        'name': name,
        'price': TextEditingController(),
        'isSelected': true.obs, // Custom added services should be selected
      });
    } else {
      farrierServices.add({
        'name': name,
        'price': TextEditingController(),
        'isSelected': true.obs,
      });
    }
  }

  // Add-Ons (Default to unselected and empty price)
  final addOns = <Map<String, dynamic>>[
    {'name': 'Aluminum', 'price': TextEditingController(), 'isSelected': false.obs},
  ].obs;

  // Travel Preferences
  final travelCategories = ['Local Only', 'Regional', 'Nationwide', 'International'];
  final selectedTravel = 'Local Only'.obs;
  
  // Detailed fee config per category
  final travelConfigurations = <String, Map<String, dynamic>>{
    'Local Only': {'type': 'No travel fee', 'price': '', 'disclaimer': ''},
    'Regional': {'type': 'No travel fee', 'price': '', 'disclaimer': ''},
    'Nationwide': {'type': 'No travel fee', 'price': '', 'disclaimer': ''},
    'International': {'type': 'No travel fee', 'price': '', 'disclaimer': ''},
  }.obs;

  // Temp variables for UI
  final tempSelectedFeeType = 'No travel fee'.obs;
  final travelFeePriceController = TextEditingController();
  final travelFeeDisclaimerController = TextEditingController();

  void saveTravelConfig(String category) {
    travelConfigurations[category] = {
      'type': tempSelectedFeeType.value,
      'price': travelFeePriceController.text,
      'disclaimer': travelFeeDisclaimerController.text,
    };
    selectedTravel.value = category;
  }

  // Client Intake
  final clientPolicies = [
    'Accepting new clients',
    'Limited availability',
    'Referral only',
    'Not accepting new clients'
  ];
  final selectedPolicy = 'Accepting new clients'.obs;
  
  final minHorsesPerStop = 6.obs;
  final emergencySupport = true.obs;

  // Insurance Status
  final insuranceOptions = [
    'Carries Insurance',
    'Insurance details upon request',
    'Not currently insured'
  ];
  final selectedInsurance = 'Carries Insurance'.obs;

  // Summary Data (Read-only)
  final location = 'Denver, Colorado, USA'.obs;
  final experience = '4 years'.obs;
  final disciplines = <String>['Hunters', 'Hunter/Jumper', 'Dressage'].obs;
  final horseLevels = <String>['A/AA Circuit', 'Grand Prix', 'Young Horses', 'FEI'].obs;
  final regionsCovered = <String>[
    'Florida (Wellington / Ocala / Gulf coast)',
    'Southwest (Thermal / AZ winter circuits)',
    'Aiken / Tryon / Wills Park / Chatt Hills'
  ].obs;

  // Cancellation Policy
  final cancellationPolicy = RxnString();
  final isCustomCancellation = false.obs;
  final customCancellationController = TextEditingController();

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFarrierData();
  }

  Future<void> fetchFarrierData() async {
    isLoading.value = true;
    try {
      // 1. Fetch tags from system config
      final tagResponse = await apiService.getRequest('/system-config/tag-types/with-values?category=Farrier');
      if (tagResponse.statusCode == 200 && tagResponse.body['success'] == true) {
        final List types = tagResponse.body['data'];
        
        // Populate Services from "Farrier Services" tag
        final serviceType = types.firstWhereOrNull((t) => t['name'] == 'Farrier Services');
        if (serviceType != null) {
          final List values = serviceType['values'];
          farrierServices.assignAll(values.map((v) => {
            'name': v['name'] as String,
            'price': TextEditingController(text: v['defaultPrice']?.toString() ?? ''),
            'isSelected': false.obs,
          }).toList());
        }

        // Populate Add-Ons from "Add-Ons" tag
        final addOnType = types.firstWhereOrNull((t) => t['name'] == 'Add-Ons');
        if (addOnType != null) {
          final List values = addOnType['values'];
          addOns.assignAll(values.map((v) => {
            'name': v['name'] as String,
            'price': TextEditingController(text: v['defaultPrice']?.toString() ?? ''),
            'isSelected': false.obs,
          }).toList());
        }
      }

      // 2. Fetch vendor profile data
      final response = await apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final vendor = response.body['data'];
        final List assignedServices = vendor['assignedServices'] ?? [];
        final farrierService = assignedServices.firstWhereOrNull((s) => s['serviceType'] == 'Farrier');

        if (farrierService != null && farrierService['application'] != null) {
          final applicationData = farrierService['application']['applicationData'] ?? {};
          
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
      debugPrint('Error fetching farrier data: $e');
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
      
      existingServicesData['farrier'] = {
        'services': farrierServices
            .where((s) => s['isSelected'].value == true)
            .map((s) => {
                  'name': s['name'],
                  'price': (s['price'] as TextEditingController).text,
                })
            .toList(),
        'addOns': addOns
            .where((s) => s['isSelected'].value == true)
            .map((s) => {
                  'name': s['name'],
                  'price': (s['price'] as TextEditingController).text,
                })
            .toList(),
        'travelPreferences': travelConfigurations.entries.map((e) => {
          'category': e.key,
          'type': e.value['type'],
          'price': e.value['price'],
          'disclaimer': e.value['disclaimer'],
        }).where((e) => e['type'] != 'No travel fee' || (selectedTravel.value == e['category'])).toList(),
        'clientIntake': {
          'policy': selectedPolicy.value,
          'minHorses': minHorsesPerStop.value,
          'emergencySupport': emergencySupport.value,
        },
        'insuranceStatus': selectedInsurance.value,
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

          if (nextService == 'Grooming') {
            Get.off(() => const GroomingDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Braiding') {
            Get.off(() => const BraidingDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Clipping') {
            Get.off(() => const ClippingDetailView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Bodywork') {
            Get.off(() => const BodyworkDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Shipping') {
            Get.off(() => const ShippingDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else {
            Get.offAll(() => const ProfileCompletedView(subtitle: 'Your farrier services are now live', destinationWidget: GroomBottomNav()));
          }
        } else {
          Get.offAll(() => const ProfileCompletedView(subtitle: 'Your farrier services are now live', destinationWidget: GroomBottomNav()));
        }
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to update farrier profile', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong. Please try again.', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    for (var s in farrierServices) {
      (s['price'] as TextEditingController).dispose();
    }
    for (var s in addOns) {
      (s['price'] as TextEditingController).dispose();
    }
    customCancellationController.dispose();
    super.onClose();
  }
}
