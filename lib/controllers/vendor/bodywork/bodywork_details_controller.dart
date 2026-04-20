import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/controllers/vendor/bodywork/bodywork_application_controller.dart';
import 'package:catch_ride/view/vendor/vendor_application_submit_view.dart';
import 'package:catch_ride/view/vendor/profile_completed_view.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/grooming_details_view.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_details_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_detail_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_details_view.dart';
import 'package:catch_ride/view/vendor/shipping/create_profile/shipping_details_view.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:collection/collection.dart';
import 'package:catch_ride/view/vendor/vendor_application_submit_view.dart';
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';

class BodyworkDetailsController extends GetxController {
  final apiService = Get.find<ApiService>();

  // Data from Application (Read-only for details view)
  final location = ''.obs;
  final experience = ''.obs;
  final disciplines = <String>[].obs;
  final horseLevels = <String>[].obs;
  final regionsCovered = <String>[].obs;

  // Services
  final services = <Map<String, dynamic>>[].obs;
  // Fallback services in case API fails
  final List<String> fallbackServices = [
    'Sports massage',
    'Myofascial release',
    'PEMF',
    'Chiropractic',
    'Acupuncture',
    'Laser therapy',
    'Red Light',
  ];

  final isLoadingServices = false.obs;
  final editingService = Rxn<Map<String, dynamic>>();

  // Certifications
  final certifications = <File>[].obs;
  final certificationUrls = <String>[].obs;
  
  // Insurance
  final selectedInsurance = 'Not currently insured'.obs;
  final insuranceDocument = Rxn<File>();
  final insuranceDocumentUrl = RxnString();
  final insuranceDocumentName = RxnString();
  final expirationDate = Rxn<DateTime>();
  final insuranceOptions = ['Carries Insurance', 'Insurance available upon request', 'Not currently insured'];

  // Travel Preferences
  final selectedTravel = <String, Map<String, dynamic>>{}.obs;
  final travelOptions = ['Local Only', 'Regional', 'Nationwide', 'International'];

  // Cancellation Policy
  final selectedCancellationPolicy = RxnString();
  final isCustomPolicy = false.obs;
  final customCancellationController = TextEditingController();
  final cancellationOptions = ['Flexible (24+ hrs)', 'Moderate (48+ hrs)', 'Strict (72+ hrs)'];

  final isLoading = false.obs;
  final isDataLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    initialLoading();
  }

  Future<void> initialLoading() async {
    isDataLoading.value = true;
    await fetchDynamicServices();
    await fetchBodyworkData();
    isDataLoading.value = false;
  }

  Future<void> fetchDynamicServices() async {
    isLoadingServices.value = true;
    try {
      final Response response = await apiService.getRequest('/system-config/tag-types/with-values?category=Bodywork');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List types = response.body['data'];
        final serviceType = types.firstWhereOrNull((t) => t['name'] == 'Bodywork Services' || t['name'] == 'Services');
        
        if (serviceType != null) {
          final List<String> names = List<String>.from(serviceType['values'].map((v) => v['name']));
          services.assignAll(names.map((name) => {
            'name': name,
            'isSelected': false,
            'rates': {'30': '', '45': '', '60': '', '90': ''},
            'note': '',
            'trainerPresence': null,
            'vetApproval': null,
          }).toList());
        } else {
          _setFallbackServices();
        }
      } else {
        _setFallbackServices();
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
      _setFallbackServices();
    } finally {
      isLoadingServices.value = false;
    }
  }

  void _setFallbackServices() {
    services.assignAll(fallbackServices.map((name) => {
      'name': name,
      'isSelected': false,
      'rates': {'30': '', '45': '', '60': '', '90': ''},
      'note': '',
      'trainerPresence': null,
      'vetApproval': null,
    }).toList());
  }

  Future<void> fetchBodyworkData() async {
    isDataLoading.value = true;
    try {
      final response = await apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final vendor = response.body['data'];
        final List assignedServices = vendor['assignedServices'] ?? [];
        final bodyworkService = assignedServices.firstWhere((s) => s['serviceType'] == 'Bodywork', orElse: () => null);

          if (bodyworkService != null) {
            final applicationData = bodyworkService['application']?['applicationData'] ?? {};
            final profileData = bodyworkService['profile']?['profileData'] ?? {};

            // Application data
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

            // Load/Merge Services & Rates
            final List existingServices = profileData['services'] ?? [];
            if (existingServices.isNotEmpty) {
              for (var existing in existingServices) {
                final index = services.indexWhere((s) => s['name'] == existing['name']);
                if (index != -1) {
                  services[index] = {
                    'name': existing['name'],
                    'isSelected': existing['isSelected'] ?? true,
                    'rates': Map<String, dynamic>.from(existing['rates'] ?? {'30': '', '45': '', '60': '', '90': ''}),
                    'note': existing['note'] ?? '',
                    'trainerPresence': existing['trainerPresence'],
                    'vetApproval': existing['vetApproval'],
                  };
                } else {
                  // If it's a custom service not in the dynamic list, add it
                  services.add({
                    'name': existing['name'],
                    'isSelected': existing['isSelected'] ?? true,
                    'rates': Map<String, dynamic>.from(existing['rates'] ?? {'30': '', '45': '', '60': '', '90': ''}),
                    'note': existing['note'] ?? '',
                    'trainerPresence': existing['trainerPresence'],
                    'vetApproval': existing['vetApproval'],
                  });
                }
              }
              services.refresh();
            }

            // Travel Preferences
            final List travel = profileData['travelPreferences'] ?? [];
            for (var t in travel) {
              if (t is Map) {
                selectedTravel[t['type'] ?? t['name'] ?? ''] = {
                  'feeType': t['feeType'],
                  'price': t['price'],
                  'disclaimer': t['disclaimer'],
                };
              }
            }

            // Insurance
            final Map<String, dynamic> appInsurance = applicationData['insurance'] is Map ? Map<String, dynamic>.from(applicationData['insurance']) : {};
            final Map<String, dynamic> profInsurance = profileData['insurance'] is Map ? Map<String, dynamic>.from(profileData['insurance']) : {};
            
            final insuranceData = profInsurance.isNotEmpty ? profInsurance : appInsurance;
            
            if (insuranceData.isNotEmpty) {
              selectedInsurance.value = insuranceData['status'] ?? 'Not currently insured';
              final expiry = insuranceData['expirationDate'] ?? insuranceData['expiryDate'];
              if (expiry != null) {
                expirationDate.value = DateTime.tryParse(expiry);
              }
              if (insuranceData['document'] != null) {
                insuranceDocumentUrl.value = insuranceData['document'];
                insuranceDocumentName.value = (insuranceData['document'] as String).split('/').last;
              }
            }

            // Certifications
            final List appCerts = applicationData['certifications'] ?? [];
            final List profCerts = profileData['certifications'] ?? [];
            if (profCerts.isNotEmpty) {
              certificationUrls.assignAll(List<String>.from(profCerts));
            } else if (appCerts.isNotEmpty) {
              certificationUrls.assignAll(List<String>.from(appCerts));
            }

            // Policy
            if (profileData['cancellationPolicy'] != null) {
              selectedCancellationPolicy.value = profileData['cancellationPolicy']['policy'];
              isCustomPolicy.value = profileData['cancellationPolicy']['isCustom'] ?? false;
              customCancellationController.text = profileData['cancellationPolicy']['customText'] ?? '';
            }
          }
      }
    } catch (e) {
      debugPrint('Error fetching bodywork data: $e');
    } finally {
      isDataLoading.value = false;
    }
  }

  Future<void> pickCertification() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 85);
    if (file != null) {
      certifications.add(File(file.path));
    }
  }

  Future<void> pickInsuranceDoc() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 85);
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

  Future<String?> _uploadFile(File file) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': 'bodywork_docs',
      });
      final response = await apiService.postRequest('/upload?type=bodywork_docs', formData);
      if (response.statusCode == 200 && response.body['success'] == true) {
        return response.body['data']['filename'];
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
    }
    return null;
  }

  Future<void> submitDetails() async {
    if (!services.any((s) => s['isSelected'] == true)) {
      Get.snackbar('Missing Info', 'Please select at least one service', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      return;
    }

    isLoading.value = true;
    try {
      final vendorResponse = await apiService.getRequest('/vendors/me');
      if (vendorResponse.statusCode != 200 || vendorResponse.body['success'] != true) {
        Get.snackbar('Error', 'Failed to fetch vendor details', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
        return;
      }
      final vendorId = vendorResponse.body['data']['_id'];

      // 1. Upload Certifications
      final List<String> certKeys = [...certificationUrls];
      for (var cert in certifications) {
        final key = await _uploadFile(cert);
        if (key != null) certKeys.add(key);
      }

      // 2. Upload Insurance Doc
      String? insuranceKey = insuranceDocumentUrl.value;
      if (insuranceDocument.value != null) {
        insuranceKey = await _uploadFile(insuranceDocument.value!);
      }

      // 3. Prepare Data
      final bodyworkData = {
        'services': services.where((s) => s['isSelected'] == true).map((s) => {
          'name': s['name'],
          'rates': s['rates'],
          'note': s['note'],
          'trainerPresence': s['trainerPresence'],
          'vetApproval': s['vetApproval'],
        }).toList(),
        'certifications': certKeys,
        'insurance': {
          'status': selectedInsurance.value,
          'document': insuranceKey,
          'expirationDate': expirationDate.value?.toIso8601String(),
        },
        'travelPreferences': selectedTravel.entries.map((e) => {
          'type': e.key,
          'feeType': e.value['feeType'],
          'price': e.value['price'],
          'disclaimer': e.value['disclaimer'],
        }).toList(),
        'cancellationPolicy': {
          'policy': selectedCancellationPolicy.value,
          'isCustom': isCustomPolicy.value,
          'customText': customCancellationController.text,
        },
        'isProfileCompleted': true,
      };

      // Merge with existing servicesData
      final Map<String, dynamic> existingServicesData = Map<String, dynamic>.from(vendorResponse.body['data']['servicesData'] ?? {});
      
      existingServicesData['bodywork'] = bodyworkData;

      final body = {
        'servicesData': existingServicesData,
        'isProfileSetup': true,
        'isProfileCompleted': true,
      };

      final response = await apiService.putRequest('/vendors/$vendorId', body);
      
      if (response.statusCode == 200 && response.body['success'] == true) {
        final authController = Get.find<AuthController>();
        await authController.updateUserMetadata();
        
        Get.snackbar('Success', 'Bodywork details saved successfully.', backgroundColor: AppColors.successPrimary, colorText: AppColors.cardColor);

        // Handle Redirection
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
          } else if (nextService == 'Farrier') {
            Get.off(() => const FarrierDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Shipping') {
            Get.off(() => const ShippingDetailsView(), arguments: {'remainingServices': nextRemaining});
          } else {
             Get.offAll(() => const ProfileCompletedView(subtitle: 'Your bodywork services are now live', destinationWidget: GroomBottomNav()));
          }
        } else {
          Get.offAll(() => const ProfileCompletedView(subtitle: 'Your bodywork services are now live', destinationWidget: GroomBottomNav()));
        }
      } else {
        final errorMsg = response.body['message'] ?? 'Failed to update bodywork details';
        Get.snackbar('Error', errorMsg, backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      }
    } catch (e) {
      debugPrint('Error submitting bodywork details: $e');
      Get.snackbar('Error', 'Something went wrong. Please try again.', backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    customCancellationController.dispose();
    super.onClose();
  }
}
