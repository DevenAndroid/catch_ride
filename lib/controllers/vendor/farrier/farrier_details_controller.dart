import 'dart:developer';
import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
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

  static const List<String> cancellationPolicyOptions = [
    'Flexible (24+ hrs)',
    'Moderate (48+ hrs)',
    'Strict (72+ hrs)',
  ];

  final addServiceInputController = TextEditingController();
  final addServicePriceController = TextEditingController();

  // Farrier Services (Default to unselected and empty price)
  final farrierServices = <Map<String, dynamic>>[
    {
      'name': 'Trimming',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Front Shoes',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Hind Shoes',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Full Set',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Corrective / Therapeutic Work ',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Glue-on Shoes',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Specialty Shoes (bar shoes, pads, wedges, etc.)',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Barefoot / Natural Trim Specialist',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Spaces for custom input services',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
    {
      'name': 'Drill & Tap',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
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
    {
      'name': 'Aluminum',
      'price': TextEditingController(),
      'isSelected': false.obs,
    },
  ].obs;

  // Travel Preferences
  final travelCategories = [
    'Local Only',
    'Regional',
    // 'Nationwide',
    // 'International',
  ];
  final selectedTravel = 'Local Only'.obs;

  // Detailed fee config per category
  final travelConfigurations = <String, Map<String, dynamic>>{
    'Local Only': {'type': 'No travel fee', 'price': '', 'disclaimer': ''},
    'Regional': {'type': 'No travel fee', 'price': '', 'disclaimer': ''},
    // 'Nationwide': {'type': 'No travel fee', 'price': '', 'disclaimer': ''},
    // 'International': {'type': 'No travel fee', 'price': '', 'disclaimer': ''},
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
    'Not accepting new clients',
  ];
  final selectedPolicy = 'Accepting new clients'.obs;

  final minHorsesPerStop = 6.obs;
  final emergencySupport = true.obs;

  // Insurance Status
  final selectedInsurance = 'Not currently insured'.obs;
  final insuranceDocument = Rxn<File>();
  final insuranceDocumentUrl = RxnString();
  final insuranceDocumentName = RxnString();
  final expirationDate = Rxn<DateTime>();
  final insuranceOptions = [
    'Carries Insurance',
    'Insurance available upon request',
    'Not currently insured'
  ];

  // Summary Data (Read-only -> Editable)
  final location = 'N/A'.obs;
  final experience = RxnString();
  final experienceOptions = ['0-1', '2-4', '5-9', '10+'];

  final disciplines = <String>[].obs;
  final disciplineOptions = <String>[].obs;

  final horseLevels = <String>[].obs;
  final horseLevelOptions = <String>[].obs;

  final regionsCovered = <String>[].obs;
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
    if (regionsCovered.contains(region)) {
      regionsCovered.remove(region);
    } else {
      regionsCovered.add(region);
    }
  }

  Future<void> pickInsuranceDoc() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      insuranceDocument.value = File(result.files.single.path!);
      insuranceDocumentName.value = result.files.single.name;
    }
  }

  Future<void> selectExpirationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: expirationDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF001149),
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) expirationDate.value = picked;
  }

  String? _coalesceFarrierInsuranceStatus(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    for (final o in insuranceOptions) {
      if (o == s) return o;
      if (o.toLowerCase() == s.toLowerCase()) return o;
    }
    final lower = s.toLowerCase();
    if (lower.contains('carries')) return 'Carries Insurance';
    if (lower.contains('upon request') ||
        (lower.contains('details') && lower.contains('request')) ||
        (lower.contains('available') && lower.contains('request'))) {
      return 'Insurance available upon request';
    }
    if (lower.contains('not') && lower.contains('insured')) {
      return 'Not currently insured';
    }
    return null;
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
    fetchFarrierData();
  }

  /// Prefill post-form fields from VendorModel-derived `servicesData.farrier` (GET /vendors/me).
  void applyFarrierFromServicesData(Map<String, dynamic>? farrierData) {
    if (farrierData == null || farrierData.isEmpty) return;

    final applicationData =
        Map<String, dynamic>.from(farrierData['applicationData'] ?? {});

    final city = applicationData['homeBase']?['city'] ?? '';
    final state = applicationData['homeBase']?['state'] ?? '';
    final country = applicationData['homeBase']?['country'] ?? 'USA';
    if (city.isNotEmpty && state.isNotEmpty) {
      location.value = '$city, $state, $country';
    }

    if (applicationData['experience'] != null) {
      experience.value = applicationData['experience'].toString();
    }
    disciplines.assignAll(
      List<String>.from(applicationData['disciplines'] ?? []),
    );
    horseLevels.assignAll(
      List<String>.from(applicationData['horseLevels'] ?? []),
    );
    regionsCovered.assignAll(
      List<String>.from(applicationData['regions'] ?? []),
    );

    for (final s in farrierData['services'] ?? []) {
      final name = s['name']?.toString();
      if (name == null || name.isEmpty) continue;
      final price = s['price']?.toString() ?? '';
      final idx = farrierServices.indexWhere((x) => x['name'] == name);
      if (idx >= 0) {
        farrierServices[idx]['isSelected'].value = true;
        (farrierServices[idx]['price'] as TextEditingController).text = price;
      } else {
        farrierServices.add({
          'name': name,
          'price': TextEditingController(text: price),
          'isSelected': true.obs,
        });
      }
    }

    for (final s in farrierData['addOns'] ?? []) {
      final name = s['name']?.toString();
      if (name == null || name.isEmpty) continue;
      final price = s['price']?.toString() ?? '';
      final idx = addOns.indexWhere((x) => x['name'] == name);
      if (idx >= 0) {
        addOns[idx]['isSelected'].value = true;
        (addOns[idx]['price'] as TextEditingController).text = price;
      } else {
        addOns.add({
          'name': name,
          'price': TextEditingController(text: price),
          'isSelected': true.obs,
        });
      }
    }

    for (final row in farrierData['travelPreferences'] ?? []) {
      if (row is! Map) continue;
      final cat = row['category']?.toString();
      if (cat == null || cat.isEmpty) continue;
      travelConfigurations[cat] = {
        'type': row['type']?.toString() ?? 'No travel fee',
        'price': row['price']?.toString() ?? '',
        'disclaimer': row['disclaimer']?.toString() ?? '',
      };
    }

    final ci = Map<String, dynamic>.from(farrierData['clientIntake'] ?? {});
    final policyStr = ci['policy']?.toString();
    if (policyStr != null &&
        policyStr.isNotEmpty &&
        clientPolicies.contains(policyStr)) {
      selectedPolicy.value = policyStr;
    }
    final mh = ci['minHorses'];
    if (mh != null && mh.toString().isNotEmpty) {
      final n = int.tryParse(mh.toString());
      if (n != null) minHorsesPerStop.value = n;
    }
    if (ci['emergencySupport'] != null) {
      emergencySupport.value = ci['emergencySupport'] == true ||
          ci['emergencySupport'] == 'true';
    }

    final insuranceData = farrierData['insurance'];
    if (insuranceData != null && insuranceData is Map) {
      final rawStatus = insuranceData['status'] ?? insuranceData['insuranceStatus'];
      final status = _coalesceFarrierInsuranceStatus(rawStatus);
      if (status != null) {
        selectedInsurance.value = status;
      }
      var doc = insuranceData['document'] ?? insuranceData['file'];
      // If document is an empty string but file is available, use file
      if (doc is String && doc.isEmpty && insuranceData['file'] != null) {
        doc = insuranceData['file'];
      }

      if (doc is String && doc.isNotEmpty) {
        insuranceDocumentUrl.value = doc;
      } else if (doc is List && doc.isNotEmpty) {
        insuranceDocumentUrl.value = doc.first.toString();
      } else {
        insuranceDocumentUrl.value = null;
      }
      
      final fName = insuranceData['fileName'];
      insuranceDocumentName.value = (fName is String) ? fName : null;

      final expStr = insuranceData['expirationDate'] ?? insuranceData['expiry'];
      if (expStr != null && expStr.toString().isNotEmpty) {
        try {
          expirationDate.value = DateTime.parse(expStr.toString());
        } catch (_) {}
      }
    } else {
      // Backward compatibility
      final rawInsuranceStatus = farrierData['insuranceStatus'];
      final ins = _coalesceFarrierInsuranceStatus(rawInsuranceStatus);
      if (ins != null) {
        selectedInsurance.value = ins;
      }
      var doc = farrierData['insuranceFile'] ?? farrierData['media']?['insurance'];
      if (doc is String && doc.isNotEmpty) {
        insuranceDocumentUrl.value = doc;
      } else if (doc is List && doc.isNotEmpty) {
        insuranceDocumentUrl.value = doc.first.toString();
      } else {
        insuranceDocumentUrl.value = null;
      }
      
      final fName = farrierData['insuranceFileName'];
      insuranceDocumentName.value = (fName is String) ? fName : null;

      final expStr = farrierData['insuranceExpiry'] ?? farrierData['insuranceExpiration'];
      if (expStr != null && expStr.toString().isNotEmpty) {
        try {
          expirationDate.value = DateTime.parse(expStr.toString());
        } catch (_) {}
      }
    }

    final cancelData = farrierData['cancellationPolicy'];
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

  Future<void> fetchFarrierData() async {
    isLoading.value = true;
    try {
      // 1. Fetch tags from system config
      final tagResponse = await apiService.getRequest(
        '/system-config/tag-types/with-values?category=Farrier',
      );
      if (tagResponse.statusCode == 200 &&
          tagResponse.body['success'] == true) {
        final List types = tagResponse.body['data'];

        // Populate Services from "Farrier Services" tag
        final serviceType = types.firstWhereOrNull(
          (t) => t['name'] == 'Farrier Services',
        );
        if (serviceType != null) {
          final List values = serviceType['values'];
          farrierServices.assignAll(
            values
                .map(
                  (v) => {
                    'name': v['name'] as String,
                    'price': TextEditingController(
                      text: v['defaultPrice']?.toString() ?? '',
                    ),
                    'isSelected': false.obs,
                  },
                )
                .toList(),
          );
        }

        // Populate Add-Ons from "Add-Ons" tag
        final addOnType = types.firstWhereOrNull((t) => t['name'] == 'Add-Ons');
        if (addOnType != null) {
          final List values = addOnType['values'];
          addOns.assignAll(
            values
                .map(
                  (v) => {
                    'name': v['name'] as String,
                    'price': TextEditingController(
                      text: v['defaultPrice']?.toString() ?? '',
                    ),
                    'isSelected': false.obs,
                  },
                )
                .toList(),
          );
        }

        // Populate Disciplines
        final disciplineType = types.firstWhereOrNull((t) => t['name'] == 'Disciplines');
        if (disciplineType != null) {
          disciplineOptions.value = List<String>.from(disciplineType['values'].map((v) => v['name']));
        }

        // Populate Level of Horses
        final horseLevelType = types.firstWhereOrNull((t) => t['name'] == 'Typical Level of Horses');
        if (horseLevelType != null) {
          horseLevelOptions.value = List<String>.from(horseLevelType['values'].map((v) => v['name']));
        }

        // Populate Regions Covered
        final regionType = types.firstWhereOrNull((t) => t['name'] == 'Regions Covered');
        if (regionType != null) {
          regionOptions.value = List<String>.from(regionType['values'].map((v) => v['name']));
        }
      }

      // 2. Fetch vendor profile data
      final response = await apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final vendor = response.body['data'];
        final servicesData = vendor['servicesData'] ?? {};
        final farrierDataRaw = servicesData['farrier'];
        final farrierData = farrierDataRaw is Map
            ? Map<String, dynamic>.from(farrierDataRaw as Map)
            : null;

        applyFarrierFromServicesData(farrierData);
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
      if (vendorResponse.statusCode != 200 ||
          vendorResponse.body['success'] != true) {
        Get.snackbar(
          'Error',
          'Failed to fetch vendor details',
          backgroundColor: AppColors.accentRed,
          colorText: AppColors.cardColor,
        );
        return;
      }
      
      String? insuranceUrl = insuranceDocumentUrl.value;
      if (insuranceDocument.value != null) {

        final formData = FormData({
          'media': MultipartFile(insuranceDocument.value!, filename: insuranceDocument.value!.path.split('/').last),
          'type': 'farrier_docs',
        });

        debugPrint('🚀 Starting insurance document upload...');
        final uploadResponse = await apiService.postRequest('/upload?type=farrier_docs', formData);
        
        if (uploadResponse.statusCode == 200 && uploadResponse.body['success'] == true) {
          debugPrint('✅ Upload successful: ${uploadResponse.body['data']['filename']}');
          insuranceUrl = uploadResponse.body['data']['filename'];
        } else {
          debugPrint('❌ Upload failed: ${uploadResponse.statusCode} - ${uploadResponse.statusText}');
          debugPrint('📦 Error body: ${uploadResponse.body}');
          Get.snackbar(
            'Upload Error',
            'Failed to upload insurance document. ${uploadResponse.body?['message'] ?? ""}',
            backgroundColor: AppColors.accentRed,
            colorText: AppColors.cardColor,
          );
          isSubmitting.value = false;
          return;
        }
      }

      // Merge with existing servicesData
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(
            vendorResponse.body['data']['servicesData'] ?? {},
          );

      // Update applicationData with new selections
      final Map<String, dynamic> updatedApplicationData = Map<String, dynamic>.from(vendorResponse.body['data']['servicesData']?['farrier']?['applicationData'] ?? {});
      updatedApplicationData['experience'] = experience.value;
      updatedApplicationData['disciplines'] = disciplines.toList();
      updatedApplicationData['horseLevels'] = horseLevels.toList();
      updatedApplicationData['regions'] = regionsCovered.toList();

      existingServicesData['farrier'] = {
        'applicationData': updatedApplicationData,
        'services': farrierServices
            .where((s) => s['isSelected'].value == true)
            .map(
              (s) => {
                'name': s['name'],
                'price': (s['price'] as TextEditingController).text.replaceAll(',', ''),
              },
            )
            .toList(),
        'addOns': addOns
            .where((s) => s['isSelected'].value == true)
            .map(
              (s) => {
                'name': s['name'],
                'price': (s['price'] as TextEditingController).text.replaceAll(',', ''),
              },
            )
            .toList(),
        'travelPreferences': travelConfigurations.entries
            .map(
              (e) => {
                'category': e.key,
                'type': e.value['type'],
                'price': e.value['price']?.toString().replaceAll(',', ''),
                'disclaimer': e.value['disclaimer'],
              },
            )
            .where(
              (e) =>
                  e['type'] != 'No travel fee' ||
                  (selectedTravel.value == e['category']),
            )
            .toList(),
        'clientIntake': {
          'policy': selectedPolicy.value,
          'minHorses': minHorsesPerStop.value,
          'emergencySupport': emergencySupport.value,
        },
        'insurance': {
          'status': selectedInsurance.value,
          'document': insuranceUrl,
          'fileName': insuranceDocumentName.value,
          'expirationDate': expirationDate.value?.toIso8601String(),
        },
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

        final List<String> remaining =
            Get.arguments?['remainingServices'] as List<String>? ?? [];
        if (remaining.isNotEmpty) {
          final nextService = remaining.first;
          final nextRemaining = remaining.skip(1).toList();

          if (nextService == 'Grooming') {
            Get.off(
              () => const GroomingDetailsView(),
              arguments: {'remainingServices': nextRemaining},
            );
          } else if (nextService == 'Braiding') {
            Get.off(
              () => const BraidingDetailsView(),
              arguments: {'remainingServices': nextRemaining},
            );
          } else if (nextService == 'Clipping') {
            Get.off(
              () => const ClippingDetailView(),
              arguments: {'remainingServices': nextRemaining},
            );
          } else if (nextService == 'Bodywork') {
            Get.off(
              () => const BodyworkDetailsView(),
              arguments: {'remainingServices': nextRemaining},
            );
          } else if (nextService == 'Shipping') {
            Get.off(
              () => const ShippingDetailsView(),
              arguments: {'remainingServices': nextRemaining},
            );
          } else {
            Get.offAll(
              () => const ProfileCompletedView(
                subtitle: 'Your farrier services are now live',
                destinationWidget: GroomBottomNav(),
              ),
            );
          }
        } else {
          Get.offAll(
            () => const ProfileCompletedView(
              subtitle: 'Your farrier services are now live',
              destinationWidget: GroomBottomNav(),
            ),
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.body['message'] ?? 'Failed to update farrier profile',
          backgroundColor: AppColors.accentRed,
          colorText: AppColors.cardColor,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        backgroundColor: AppColors.accentRed,
        colorText: AppColors.cardColor,
      );
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
