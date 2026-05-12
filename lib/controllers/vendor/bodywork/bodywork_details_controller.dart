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
  final travelOptions = ['Local Only', 'Regional'];

  // Cancellation Policy — must match [BodyworkDetailsView] dropdown items.
  static const List<String> cancellationPolicyOptions = [
    'Flexible (24+ hrs)',
    'Moderate (48+ hrs)',
    'Strict (72+ hrs)',
  ];

  final selectedCancellationPolicy = RxnString();
  final isCustomPolicy = false.obs;
  final customCancellationController = TextEditingController();

  /// Returns the canonical menu label if [raw] matches a preset (case/trim tolerant).
  static String? canonicalCancellationPreset(String? raw) {
    if (raw == null) return null;
    final t = raw.trim();
    if (t.isEmpty) return null;
    for (final o in cancellationPolicyOptions) {
      if (o == t) return o;
      if (o.toLowerCase() == t.toLowerCase()) return o;
    }
    return null;
  }

  /// Normalizes API shapes (null, String, Map) so the dropdown never sees an orphan value.
  void applyCancellationPolicyFromServer(dynamic cancelData) {
    if (cancelData == null) {
      isCustomPolicy.value = false;
      selectedCancellationPolicy.value = null;
      customCancellationController.clear();
      return;
    }
    if (cancelData is String) {
      final t = cancelData.trim();
      if (t.isEmpty) {
        isCustomPolicy.value = false;
        selectedCancellationPolicy.value = null;
        customCancellationController.clear();
        return;
      }
      final canon = canonicalCancellationPreset(t);
      if (canon != null) {
        isCustomPolicy.value = false;
        selectedCancellationPolicy.value = canon;
        customCancellationController.clear();
      } else {
        isCustomPolicy.value = true;
        selectedCancellationPolicy.value = null;
        customCancellationController.text = t;
      }
      return;
    }
    if (cancelData is Map) {
      final cd = Map<String, dynamic>.from(cancelData);
      final isCustom = cd['isCustom'] == true;
      final policyRaw = cd['policy']?.toString().trim() ?? '';
      final customTextRaw = cd['customText']?.toString();
      final customTrim = customTextRaw?.trim() ?? '';

      if (isCustom) {
        isCustomPolicy.value = true;
        selectedCancellationPolicy.value = null;
        customCancellationController.text =
            customTrim.isNotEmpty ? customTrim : policyRaw;
        return;
      }

      customCancellationController.clear();
      final canon = canonicalCancellationPreset(policyRaw);
      if (canon != null) {
        isCustomPolicy.value = false;
        selectedCancellationPolicy.value = canon;
      } else if (policyRaw.isNotEmpty) {
        isCustomPolicy.value = true;
        selectedCancellationPolicy.value = null;
        customCancellationController.text = policyRaw;
      } else {
        isCustomPolicy.value = false;
        selectedCancellationPolicy.value = null;
      }
    }
  }

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

  /// Aligns VendorModel (`insuranceStatus`) / legacy (`status`) strings with radio [insuranceOptions].
  String? _coalesceBodyworkInsuranceStatus(dynamic raw) {
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
    if (lower.contains('not currently') ||
        (lower.contains('not') && lower.contains('insured'))) {
      return 'Not currently insured';
    }
    return null;
  }

  void _applyInsuranceMap(Map<String, dynamic> insMap) {
    final resolved = _coalesceBodyworkInsuranceStatus(
      insMap['status'] ?? insMap['insuranceStatus'],
    );
    if (resolved != null) {
      selectedInsurance.value = resolved;
    }

    final expiry = insMap['expirationDate'] ??
        insMap['expiryDate'] ??
        insMap['expiration'];
    if (expiry != null) {
      expirationDate.value =
          expiry is DateTime ? expiry : DateTime.tryParse(expiry.toString());
    }

    dynamic docRaw = insMap['document'];
    if (docRaw == null || docRaw.toString().trim().isEmpty) {
      final files = insMap['file'];
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

  /// Hydrate from VendorModel-derived `servicesData.bodywork` (GET /vendors/me).
  void hydrateBodyworkFromServicesData(Map<String, dynamic> bw) {
    final applicationData =
        Map<String, dynamic>.from(bw['applicationData'] ?? {});

    final city = applicationData['homeBase']?['city'] ?? '';
    final state = applicationData['homeBase']?['state'] ?? '';
    if (city.isNotEmpty && state.isNotEmpty) {
      location.value = '$city, $state, USA';
    }

    experience.value = applicationData['experience']?.toString();

    disciplines.assignAll(List<String>.from(applicationData['disciplines'] ?? []));
    horseLevels.assignAll(List<String>.from(applicationData['horseLevels'] ?? []));
    regionsCovered.assignAll(List<String>.from(applicationData['regions'] ?? []));

    final List existingServices = List.from(bw['services'] ?? []);
    if (existingServices.isNotEmpty) {
      for (final existing in existingServices) {
        if (existing is! Map) continue;
        final existingMap = Map<String, dynamic>.from(existing as Map);
        final index = services.indexWhere((s) => s['name'] == existingMap['name']);
        if (index != -1) {
          services[index] = {
            'name': existingMap['name'],
            'isSelected': existingMap['isSelected'] ?? true,
            'rates': Map<String, dynamic>.from(
                existingMap['rates'] ?? {'30': '', '45': '', '60': '', '90': ''}),
            'note': existingMap['note'] ?? '',
            'trainerPresence': existingMap['trainerPresence'],
            'vetApproval': existingMap['vetApproval'],
          };
        } else {
          services.add({
            'name': existingMap['name'],
            'isSelected': existingMap['isSelected'] ?? true,
            'rates': Map<String, dynamic>.from(
                existingMap['rates'] ?? {'30': '', '45': '', '60': '', '90': ''}),
            'note': existingMap['note'] ?? '',
            'trainerPresence': existingMap['trainerPresence'],
            'vetApproval': existingMap['vetApproval'],
          });
        }
      }
      services.refresh();
    }

    selectedTravel.clear();
    for (final t in bw['travelPreferences'] ?? []) {
      if (t is Map) {
        final m = Map<String, dynamic>.from(t);
        final key = (m['type'] ?? m['name'] ?? '').toString();
        if (key.isEmpty) continue;
        selectedTravel[key] = {
          'feeType': m['feeType'],
          'price': m['price'],
          'disclaimer': m['disclaimer'],
        };
      }
    }

    final nestedIns = applicationData['insurance'];
    final bwIns = bw['insurance'];
    final mergedIns = <String, dynamic>{};
    if (nestedIns is Map) {
      mergedIns.addAll(Map<String, dynamic>.from(nestedIns as Map));
    }
    if (bwIns is Map) {
      mergedIns.addAll(Map<String, dynamic>.from(bwIns as Map));
    }
    if (mergedIns.isNotEmpty) {
      _applyInsuranceMap(mergedIns);
    }

    final certs = bw['certifications'];
    if (certs is List && certs.isNotEmpty) {
      certificationUrls.assignAll(List<String>.from(certs.map((e) => e.toString())));
    }

    applyCancellationPolicyFromServer(bw['cancellationPolicy']);
  }

  Future<void> fetchBodyworkData() async {
    isDataLoading.value = true;
    try {
      // Fetch options from system config
      final tagResponse = await apiService.getRequest(
        '/system-config/tag-types/with-values?category=Bodywork',
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
        final bwRaw = vendor['servicesData']?['bodywork'];

        if (bwRaw is Map && (bwRaw as Map).isNotEmpty) {
          hydrateBodyworkFromServicesData(
              Map<String, dynamic>.from(bwRaw as Map));
        } else {
          final List assignedServices = vendor['assignedServices'] ?? [];
          final bodyworkService = assignedServices.firstWhere(
              (s) => s['serviceType'] == 'Bodywork',
              orElse: () => null);

          if (bodyworkService != null) {
            final applicationData =
                bodyworkService['application']?['applicationData'] ?? {};
            final profileData =
                bodyworkService['profile']?['profileData'] ?? {};

            // Application data
            final city = applicationData['homeBase']?['city'] ?? '';
            final state = applicationData['homeBase']?['state'] ?? '';
            if (city.isNotEmpty && state.isNotEmpty) {
              location.value = '$city, $state, USA';
            }

            experience.value = applicationData['experience']?.toString();

            disciplines.assignAll(
                List<String>.from(applicationData['disciplines'] ?? []));
            horseLevels
                .assignAll(List<String>.from(applicationData['horseLevels'] ?? []));
            regionsCovered
                .assignAll(List<String>.from(applicationData['regions'] ?? []));

            final List existingServices = profileData['services'] ?? [];
            if (existingServices.isNotEmpty) {
              for (var existing in existingServices) {
                final index =
                    services.indexWhere((s) => s['name'] == existing['name']);
                if (index != -1) {
                  services[index] = {
                    'name': existing['name'],
                    'isSelected': existing['isSelected'] ?? true,
                    'rates': Map<String, dynamic>.from(existing['rates'] ??
                        {'30': '', '45': '', '60': '', '90': ''}),
                    'note': existing['note'] ?? '',
                    'trainerPresence': existing['trainerPresence'],
                    'vetApproval': existing['vetApproval'],
                  };
                } else {
                  services.add({
                    'name': existing['name'],
                    'isSelected': existing['isSelected'] ?? true,
                    'rates': Map<String, dynamic>.from(existing['rates'] ??
                        {'30': '', '45': '', '60': '', '90': ''}),
                    'note': existing['note'] ?? '',
                    'trainerPresence': existing['trainerPresence'],
                    'vetApproval': existing['vetApproval'],
                  });
                }
              }
              services.refresh();
            }

            final List travel = profileData['travelPreferences'] ?? [];
            selectedTravel.clear();
            for (var t in travel) {
              if (t is Map) {
                selectedTravel[t['type'] ?? t['name'] ?? ''] = {
                  'feeType': t['feeType'],
                  'price': t['price'],
                  'disclaimer': t['disclaimer'],
                };
              }
            }

            final Map<String, dynamic> appInsurance =
                applicationData['insurance'] is Map
                    ? Map<String, dynamic>.from(applicationData['insurance'])
                    : {};
            final Map<String, dynamic> profInsurance =
                profileData['insurance'] is Map
                    ? Map<String, dynamic>.from(profileData['insurance'])
                    : {};

            Map<String, dynamic> insuranceData;
            if (profInsurance.isNotEmpty && appInsurance.isNotEmpty) {
              insuranceData = Map<String, dynamic>.from(appInsurance);
              insuranceData.addAll(profInsurance);
            } else if (profInsurance.isNotEmpty) {
              insuranceData = profInsurance;
            } else {
              insuranceData = appInsurance;
            }

            if (insuranceData.isNotEmpty) {
              _applyInsuranceMap(insuranceData);
            }

            final List appCerts = applicationData['certifications'] ?? [];
            final List profCerts = profileData['certifications'] ?? [];
            if (profCerts.isNotEmpty) {
              certificationUrls.assignAll(List<String>.from(profCerts));
            } else if (appCerts.isNotEmpty) {
              certificationUrls.assignAll(List<String>.from(appCerts));
            }

            applyCancellationPolicyFromServer(profileData['cancellationPolicy']);
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
      final vendorId = vendorResponse.body['data']['_id']?? vendorResponse.body['data']['id'];

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
          'rates': (s['rates'] as Map).map((key, value) => MapEntry(key, value.toString().replaceAll(',', ''))),
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
          'price': e.value['price']?.toString().replaceAll(',', ''),
          'disclaimer': e.value['disclaimer'],
        }).toList(),
        'cancellationPolicy': {
          'policy': selectedCancellationPolicy.value,
          'isCustom': isCustomPolicy.value,
          'customText': customCancellationController.text,
        },
        'isProfileCompleted': true,
      };

      // Update applicationData with new selections
      final Map<String, dynamic> updatedApplicationData = Map<String, dynamic>.from(vendorResponse.body['data']['servicesData']?['bodywork']?['applicationData'] ?? {});
      updatedApplicationData['experience'] = experience.value;
      updatedApplicationData['disciplines'] = disciplines.toList();
      updatedApplicationData['horseLevels'] = horseLevels.toList();
      updatedApplicationData['regions'] = regionsCovered.toList();

      // Merge with existing servicesData
      final Map<String, dynamic> existingServicesData = Map<String, dynamic>.from(vendorResponse.body['data']['servicesData'] ?? {});
      
      existingServicesData['bodywork'] = {
        ...bodyworkData,
        'applicationData': updatedApplicationData,
      };

      final body = {
        'servicesData': existingServicesData,
        'isProfileSetup': true,
        'isProfileCompleted': true,
      };

      final response = await apiService.putRequest('/vendors/me', body);
      
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
