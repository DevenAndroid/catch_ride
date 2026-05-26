import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorInsuranceController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();
  final AuthController authController = Get.find<AuthController>();

  final isDataLoading = false.obs;
  final isSaving = false.obs;

  // Insurance Status options
  final selectedInsurance = RxnString();
  final insuranceOptions = <String>[
    'Carries Insurance',
    'Insurance available upon request',
    'Not currently insured'
  ];

  // Insurance Document (Local File and Remote URL)
  final insuranceFile = Rxn<File>();
  final insuranceDocumentUrl = RxnString();
  final insuranceDocumentName = RxnString();

  // Expiration Date
  final expirationDate = Rxn<DateTime>();
  final insuranceExpiryStr = RxnString();

  // Keep a copy of full vendor data from GET /vendors/me
  final vendorData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadInsuranceData();
  }

  /// Canonical service key matching menu_view.dart
  String _canonicalServiceKey(String raw) {
    var k = raw.toLowerCase().replaceAll(' ', '');
    if (k == 'transportation') k = 'shipping';
    return k;
  }

  /// Get active vendor services
  List<String> getActiveServices() {
    final user = authController.currentUser.value;
    if (user == null) return [];
    if (user.vendorSelectedServiceTypes.isNotEmpty) {
      return user.vendorSelectedServiceTypes;
    }
    return user.vendorServices;
  }

  /// Coalesce different insurance status strings to standard options
  String? _coalesceInsuranceStatus(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    for (final o in insuranceOptions) {
      if (o == s || o.toLowerCase() == s.toLowerCase()) return o;
    }
    final lower = s.toLowerCase();
    if (lower.contains('carries')) return 'Carries Insurance';
    if (lower.contains('upon request') ||
        (lower.contains('available') && lower.contains('request'))) {
      return 'Insurance available upon request';
    }
    if (lower.contains('not') && lower.contains('insured')) {
      return 'Not currently insured';
    }
    return null;
  }

  /// Load and pre-fill existing insurance data from /vendors/me
  Future<void> loadInsuranceData() async {
    isDataLoading.value = true;
    try {
      final response = await apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final vendor = response.body['data'];
        vendorData.value = Map<String, dynamic>.from(vendor);

        final servicesData = vendor['servicesData'] is Map
            ? Map<String, dynamic>.from(vendor['servicesData'] as Map)
            : <String, dynamic>{};

        // Find the first active service with insurance data
        final activeServices = getActiveServices();
        Map<String, dynamic>? insuranceMap;

        for (var service in activeServices) {
          final key = _canonicalServiceKey(service);
          final serviceBlock = servicesData[key];
          if (serviceBlock is Map) {
            final ins = serviceBlock['insurance'];
            if (ins is Map && ins.isNotEmpty) {
              insuranceMap = Map<String, dynamic>.from(ins);
              break;
            }
            final appData = serviceBlock['applicationData'];
            if (appData is Map && appData['insurance'] is Map) {
              insuranceMap = Map<String, dynamic>.from(appData['insurance'] as Map);
              break;
            }
          }
        }

        // Hydrate from parsed insurance data
        if (insuranceMap != null) {
          final rawStatus = insuranceMap['status'] ?? insuranceMap['insuranceStatus'];
          final status = _coalesceInsuranceStatus(rawStatus);
          if (status != null) {
            selectedInsurance.value = status;
          }

          final expiry = insuranceMap['expirationDate'] ?? insuranceMap['expiryDate'] ?? insuranceMap['expiration'] ?? insuranceMap['expiry'];
          if (expiry != null && expiry.toString().isNotEmpty) {
            try {
              final parsedDate = DateTime.parse(expiry.toString());
              expirationDate.value = parsedDate;
              insuranceExpiryStr.value = "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
            } catch (_) {}
          }

          dynamic docRaw = insuranceMap['document'];
          if (docRaw == null || docRaw.toString().trim().isEmpty) {
            final files = insuranceMap['file'];
            if (files is List && files.isNotEmpty) {
              docRaw = files.first;
            }
          }
          final doc = docRaw?.toString();
          if (doc != null && doc.isNotEmpty) {
            insuranceDocumentUrl.value = doc;
            insuranceDocumentName.value = doc.split(RegExp(r'[/\\]')).last;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading vendor insurance: $e');
    } finally {
      isDataLoading.value = false;
    }
  }

  /// Pick insurance document via FilePicker (supports PDF, image)
  Future<void> pickInsuranceDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      insuranceFile.value = File(result.files.single.path!);
      insuranceDocumentName.value = result.files.single.name;
    }
  }

  /// Select insurance expiry date
  Future<void> pickInsuranceExpiry(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: expirationDate.value ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      expirationDate.value = picked;
      insuranceExpiryStr.value = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  /// Upload file using CatchRide upload service
  Future<String?> _uploadFile(File file) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': 'certification',
      });
      final response = await apiService.postRequest('/upload?type=certification', formData);
      if (response.statusCode == 200 && response.body['success'] == true) {
        return response.body['data']['filename'];
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
    }
    return null;
  }

  /// Save changes to the backend
  Future<void> saveInsuranceChanges() async {
    if (selectedInsurance.value == null) {
      Get.snackbar('Missing Selection', 'Please select an insurance status option',
          backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      return;
    }

    if (selectedInsurance.value == 'Carries Insurance') {
      if (insuranceFile.value == null && insuranceDocumentUrl.value == null) {
        Get.snackbar('Missing File', 'Please upload your insurance document',
            backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
        return;
      }
      if (expirationDate.value == null) {
        Get.snackbar('Missing Expiry', 'Please select the insurance expiration date',
            backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
        return;
      }
    }

    isSaving.value = true;
    try {
      // 1. Upload file if a new file is picked
      String? insuranceKey = insuranceDocumentUrl.value;
      if (selectedInsurance.value == 'Carries Insurance' && insuranceFile.value != null) {
        insuranceKey = await _uploadFile(insuranceFile.value!);
        if (insuranceKey == null) {
          Get.snackbar('Upload Failed', 'Failed to upload insurance document. Please try again.',
              backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
          isSaving.value = false;
          return;
        }
      }

      // 2. Fetch current vendors/me to avoid losing data during concurrent updates
      final vendorResponse = await apiService.getRequest('/vendors/me');
      if (vendorResponse.statusCode != 200 || vendorResponse.body['success'] != true) {
        Get.snackbar('Error', 'Failed to save changes. Please try again.',
            backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
        isSaving.value = false;
        return;
      }
      final latestVendor = vendorResponse.body['data'];

      // 3. Prepare updated servicesData by injecting updated insurance block in ALL active services
      final Map<String, dynamic> existingServicesData = latestVendor['servicesData'] is Map
          ? Map<String, dynamic>.from(latestVendor['servicesData'] as Map)
          : <String, dynamic>{};

      final activeServices = getActiveServices();
      final insuranceBlock = {
        'status': selectedInsurance.value,
        'insuranceStatus': selectedInsurance.value,
        'document': selectedInsurance.value == 'Carries Insurance' ? insuranceKey : null,
        'file': selectedInsurance.value == 'Carries Insurance' && insuranceKey != null ? [insuranceKey] : [],
        'expirationDate': selectedInsurance.value == 'Carries Insurance' ? expirationDate.value?.toIso8601String() : null,
        'expiry': selectedInsurance.value == 'Carries Insurance' ? expirationDate.value?.toIso8601String() : null,
      };

      for (var service in activeServices) {
        final key = _canonicalServiceKey(service);
        if (key.isEmpty) continue;

        final serviceBlock = existingServicesData[key] is Map
            ? Map<String, dynamic>.from(existingServicesData[key] as Map)
            : <String, dynamic>{};

        serviceBlock['insurance'] = insuranceBlock;

        // Also update internal applicationData
        if (serviceBlock['applicationData'] is Map) {
          final appData = Map<String, dynamic>.from(serviceBlock['applicationData'] as Map);
          appData['insurance'] = insuranceBlock;
          serviceBlock['applicationData'] = appData;
        }

        // Also update internal profileData
        if (serviceBlock['profileData'] is Map) {
          final profData = Map<String, dynamic>.from(serviceBlock['profileData'] as Map);
          profData['insurance'] = insuranceBlock;
          serviceBlock['profileData'] = profData;
        }

        existingServicesData[key] = serviceBlock;
      }

      final body = {
        'servicesData': existingServicesData,
      };

      final response = await apiService.putRequest('/vendors/me', body);

      if (response.statusCode == 200 && response.body['success'] == true) {
        await authController.updateUserMetadata();
        Get.snackbar('Success', 'Insurance information updated successfully.',
            backgroundColor: AppColors.successPrimary, colorText: AppColors.cardColor);
        Get.back();
      } else {
        final errorMsg = response.body['message'] ?? 'Failed to update insurance information';
        Get.snackbar('Error', errorMsg,
            backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
      }
    } catch (e) {
      debugPrint('Error saving insurance: $e');
      Get.snackbar('Error', 'Something went wrong. Please check your connection and try again.',
          backgroundColor: AppColors.accentRed, colorText: AppColors.cardColor);
    } finally {
      isSaving.value = false;
    }
  }
}
