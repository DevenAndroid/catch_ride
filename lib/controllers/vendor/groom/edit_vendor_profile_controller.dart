import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/utils/vendor_service_sync.dart';
import 'package:catch_ride/utils/vendor_service_payload.dart';
import 'package:catch_ride/utils/vendor_travel_preference_payload.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/system_config_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

String _editProfileBodyworkNameKey(dynamic name) =>
    (name?.toString() ?? '').toLowerCase().trim();

/// Matches [assignedServiceMatchesTab] for a bare `serviceType` string from [assignedServices].
bool _editProfileIsBodyworkServiceType(dynamic serviceType) =>
    assignedServiceMatchesTab(<String, dynamic>{
      'serviceType': serviceType,
    }, 'Bodywork');

class EditVendorProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxList assignedServices = [].obs;
  final RxInt selectedServiceIndex = 0.obs; // 0 for Details, 1+ for services

  // Basic Details Section
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final businessNameController = TextEditingController();
  final aboutController = TextEditingController();
  final notesForTrainerController = TextEditingController();
  final RxString profilePhotoUrl = ''.obs;
  final RxString coverImageUrl = ''.obs;
  final Rxn<File> newProfileImage = Rxn<File>();
  final Rxn<File> newCoverImage = Rxn<File>();

  // Payment Methods
  final RxList<String> paymentOptions = <String>[
    'Venmo',
    'Zelle',
    'Cash',
    'Credit Card',
    'ACH/Bank Transfer',
    'Other',
  ].obs;
  final RxList<String> selectedPayments = <String>[].obs;
  final otherPaymentController = TextEditingController();

  // Experience Highlights
  final RxList<TextEditingController> highlightControllers =
      <TextEditingController>[].obs;

  // Grooming Tab - Home Base
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController(text: 'USA');

  // Location Details
  final selectedCountryCode = 'US'.obs;
  final countries = [
    {'name': 'USA', 'code': 'US'},
    {'name': 'Canada', 'code': 'CA'},
  ];
  final states = <Map<String, dynamic>>[].obs;
  final cities = <Map<String, dynamic>>[].obs;
  final isLoadingStates = false.obs;
  final isLoadingCities = false.obs;
  final selectedStateNode = Rxn<Map<String, dynamic>>();
  final selectedCityNode = Rxn<Map<String, dynamic>>();

  // Grooming Tab - Experience & Choices
  final RxnString experience = RxnString();
  final List<String> experienceOptions = ['0-1', '2-4', '3-5', '6-10', '10+'];

  final RxList<String> disciplineOptions = <String>[
    'Eventing',
    'Hunter/Jumper',
    'Dressage',
    'Other',
  ].obs;
  final RxList<String> selectedDisciplines = <String>[].obs;
  final otherDisciplineController = TextEditingController();

  final RxList<String> horseLevelOptions = <String>[
    'A/AA Circuit',
    'FEI',
    'Grand Prix',
    'Young horses',
  ].obs;
  final RxList<String> selectedHorseLevels = <String>[].obs;

  final RxList<String> regionOptions = <String>[].obs;
  final RxList<String> selectedRegions = <String>[].obs;

  // Social Media
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();

  // Additional Grooming Sections
  final RxList<String> supportOptions = <String>[
    'Show Grooming',
    'Monthly Jobs',
    'Fill in Daily Grooming Support',
    'Weekly Jobs',
    'Seasonal Jobs',
    'Travel Jobs',
  ].obs;
  final RxList<String> selectedSupport = <String>[].obs;

  final RxList<String> handlingOptions = <String>[
    'Lunging',
    'Flat Riding (Exercise Only)',
  ].obs;
  final RxList<String> selectedHandling = <String>[].obs;

  final RxList<String> additionalSkillsOptions = <String>[
    'Braiding',
    'Clipping',
  ].obs;
  final RxList<String> selectedAdditionalSkills = <String>[].obs;

  final RxList<String> travelOptions = <String>[
    'Local Only',
    'Regional',
    'Nationwide',
    'International',
  ].obs;
  final RxList<String> selectedTravel = <String>[].obs;

  /// Same zones as [ClippingDetailsController.travelOptions] — fee structure per zone.
  static const List<String> clippingTravelZoneOptions = ['Local Only', 'Regional'];
  final clippingTravelFees = <String, Map<String, dynamic>>{}.obs;
  final clippingTravelFeePriceController = TextEditingController();
  final clippingTravelFeeNotesController = TextEditingController();
  final clippingSelectedTravelFeeType = 'No travel fee'.obs;

  void updateClippingTravelFee(
    String option,
    String type,
    String price,
    String notes,
  ) {
    if (type == 'No travel fee') {
      clippingTravelFees.remove(option);
    } else {
      clippingTravelFees[option] = {
        'type': type,
        'price': price,
        'notes': notes,
      };
    }
    clippingTravelFees.refresh();
  }

  void removeClippingTravelPreference(String option) => clippingTravelFees.remove(option);

  static const List<String> farrierClientPolicyOptions = [
    'Accepting new clients',
    'Limited availability',
    'Referral only',
    'Not accepting new clients',
  ];

  String? _coalesceFarrierInsuranceStatus(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    const options = [
      'Carries Insurance',
      'Insurance available upon request',
      'Not currently insured',
    ];
    for (final o in options) {
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
    if (lower == 'i have professional liability insurance') {
      return 'Carries Insurance';
    }
    if (lower == 'i do not have professional liability insurance') {
      return 'Not currently insured';
    }
    if (lower == 'not applicable') return 'Insurance available upon request';
    return null;
  }

  String? _farrierPolicyLabelFromSources(
    Map<String, dynamic> merged,
    Map<String, dynamic> profileData,
    Map<String, dynamic> appData,
  ) {
    final cis = profileData['clientIntakePlusScheduling'] ??
        merged['clientIntakePlusScheduling'] ??
        appData['clientIntakePlusScheduling'];
    if (cis is Map) {
      final m = Map<String, dynamic>.from(cis);
      if (m['notAcceptingNewClients'] == true) {
        return 'Not accepting new clients';
      }
      if (m['referralOnly'] == true) return 'Referral only';
      if (m['limitedAvailability'] == true) return 'Limited availability';
      if (m['acceptingNewClients'] == true) return 'Accepting new clients';
    }
    final ci = profileData['clientIntake'] ??
        appData['clientIntake'] ??
        merged['clientIntake'];
    if (ci is Map) {
      final raw = ci['policy']?.toString().toLowerCase() ?? '';
      if (raw.contains('not accepting')) return 'Not accepting new clients';
      if (raw.contains('referral')) return 'Referral only';
      if (raw.contains('limited')) return 'Limited availability';
      if (raw.contains('accepting')) return 'Accepting new clients';
      final exact = ci['policy']?.toString().trim();
      if (exact != null &&
          exact.isNotEmpty &&
          farrierClientPolicyOptions.contains(exact)) {
        return exact;
      }
    }
    return null;
  }

  void _applySavedFarrierServiceRows(
    List<dynamic> saved,
    RxList target,
  ) {
    if (saved.isEmpty) return;
    if (target.isEmpty) {
      target.assignAll(
        saved.map((s) {
          if (s is! Map) {
            return {
              'name': s.toString(),
              'price': TextEditingController(text: '0'),
              'isSelected': RxBool(true),
            };
          }
          final m = Map<String, dynamic>.from(s);
          final name = (m['name'] ?? m['label'])?.toString().trim() ?? '';
          final price =
              (m['price'] ?? m['ratePerHour'] ?? m['rate'] ?? '').toString();
          final sel = m['isSelected'];
          final isSelected = sel is bool
              ? sel
              : (sel == null ? price.isNotEmpty : sel == true);
          return {
            'name': name,
            'price': TextEditingController(text: price),
            'isSelected': RxBool(isSelected),
          };
        }),
      );
      return;
    }
    for (final s in saved) {
      if (s is! Map) continue;
      final m = Map<String, dynamic>.from(s);
      final name = (m['name'] ?? m['label'])?.toString().trim() ?? '';
      if (name.isEmpty) continue;
      final price =
          (m['price'] ?? m['ratePerHour'] ?? m['rate'] ?? '').toString();
      final sel = m['isSelected'];
      final isSelected = sel is bool
          ? sel
          : (sel == null ? price.isNotEmpty : sel == true);
      final idx = target.indexWhere((x) => x['name'] == name);
      if (idx >= 0) {
        target[idx]['isSelected'].value = isSelected;
        (target[idx]['price'] as TextEditingController).text = price;
      } else {
        target.add({
          'name': name,
          'price': TextEditingController(text: price),
          'isSelected': RxBool(isSelected),
        });
      }
    }
  }

  void _hydrateFarrierTravelFromList(List<dynamic> travelPrefRaw) {
    final Map<String, Map<String, dynamic>> travelMap = {};
    selectedTravel.clear();
    for (var item in travelPrefRaw) {
      if (item is! Map) continue;
      final itemMap = Map<String, dynamic>.from(item);
      final categoryName =
          VendorTravelPreferencePayload.labelFromRow(itemMap);
      if (categoryName.isEmpty) continue;
      final ui = VendorTravelPreferencePayload.toUiEditingState(itemMap);
      final feeType = ui['feeType'] ?? 'No travel fee';
      if (feeType == 'No travel fee' &&
          (ui['price'] ?? '').isEmpty &&
          (ui['disclaimer'] ?? '').isEmpty) {
        continue;
      }
      travelMap[categoryName] = {
        'type': categoryName,
        'feeType': feeType,
        'price': ui['price'] ?? '',
        'disclaimer': ui['disclaimer'] ?? '',
      };
      if (!selectedTravel.contains(categoryName)) {
        selectedTravel.add(categoryName);
      }
    }
    selectedTravelData.assignAll(travelMap);
  }

  void _hydrateFarrierInsuranceFromSources(
    Map<String, dynamic> merged,
    Map<String, dynamic> profileData,
    Map<String, dynamic> appData,
  ) {
    final insData = profileData['insurance'] ??
        appData['insurance'] ??
        merged['insurance'];
    if (insData is Map) {
      final rawStatus = insData['status'] ?? insData['insuranceStatus'];
      final status = _coalesceFarrierInsuranceStatus(rawStatus);
      if (status != null) farrierInsuranceStatus.value = status;

      var doc = insData['document'] ?? insData['file'];
      if (doc is String && doc.isEmpty && insData['file'] is List) {
        doc = insData['file'];
      }
      if (doc is String && doc.isNotEmpty) {
        farrierExistingInsuranceUrl.value = doc;
      } else if (doc is List && doc.isNotEmpty) {
        farrierExistingInsuranceUrl.value = doc.first.toString();
      } else {
        farrierExistingInsuranceUrl.value = null;
      }

      final fName = insData['fileName'];
      farrierInsuranceFileName.value =
          (fName is String && fName.isNotEmpty) ? fName : null;

      final expStr = insData['expirationDate'] ?? insData['expiry'];
      if (expStr != null && expStr.toString().isNotEmpty) {
        try {
          farrierInsuranceExpiry.value = DateTime.parse(expStr.toString());
        } catch (_) {}
      }
      return;
    }

    final rawInsuranceStatus =
        profileData['insuranceStatus'] ?? appData['insuranceStatus'];
    final status = _coalesceFarrierInsuranceStatus(rawInsuranceStatus);
    if (status != null) farrierInsuranceStatus.value = status;

    var doc = appData['insuranceFile'] ?? profileData['insuranceFile'];
    if (doc is String && doc.isNotEmpty) {
      farrierExistingInsuranceUrl.value = doc;
    } else if (doc is List && doc.isNotEmpty) {
      farrierExistingInsuranceUrl.value = doc.first.toString();
    } else {
      farrierExistingInsuranceUrl.value = null;
    }

    final fName =
        appData['insuranceFileName'] ?? profileData['insuranceFileName'];
    farrierInsuranceFileName.value =
        (fName is String && fName.isNotEmpty) ? fName : null;

    final expStr =
        appData['insuranceExpiry'] ?? profileData['insuranceExpiry'];
    if (expStr != null && expStr.toString().isNotEmpty) {
      try {
        farrierInsuranceExpiry.value = DateTime.parse(expStr.toString());
      } catch (_) {}
    }
  }

  void _hydrateFarrierFields({
    required Map<String, dynamic> merged,
    required Map<String, dynamic> profileDataMap,
    required Map<String, dynamic> appDataMap,
  }) {
    final profileData = merged['profileData'] is Map
        ? Map<String, dynamic>.from(merged['profileData'] as Map)
        : profileDataMap;

    _applySavedFarrierServiceRows(
      profileData['services'] is List
          ? List<dynamic>.from(profileData['services'] as List)
          : [],
      farrierServices,
    );
    _applySavedFarrierServiceRows(
      profileData['addOns'] is List
          ? List<dynamic>.from(profileData['addOns'] as List)
          : [],
      farrierAddOns,
    );

    selectedCertifications.assignAll(
      List<String>.from(
        appDataMap['relevantCertifications'] ??
            profileData['relevantCertifications'] ??
            appDataMap['certifications'] ??
            profileData['certifications'] ??
            [],
      ),
    );
    otherCertificationController.text =
        (appDataMap['otherCertification'] ?? profileData['otherCertification'] ?? '')
            .toString()
            .replaceFirst('Other:', '')
            .trim();

    selectedFarrierScope.assignAll(
      List<String>.from(
        appDataMap['scopeOfWork'] ??
            profileData['scopeOfWork'] ??
            merged['scopeOfWork'] ??
            [],
      ),
    );
    otherFarrierScopeController.text =
        (appDataMap['otherScopeOfWork'] ??
                appDataMap['otherScope'] ??
                profileData['otherScope'] ??
                '')
            .toString()
            .replaceFirst('Other:', '')
            .trim();

    final travelRaw = profileData['travelPreferences'] ??
        merged['travelPreferences'] ??
        [];
    if (travelRaw is List) _hydrateFarrierTravelFromList(travelRaw);

    farrierNewClientPolicy.value = _farrierPolicyLabelFromSources(
      merged,
      profileData,
      appDataMap,
    );

    final cis = profileData['clientIntakePlusScheduling'] ??
        merged['clientIntakePlusScheduling'];
    final ci = profileData['clientIntake'] ?? appDataMap['clientIntake'];
    final minRaw = cis is Map
        ? (cis['minHorsesPerStop'] ?? cis['minHorses'])
        : (ci is Map ? ci['minHorses'] : null);
    farrierMinHorses.value = int.tryParse(minRaw?.toString() ?? '') ?? 1;

    if (cis is Map && cis['emergencySupport'] != null) {
      farrierEmergencySupport.value = cis['emergencySupport'] == true;
    } else if (ci is Map && ci['emergencySupport'] != null) {
      farrierEmergencySupport.value = ci['emergencySupport'] == true;
    }

    _hydrateFarrierInsuranceFromSources(merged, profileData, appDataMap);
  }

  Future<void> _fetchFarrierTagsAndHydrate() async {
    try {
      final response = await _apiService.getRequest(
        '/system-config/tag-types/with-values?category=Farrier',
      );
      if (response.statusCode != 200 || response.body['success'] != true) {
        return;
      }
      final List types = response.body['data'];

      final serviceType = types.firstWhereOrNull(
        (t) => t['name'] == 'Farrier Services',
      );
      if (serviceType != null) {
        farrierServices.assignAll(
          List<Map<String, dynamic>>.from(
            (serviceType['values'] as List).map(
              (v) => {
                'name': v['name'] as String,
                'price': TextEditingController(
                  text: v['defaultPrice']?.toString() ?? '',
                ),
                'isSelected': false.obs,
              },
            ),
          ),
        );
      }

      final addOnType = types.firstWhereOrNull((t) => t['name'] == 'Add-Ons');
      if (addOnType != null) {
        farrierAddOns.assignAll(
          List<Map<String, dynamic>>.from(
            (addOnType['values'] as List).map(
              (v) => {
                'name': v['name'] as String,
                'price': TextEditingController(
                  text: v['defaultPrice']?.toString() ?? '',
                ),
                'isSelected': false.obs,
              },
            ),
          ),
        );
      }

      final scopeType = types.firstWhereOrNull(
        (t) => t['name'] == 'Scope of Work' || t['name'] == 'Scope Of Work',
      );
      if (scopeType != null) {
        final values = List<String>.from(
          scopeType['values'].map((v) => v['name']),
        );
        if (!values.contains('Other')) values.add('Other');
        farrierScopeOptions.assignAll(values);
      }

      for (final t in types) {
        if (t['name'] == 'Disciplines') {
          final values = List<String>.from(t['values'].map((v) => v['name']));
          for (final v in values) {
            if (!disciplineOptions.contains(v)) disciplineOptions.add(v);
          }
        } else if (t['name'] == 'Typical Level of Horses') {
          final values = List<String>.from(t['values'].map((v) => v['name']));
          for (final v in values) {
            if (!horseLevelOptions.contains(v)) horseLevelOptions.add(v);
          }
        }
      }

      if (vendorRootData.isNotEmpty) {
        final merged = mergedVendorServiceDisplayData(
          Map<String, dynamic>.from(vendorRootData),
          'Farrier',
        );
        final appData = merged['applicationData'] is Map
            ? Map<String, dynamic>.from(merged['applicationData'] as Map)
            : <String, dynamic>{};
        final pd = merged['profileData'] is Map
            ? Map<String, dynamic>.from(merged['profileData'] as Map)
            : <String, dynamic>{};
        _hydrateFarrierFields(
          merged: merged,
          profileDataMap: pd,
          appDataMap: appData,
        );
      }
    } catch (e) {
      debugPrint('Error fetching farrier tags: $e');
    }
  }

  // Braiding Tab Specifics
  final RxList braidingServices = [].obs;
  final braidingServiceInputController = TextEditingController();

  // Cancellation
  final RxnString cancellationPolicy = RxnString();
  final RxBool isCustomCancellation = false.obs;
  final customCancellationController = TextEditingController();

  static const List<String> cancellationPresetOptions = [
    'Flexible (24+ hrs)',
    'Moderate (48+ hrs)',
    'Strict (72+ hrs)',
  ];

  /// Preset label for cancellation row; avoids invalid Dropdown/trigger state.
  String? get cancellationPresetForDropdown {
    if (isCustomCancellation.value) return null;
    final v = cancellationPolicy.value?.trim();
    if (v == null || v.isEmpty) return null;
    return cancellationPresetMatching(v);
  }

  /// Returns canonical preset string if [text] matches a dropdown option (trim + case-insensitive).
  String? cancellationPresetMatching(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    for (final p in cancellationPresetOptions) {
      if (p == t || p.toLowerCase() == t.toLowerCase()) return p;
    }
    return null;
  }

  /// Readable policy/custom text stored in API (map or legacy string).
  String _effectiveCancellationText(dynamic cp) {
    if (cp == null) return '';
    if (cp is Map) {
      final p = cp['policy']?.toString().trim() ?? '';
      final c = cp['customText']?.toString().trim() ?? '';
      final isCustom = cp['isCustom'] == true;
      if (isCustom) {
        return c.isNotEmpty ? c : p;
      }
      return p.isNotEmpty ? p : c;
    }
    return cp.toString().trim();
  }

  /// Prefill dropdown for presets; use custom textarea only when value is not a preset.
  /// Ignores misleading `isCustom` when the stored text equals a preset.
  void hydrateCancellationPolicyFrom(dynamic cp) {
    final raw = _effectiveCancellationText(cp);
    if (raw.isEmpty) {
      isCustomCancellation.value = false;
      cancellationPolicy.value = null;
      customCancellationController.clear();
      return;
    }
    final preset = cancellationPresetMatching(raw);
    if (preset != null) {
      isCustomCancellation.value = false;
      cancellationPolicy.value = preset;
      customCancellationController.clear();
      return;
    }
    isCustomCancellation.value = true;
    cancellationPolicy.value = null;
    customCancellationController.text = raw;
  }

  // Photos
  final RxList<String> existingPhotos = <String>[].obs;
  final RxList<File> newPhotos = <File>[].obs;

  // Service-specific photo lists to prevent overwriting
  final Map<String, RxList<String>> serviceExistingPhotos = {
    'Grooming': <String>[].obs,
    'Braiding': <String>[].obs,
    'Clipping': <String>[].obs,
    'Farrier': <String>[].obs,
    'Bodywork': <String>[].obs,
  };
  final Map<String, RxList<File>> serviceNewPhotos = {
    'Grooming': <File>[].obs,
    'Braiding': <File>[].obs,
    'Clipping': <File>[].obs,
    'Farrier': <File>[].obs,
    'Bodywork': <File>[].obs,
  };

  // Separate lists for Braiding and Clipping to prevent overwriting
  final RxList clippingServices = [].obs;
  final clippingServiceInputController = TextEditingController();

  // Farrier Tab Specifics
  final RxList farrierServices = [].obs;
  final RxList farrierAddOns = [].obs;
  final RxList<String> certificationOptions = <String>[
    'AFA Certified Journeyman Farrier (CJF)',
    'AFA Certified Farrier (CF)',
    'AFA Certified Tradesman Farrier (CTF)',
    'BWFA Masters',
    'DipWCF (Worshipful Company ...)',
    'Other',
  ].obs;
  final RxList<String> selectedCertifications = <String>[].obs;
  final otherCertificationController = TextEditingController();

  final RxList<String> farrierScopeOptions = <String>[
    'Routine trimming/shoeing',
    'Glue-on / specialty shoes',
    'Barefoot / Natural Balance',
    'Corrective/Therapeutic shoeing',
    'Draft horses',
    'Donkeys/Mules',
    'Upper-level performance horses',
    'Other',
  ].obs;
  final RxList<String> selectedFarrierScope = <String>[].obs;
  final otherFarrierScopeController = TextEditingController();

  // Farrier Travel & Fees
  final RxList<Map<String, dynamic>> farrierTravelFees =
      <Map<String, dynamic>>[].obs;

  // Farrier Client Intake
  final RxnString farrierNewClientPolicy = RxnString();
  final RxInt farrierMinHorses = 1.obs;
  final RxBool farrierEmergencySupport = false.obs;
  final RxnString farrierInsuranceStatus = RxnString();
  final RxnString farrierExistingInsuranceUrl = RxnString();
  final RxnString farrierInsuranceFileName = RxnString();
  final Rxn<File> farrierInsuranceFile = Rxn<File>();
  final Rxn<DateTime> farrierInsuranceExpiry = Rxn<DateTime>();

  // Bodywork Tab Specifics
  final RxList bodyworkServices = [].obs;
  final RxList<String> bodyworkProfessionalStandards = <String>[
    'I provide supportive bodywork and do not replace veterinary care',
    'I refer cases requiring diagnosis or medical treatment to a licensed veterinarian',
    'I understand certain services or situations may require prior veterinary approval',
    'I operate within the scope of my certifications and local regulations.',
  ].obs;
  final RxList<String> selectedBodyworkStandards = <String>[].obs;
  final RxList<File> bodyworkCertFiles = <File>[].obs;
  final RxList<String> bodyworkExistingCertUrls = <String>[].obs;
  final RxList<String> bodyworkModalityOptions = <String>[].obs;
  final otherModalityController = TextEditingController();
  final selectedTravelData = <String, Map<String, dynamic>>{}.obs;
  final RxString tempSelectedFeeType = 'No travel fee'.obs;
  final travelFeePriceController = TextEditingController();
  final travelFeeDisclaimerController = TextEditingController();

  void saveFarrierTravelConfig(String category) {
    selectedTravelData[category] = {
      'type': tempSelectedFeeType.value,
      'price': travelFeePriceController.text,
      'disclaimer': travelFeeDisclaimerController.text,
    };

    // Sync to farrierTravelFees for payload
    final index = farrierTravelFees.indexWhere(
      (t) => t['category'] == category,
    );
    final newData = {
      'category': category,
      'type': tempSelectedFeeType.value,
      'price': travelFeePriceController.text,
      'disclaimer': travelFeeDisclaimerController.text,
    };
    if (index != -1) {
      farrierTravelFees[index] = newData;
    } else {
      farrierTravelFees.add(newData);
    }
  }

  // Shipping Tab Specifics
  final dotNumberController = TextEditingController();
  final RxnString shippingOperationType = RxnString();
  final RxList<String> shippingTravelScope = <String>[].obs;
  final RxList<String> shippingRigTypes = <String>[].obs;
  final RxList<String> shippingServicesOffered = <String>[].obs;
  final RxBool shippingHasCDL = false.obs;
  final Rxn<File> shippingCDLFile = Rxn<File>();
  final RxInt shippingRigCapacity = 1.obs;
  final shippingNotesController = TextEditingController();
  final RxList<String> shippingRigPhotos = <String>[].obs;
  final RxList<File> newShippingRigPhotos = <File>[].obs;
  final RxnString shippingExistingCDLUrl = RxnString();
  final RxnString shippingExistingInsuranceUrl = RxnString();
  final RxnString shippingInsuranceFileName = RxnString();
  final RxnString shippingCdlFileName = RxnString();
  final Rxn<File> shippingInsuranceFile = Rxn<File>();
  final insuranceExpiryController = TextEditingController();

  // Shipping Dynamic Options
  final RxList<String> shippingOperationOptions = <String>[].obs;
  final RxList<String> shippingTravelScopeOptions = <String>[].obs;
  final RxList<String> shippingRigTypeOptions = <String>[].obs;
  final RxList<String> shippingServicesOptions = <String>[].obs;
  final RxList<String> shippingStallOptions = <String>[].obs;
  final RxList<String> shippingStallTypes = <String>[].obs;

  // Combined Services Cache
  final RxMap rawServicesData = {}.obs;
  final RxMap draftServicesData = {}.obs;
  final RxMap originalServicesData = {}.obs;
  final RxMap vendorRootData = {}.obs;

  // Static cache to persist data across controller recreations
  static Map? _cachedVendorRootData;
  static List<String>? _cachedDisciplineOptions;
  static List<String>? _cachedHorseLevelOptions;
  static List<String>? _cachedRegionOptions;
  static List<String>? _cachedShippingOperationOptions;
  static List<String>? _cachedShippingTravelScopeOptions;
  static List<String>? _cachedShippingRigTypeOptions;
  static List<String>? _cachedShippingStallOptions;
  static List<String>? _cachedShippingServicesOptions;
  static List? _cachedAssignedServices;
  static Map<String, dynamic>? _cachedRawServicesData;
  static Map<String, dynamic>? _cachedOriginalServicesData;
  static Map<String, dynamic>? _cachedDraftServicesData;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();

    // Restore from cache if available
    if (_cachedVendorRootData != null)
      vendorRootData.assignAll(_cachedVendorRootData!);
    if (_cachedDisciplineOptions != null)
      disciplineOptions.assignAll(_cachedDisciplineOptions!);
    if (_cachedHorseLevelOptions != null)
      horseLevelOptions.assignAll(_cachedHorseLevelOptions!);
    if (_cachedRegionOptions != null)
      regionOptions.assignAll(_cachedRegionOptions!);
    if (_cachedShippingOperationOptions != null)
      shippingOperationOptions.assignAll(_cachedShippingOperationOptions!);
    if (_cachedShippingTravelScopeOptions != null)
      shippingTravelScopeOptions.assignAll(_cachedShippingTravelScopeOptions!);
    if (_cachedShippingRigTypeOptions != null)
      shippingRigTypeOptions.assignAll(_cachedShippingRigTypeOptions!);
    if (_cachedShippingStallOptions != null)
      shippingStallOptions.assignAll(_cachedShippingStallOptions!);
    if (_cachedShippingServicesOptions != null)
      shippingServicesOptions.assignAll(_cachedShippingServicesOptions!);
    if (_cachedAssignedServices != null)
      assignedServices.assignAll(_cachedAssignedServices!);
    if (_cachedRawServicesData != null)
      rawServicesData.assignAll(_cachedRawServicesData!);
    if (_cachedOriginalServicesData != null)
      originalServicesData.assignAll(_cachedOriginalServicesData!);
    if (_cachedDraftServicesData != null)
      draftServicesData.assignAll(_cachedDraftServicesData!);

    // Populate UI fields immediately from cache
    _populateAllFieldsFromCache();

    fetchProfileData();
    fetchDynamicTags();
    fetchStates();
  }

  String _resolvedProfileImage(Map<dynamic, dynamic> data) {
    final fromVendor = vendorProfileImageFromRoot(data);
    if (fromVendor.isNotEmpty) return fromVendor;
    return _authController.currentUser.value?.displayAvatar ?? '';
  }

  String _resolvedBannerImage(Map<dynamic, dynamic> data) {
    final fromVendor = vendorBannerImageFromRoot(data);
    if (fromVendor.isNotEmpty) return fromVendor;
    return _authController.currentUser.value?.coverImage ?? '';
  }

  void _populateAllFieldsFromCache() {
    if (vendorRootData.isEmpty) return;

    final data = vendorRootData;
    fullNameController.text =
        '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
    // API/cache may decode numeric fields as int; controllers need String.
    phoneController.text = data['phone']?.toString() ?? '';
    businessNameController.text = data['businessName']?.toString() ?? '';
    aboutController.text = data['bio']?.toString() ?? '';
    notesForTrainerController.text = data['notesForTrainer']?.toString() ?? '';
    profilePhotoUrl.value = _resolvedProfileImage(data);
    coverImageUrl.value = _resolvedBannerImage(data);
    otherPaymentController.text = data['otherPaymentDetails']?.toString() ?? '';
    selectedPayments.assignAll(List<String>.from(data['paymentMethods'] ?? []));

    final List<String> loadedHighlights = List<String>.from(
      data['highlights'] ?? [],
    );
    if (loadedHighlights.isEmpty) {
      highlightControllers.assignAll([TextEditingController()]);
    } else {
      highlightControllers.assignAll(
        loadedHighlights.map((h) => TextEditingController(text: h)).toList(),
      );
    }

    _initializeAllServicesFields();
    populateServiceData();
  }

  Future<void> fetchStates() async {
    isLoadingStates.value = true;
    try {
      final countryCode = selectedCountryCode.value;
      final response = await _apiService.getRequest(
        '/locations/states?countryCode=$countryCode',
      );
      if (response.statusCode == 200 && response.body['success'] == true) {
        states.assignAll(
          List<Map<String, dynamic>>.from(response.body['data']),
        );
        _syncLocationNodes();
      }
    } catch (e) {
      debugPrint('Error fetching states: $e');
    } finally {
      isLoadingStates.value = false;
    }
  }

  Future<void> fetchCities(String stateCode) async {
    isLoadingCities.value = true;
    cities.clear();
    try {
      final countryCode = selectedCountryCode.value;
      final response = await _apiService.getRequest(
        '/locations/states/$stateCode/cities?countryCode=$countryCode',
      );
      if (response.statusCode == 200 && response.body['success'] == true) {
        cities.assignAll(
          List<Map<String, dynamic>>.from(response.body['data']),
        );

        if (cityController.text.isNotEmpty) {
          final node = cities.firstWhereOrNull(
            (c) => c['name'] == cityController.text,
          );
          if (node != null) {
            selectedCityNode.value = node;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching cities: $e');
    } finally {
      isLoadingCities.value = false;
    }
  }

  void onCountrySelected(Map<String, dynamic> country) {
    if (selectedCountryCode.value != country['code']) {
      selectedCountryCode.value = country['code'] ?? 'US';
      final name = country['name']?.toString() ?? 'USA';
      countryController.text = name.toUpperCase() == 'USA' ? 'USA' : name;

      // Reset state and city when country changes
      stateController.text = '';
      selectedStateNode.value = null;
      cityController.text = '';
      selectedCityNode.value = null;
      states.clear();
      cities.clear();

      fetchStates();
    }
  }

  void onStateSelected(Map<String, dynamic> stateNode) {
    selectedStateNode.value = stateNode;
    stateController.text = stateNode['name'] ?? '';
    cityController.text = '';
    selectedCityNode.value = null;
    fetchCities(stateNode['isoCode']);
  }

  void onCitySelected(Map<String, dynamic> cityNode) {
    selectedCityNode.value = cityNode;
    cityController.text = cityNode['name'] ?? '';
  }

  void _syncLocationNodes() {
    if (states.isNotEmpty && stateController.text.isNotEmpty) {
      final sNode = states.firstWhereOrNull(
        (s) => s['name'] == stateController.text,
      );
      if (sNode != null) {
        selectedStateNode.value = sNode;
        // If cities are already loaded, try to find the city node
        if (cities.isNotEmpty && cityController.text.isNotEmpty) {
          final cNode = cities.firstWhereOrNull(
            (c) => c['name'] == cityController.text,
          );
          if (cNode != null) {
            selectedCityNode.value = cNode;
          }
        } else if (cityController.text.isNotEmpty) {
          // Fetch cities if they aren't loaded yet
          fetchCities(sNode['isoCode']);
        }
      }
    }
  }

  Future<void> fetchProfileData({bool forceLoading = false}) async {
    if (vendorRootData.isEmpty || forceLoading) {
      isLoading.value = true;
    }
    try {
      final response = await _apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final raw = response.body['data'];
        if (raw is! Map) {
          isLoading.value = false;
          return;
        }
        final root = Map<String, dynamic>.from(raw);
        // Match groom view profile: build tabs from VendorModel.assignedServices OR legacy
        // vendor.serviceType + servicesData when assignedServices is empty.
        final normalizedAssigned = normalizeAssignedServices(root);
        root['assignedServices'] = normalizedAssigned;

        _cachedVendorRootData = root;
        vendorRootData.assignAll(root);

        // Basic Details
        fullNameController.text =
            '${root['firstName'] ?? ''} ${root['lastName'] ?? ''}'.trim();
        phoneController.text = root['phone']?.toString() ?? '';
        businessNameController.text = root['businessName']?.toString() ?? '';
        aboutController.text = root['bio']?.toString() ?? '';
        notesForTrainerController.text = root['notesForTrainer']?.toString() ?? '';
        profilePhotoUrl.value = _resolvedProfileImage(root);
        coverImageUrl.value = _resolvedBannerImage(root);
        otherPaymentController.text = root['otherPaymentDetails']?.toString() ?? '';


        selectedPayments.assignAll(
          List<String>.from(root['paymentMethods'] ?? []),
        );

        final List<String> loadedHighlights = List<String>.from(
          root['highlights'] ?? [],
        );
        if (loadedHighlights.isEmpty) {
          highlightControllers.assignAll([TextEditingController()]);
        } else {
          highlightControllers.assignAll(
            loadedHighlights
                .map((h) => TextEditingController(text: h))
                .toList(),
          );
        }

        // Always replace so nested profile/application from API refresh (same _id, new data).
        _cachedAssignedServices = normalizedAssigned;
        assignedServices.assignAll(normalizedAssigned);

        // Cache raw services data to preserve unmanaged fields (like rates)
        final Map<String, dynamic> sData = Map<String, dynamic>.from(
          root['servicesData'] is Map ? root['servicesData'] : {},
        );
        _cachedRawServicesData = sData;
        _cachedOriginalServicesData = jsonDecode(jsonEncode(sData));
        _cachedDraftServicesData = jsonDecode(jsonEncode(sData));

        rawServicesData.assignAll(sData);
        originalServicesData.assignAll(_cachedOriginalServicesData!);
        draftServicesData.assignAll(_cachedDraftServicesData!);

        _applyMergedProfileDataToRxServiceMaps(root, normalizedAssigned);

        // Populate ALL service data into our reactive fields to prevent overwriting with blanks
        _initializeAllServicesFields();

        final systemConfig = Get.find<SystemConfigController>();
        if (systemConfig.regions.isEmpty) await systemConfig.fetchRegions();

        populateServiceData();
      }
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Aligns `draft` / `raw` / `original` [servicesData] blocks with [mergedVendorServiceDisplayData]
  /// (VendorModel embed + assigned profile + `servicesData`) so Edit Profile matches groom profile + Services & Rates after GET `/vendors/me`.
  void _applyMergedProfileDataToRxServiceMaps(
    Map<String, dynamic> root,
    List<Map<String, dynamic>> normalizedAssigned,
  ) {
    for (final row in normalizedAssigned) {
      final t = row['serviceType']?.toString() ?? '';
      if (t.isEmpty) continue;
      final merged = mergedVendorServiceDisplayData(root, t);
      final pd = merged['profileData'];
      if (pd is! Map) continue;
      final profileData = Map<String, dynamic>.from(pd);
      if (profileData.isEmpty) continue;
      final key = vendorPreformSubdocKey(t);
      void upsert(RxMap target) {
        final existing = target[key];
        final Map<String, dynamic> block = existing is Map
            ? Map<String, dynamic>.from(existing as Map)
            : <String, dynamic>{};
        block['profileData'] = profileData;
        target[key] = block;
      }

      upsert(draftServicesData);
      upsert(rawServicesData);
      upsert(originalServicesData);
    }
    _cachedDraftServicesData = jsonDecode(
      jsonEncode(Map<String, dynamic>.from(draftServicesData)),
    );
    _cachedOriginalServicesData = jsonDecode(
      jsonEncode(Map<String, dynamic>.from(originalServicesData)),
    );
    _cachedRawServicesData = Map<String, dynamic>.from(rawServicesData);
  }

  void _initializeAllServicesFields() {
    for (var service in assignedServices) {
      final type = service['serviceType'];
      final typeStr = type is String ? type : type.toString();
      final merged = mergedVendorServiceDisplayData(
        Map<String, dynamic>.from(vendorRootData),
        typeStr,
      );
      final profileData = merged['profileData'] is Map
          ? Map<String, dynamic>.from(merged['profileData'] as Map)
          : <String, dynamic>{};
      final application = service['application'] ?? {};
      final appData = application['applicationData'] ?? application ?? {};

      if (type == 'Grooming') {
        final caps =
            draftServicesData['grooming']?['capabilities'] ??
            profileData['capabilities'] ??
            {};
        selectedSupport.assignAll(List<String>.from(caps['support'] ?? []));
        selectedHandling.assignAll(List<String>.from(caps['handling'] ?? []));
        selectedAdditionalSkills.assignAll(
          List<String>.from(
            draftServicesData['grooming']?['additionalSkills'] ??
                profileData['additionalSkills'] ??
                [],
          ),
        );
      } else if (type == 'Braiding') {
        final List bServices = profileData['services'] ?? [];
        braidingServices.assignAll(
          bServices.map((s) {
            if (s is Map) {
              return {
                'name': s['name'] ?? '',
                'price': TextEditingController(
                  text: s['price']?.toString() ?? '',
                ),
                'isSelected': RxBool(
                  s['isSelected'] == null || s['isSelected'] == true,
                ),
              };
            }
            return {
              'name': s.toString(),
              'price': TextEditingController(text: '0'),
              'isSelected': RxBool(true),
            };
          }).toList(),
        );
      } else if (type == 'Clipping') {
        final List bServices = profileData['services'] ?? [];
        clippingServices.assignAll(
          bServices.map((s) {
            if (s is Map) {
              return {
                'name': s['name'] ?? '',
                'price': TextEditingController(
                  text: s['price']?.toString() ?? '',
                ),
                'isSelected': RxBool(
                  s['isSelected'] == null || s['isSelected'] == true,
                ),
              };
            }
            return {
              'name': s.toString(),
              'price': TextEditingController(text: '0'),
              'isSelected': RxBool(true),
            };
          }).toList(),
        );
        final List travelPrefs = profileData['travelPreferences'] ?? [];
        clippingTravelFees.clear();
        for (var pref in travelPrefs) {
          if (pref is! Map) continue;
          final m = Map<String, dynamic>.from(pref);
          final region = VendorTravelPreferencePayload.labelFromRow(m);
          if (region.isEmpty) continue;
          clippingTravelFees[region] =
              VendorTravelPreferencePayload.clippingFeeStructureFromRow(m);
        }
      } else if (type == 'Farrier') {
        _hydrateFarrierFields(
          merged: merged,
          profileDataMap: profileData,
          appDataMap: appData is Map
              ? Map<String, dynamic>.from(appData as Map)
              : <String, dynamic>{},
        );
      } else if (_editProfileIsBodyworkServiceType(type)) {
        _mergeBodyworkModalities();
        otherModalityController.text =
            appData['otherModality'] ?? profileData['otherModality'] ?? '';
        final certs = List<String>.from(
          profileData['certifications'] ?? appData['certifications'] ?? [],
        );
        bodyworkExistingCertUrls.assignAll(certs);

        final List travelFees = profileData['travelPreferences'] ?? [];
        final Map<String, Map<String, dynamic>> travelMap = {};
        for (var item in travelFees) {
          if (item is Map) {
            final m = Map<String, dynamic>.from(item);
            final label = VendorTravelPreferencePayload.labelFromRow(m);
            if (label.isEmpty) continue;
            final ui = VendorTravelPreferencePayload.toUiEditingState(m);
            travelMap[label] = {
              'type': label,
              'feeType': ui['feeType'],
              'price': ui['price'],
              'disclaimer': ui['disclaimer'],
            };
          }
        }
        selectedTravelData.assignAll(travelMap);

        final List<String> standards = List<String>.from(
          profileData['professionalStandards'] ?? [],
        );
        selectedBodyworkStandards.assignAll(standards);
      } else if (type == 'Shipping') {
        dotNumberController.text =
            (profileData['usdotNumber'] ??
                    appData['usdotNumber'] ??
                    appData['businessInfo']?['dotNumber'] ??
                    '')
                .toString();
        shippingOperationType.value =
            profileData['operationType'] ?? appData['operationType'];
        if (shippingOperationType.value == 'Independent Small Operation') {
          shippingOperationType.value = 'Independent / Small Operation';
        }
        shippingTravelScope.assignAll(
          List<String>.from(
            profileData['travelScope'] ?? appData['travelScope'] ?? [],
          ),
        );
        shippingRigTypes.assignAll(
          List<String>.from(
            profileData['rigTypes'] ?? appData['rigTypes'] ?? [],
          ),
        );
        shippingStallTypes.assignAll(
          List<String>.from(
            profileData['stallTypes'] ??
                profileData['stallType'] ??
                appData['stallTypes'] ??
                appData['stallType'] ??
                [],
          ),
        );
        shippingServicesOffered.assignAll(
          List<String>.from(profileData['servicesOffered'] ?? [])
              .map(
                (s) => s == 'Long-Distance Transport'
                    ? 'Long distance transport'
                    : s,
              )
              .toList(),
        );
        shippingHasCDL.value =
            profileData['hasCDL'] ?? appData['hasCDL'] ?? false;
        shippingRigCapacity.value =
            appData['rigCapacity'] ?? profileData['rigCapacity'] ?? 1;
        final addNotesFirst =
            profileData['additionalNotes']?.toString().trim() ?? '';
        shippingNotesController.text = addNotesFirst.isNotEmpty
            ? addNotesFirst
            : (profileData['notes']?.toString() ?? '');
        //  shippingRigPhotos.assignAll(List<String>.from(profileData['media']?['rigPhotos'] ?? appData['media']?['rigPhotos'] ?? []));
        shippingExistingCDLUrl.value =
            profileData['cdlFile'] ??
            appData['cdlDoc'] ??
            appData['media']?['cdlPhoto'] ??
            appData['media']?['licensePhoto'] ??
            profileData['media']?['cdlPhoto'] ??
            profileData['media']?['licensePhoto'];
        shippingCdlFileName.value =
            profileData['cdlFileName'] ??
            appData['cdlDocName'] ??
            appData['media']?['cdlDocName'] ??
            'CDL Document';

        shippingExistingInsuranceUrl.value =
            profileData['insuranceFile'] ??
            appData['insuranceFile'] ??
            appData['media']?['insurance'] ??
            appData['media']?['dotCopy'];
        shippingInsuranceFileName.value =
            profileData['insuranceFileName'] ??
            appData['insuranceFileName'] ??
            appData['media']?['insuranceFileName'] ??
            'Insurance Document';
        insuranceExpiryController.text =
            profileData['insuranceExpiry'] ?? appData['insuranceExpiry'] ?? '';
      }

      // Photos for each service
      if (serviceExistingPhotos.containsKey(type)) {
        final typeStr = type.toString();
        final typeKey = typeStr.toLowerCase();
        final draftB = draftServicesData[typeKey] is Map
            ? Map<String, dynamic>.from(draftServicesData[typeKey] as Map)
            : null;
        final urls = mergeServicePortfolioMediaUrls(
          serviceType: typeStr,
          vendorRoot: Map<String, dynamic>.from(vendorRootData),
          profileData: profileData is Map
              ? Map<String, dynamic>.from(profileData)
              : <String, dynamic>{},
          appData: appData is Map
              ? Map<String, dynamic>.from(appData)
              : <String, dynamic>{},
          draftBlock: draftB,
        );
        serviceExistingPhotos[type]!.assignAll(urls);
      }
    }
  }

  void populateServiceData() {
    final services = assignedServices;

    // Find the active service based on selected index or default to Grooming/first
    Map<String, dynamic>? activeService;
    if (selectedServiceIndex.value > 0 &&
        selectedServiceIndex.value <= services.length) {
      activeService = services[selectedServiceIndex.value - 1];
    } else {
      activeService =
          services.firstWhereOrNull((s) => s['serviceType'] == 'Grooming') ??
          (services.isNotEmpty ? services.first : null);
    }

    if (activeService != null) {
      final String typeStr = activeService['serviceType']?.toString() ?? '';
      final typeKey = typeStr.toLowerCase();
      final draft = draftServicesData[typeKey] ?? {};

      // Use the unified merge logic for robust fallback (VendorModel subdoc -> Profile -> servicesData)
      final merged = mergedVendorServiceDisplayData(
        Map<String, dynamic>.from(vendorRootData),
        typeStr,
      );

      final Map<String, dynamic> profileDataMap = {
        ...Map<String, dynamic>.from(merged['profileData'] ?? {}),
        ...Map<String, dynamic>.from(draft['profileData'] ?? {}),
      };

      final Map<String, dynamic> appDataMap = {
        ...Map<String, dynamic>.from(merged['applicationData'] ?? {}),
        ...Map<String, dynamic>.from(draft['applicationData'] ?? {}),
      };


      // Home Base Fallbacks (application → profile → vendor root / homeBaseLocation from GET /vendors/me)
      Map<String, dynamic>? mapOrNull(dynamic v) =>
          v is Map ? Map<String, dynamic>.from(v as Map) : null;
      final appHb = mapOrNull(appDataMap['homeBase']);
      final profHb = mapOrNull(profileDataMap['homeBase']);
      final rootHb = mapOrNull(vendorRootData['homeBaseLocation']);

      String? city = appHb?['city']?.toString() ??
          profHb?['city']?.toString() ??
          appDataMap['city']?.toString();
      String? state = appHb?['state']?.toString() ??
          profHb?['state']?.toString() ??
          appDataMap['state']?.toString();
      String? country = appHb?['country']?.toString() ??
          profHb?['country']?.toString() ??
          appDataMap['country']?.toString();

      if (city == null || city.trim().isEmpty) city = vendorRootData['city']?.toString();
      if (state == null || state.trim().isEmpty) state = vendorRootData['state']?.toString();
      if (country == null || country.trim().isEmpty) country = vendorRootData['country']?.toString();

      if (rootHb != null) {
        if (city == null || city.trim().isEmpty) city = rootHb['city']?.toString();
        if (state == null || state.trim().isEmpty) state = rootHb['state']?.toString();
        if (country == null || country.trim().isEmpty) country = rootHb['country']?.toString();
      }


      cityController.text = city ?? '';
      stateController.text = state ?? '';
      String co = country ?? 'USA';
      countryController.text = co.toUpperCase() == 'USA' ? 'USA' : co;

      if (countryController.text == 'Canada' ||
          countryController.text == 'CA') {
        selectedCountryCode.value = 'CA';
        countryController.text = 'Canada';
      } else {
        selectedCountryCode.value = 'US';
        countryController.text = 'USA';
      }

      // Experience Fallback
      dynamic exp =
          appDataMap['experience'] ??
          appDataMap['yearsExperience'] ??
          vendorRootData['yearsExperience'] ??
          vendorRootData['experience'];
      experience.value = exp?.toString();

      selectedDisciplines.assignAll(
        List<String>.from(
          appDataMap['disciplines'] ?? vendorRootData['disciplines'] ?? [],
        ),
      );
      otherDisciplineController.text = appDataMap['otherDiscipline'] ?? '';
      selectedHorseLevels.assignAll(List<String>.from(appDataMap['horseLevels'] ?? vendorRootData['horseLevels'] ?? []));
      
      final List rawRegions = appDataMap['regions'] ?? appDataMap['regionsCovered'] ?? vendorRootData['regions'] ?? vendorRootData['regionsCovered'] ?? [];
      final systemConfig = Get.find<SystemConfigController>();
      final List<String> regionNames = rawRegions.map((r) {
        final rStr = r.toString();
        final regionObj = systemConfig.regions.firstWhereOrNull((reg) => reg['_id'].toString() == rStr);
        if (regionObj != null) {
          return (regionObj['region'] ?? regionObj['label'] ?? regionObj['name'] ?? rStr).toString();
        }
        return rStr;
      }).toList();
      selectedRegions.assignAll(regionNames);

      // Migration: Load service-specific highlights
      final List<String> loadedHighlights = List<String>.from(
        appDataMap['experienceHighlights'] ??
            profileDataMap['experienceHighlights'] ??
            vendorRootData['highlights'] ??
            [],
      );
      if (loadedHighlights.isEmpty) {
        highlightControllers.assignAll([TextEditingController()]);
      } else {
        highlightControllers.assignAll(
          loadedHighlights.map((h) => TextEditingController(text: h)).toList(),
        );
      }

      final activeTypeStr = activeService['serviceType']?.toString() ?? '';
      final vendorRootMap = Map<String, dynamic>.from(vendorRootData);
      final draftServicesMap = Map<String, dynamic>.from(
        draftServicesData[activeTypeStr.toLowerCase()] ?? {},
      );

      instagramController.text = resolveServiceInstagram(
        serviceType: activeTypeStr,
        vendorRoot: vendorRootMap,
        profileData: profileDataMap,
        appData: appDataMap,
        draftBlock: draftServicesMap.isNotEmpty ? draftServicesMap : null,
      );
      facebookController.text = resolveServiceFacebook(
        serviceType: activeTypeStr,
        vendorRoot: vendorRootMap,
        profileData: profileDataMap,
        appData: appDataMap,
        draftBlock: draftServicesMap.isNotEmpty ? draftServicesMap : null,
      );

      _syncLocationNodes();
      // Capabilities based on service type
      if (activeService['serviceType'] == 'Grooming') {
        final caps =
            draft['capabilities'] ?? profileDataMap['capabilities'] ?? {};
        selectedSupport.assignAll(List<String>.from(caps['support'] ?? []));
        selectedHandling.assignAll(List<String>.from(caps['handling'] ?? []));
        selectedAdditionalSkills.assignAll(
          List<String>.from(
            draft['additionalSkills'] ??
                profileDataMap['additionalSkills'] ??
                [],
          ),
        );
      } else if (activeService['serviceType'] == 'Braiding') {
        final List bServices = profileDataMap['services'] ?? [];
        braidingServices.assignAll(
          bServices.map((s) {
            if (s is Map) {
              return {
                'name': s['name'] ?? '',
                'price': TextEditingController(
                  text: s['price']?.toString() ?? '',
                ),
                'isSelected': RxBool(
                  s['isSelected'] == null || s['isSelected'] == true,
                ),
              };
            }
            return {
              'name': s.toString(),
              'price': TextEditingController(text: '0'),
              'isSelected': RxBool(true),
            };
          }).toList(),
        );
      } else if (activeService['serviceType'] == 'Clipping') {
        final List bServices = profileDataMap['services'] ?? [];
        clippingServices.assignAll(
          bServices.map((s) {
            if (s is Map) {
              return {
                'name': s['name'] ?? '',
                'price': TextEditingController(
                  text: s['price']?.toString() ?? '',
                ),
                'isSelected': RxBool(
                  s['isSelected'] == null || s['isSelected'] == true,
                ),
              };
            }
            return {
              'name': s.toString(),
              'price': TextEditingController(text: '0'),
              'isSelected': RxBool(true),
            };
          }).toList(),
        );
      } else if (activeService['serviceType'] == 'Farrier') {
        _hydrateFarrierFields(
          merged: merged,
          profileDataMap: profileDataMap,
          appDataMap: appDataMap,
        );
      } else if (assignedServiceMatchesTab(activeService, 'Bodywork')) {
        _mergeBodyworkModalities();

        otherModalityController.text =
            appDataMap['otherModality'] ??
            profileDataMap['otherModality'] ??
            '';

        final List<String> standards = List<String>.from(
          profileDataMap['professionalStandards'] ?? [],
        );
        if (standards.isNotEmpty) {
          selectedBodyworkStandards.assignAll(standards);
        } else if (appDataMap['standards'] != null) {
          final Map stdMap = appDataMap['standards'] ?? {};
          if (stdMap['provideSupportiveBodywork'] == true)
            selectedBodyworkStandards.add(bodyworkProfessionalStandards[0]);
          if (stdMap['refertoVet'] == true)
            selectedBodyworkStandards.add(bodyworkProfessionalStandards[1]);
          if (stdMap['vetApprovalRequired'] == true)
            selectedBodyworkStandards.add(bodyworkProfessionalStandards[2]);
          if (stdMap['operateWithinScope'] == true)
            selectedBodyworkStandards.add(bodyworkProfessionalStandards[3]);
        }

        final certs = List<String>.from(
          profileDataMap['certifications'] ??
              appDataMap['certifications'] ??
              [],
        );
        bodyworkExistingCertUrls.assignAll(certs);
      } else if (activeService['serviceType'] == 'Shipping') {
        dotNumberController.text =
            (profileDataMap['usdotNumber'] ??
                    appDataMap['usdotNumber'] ??
                    appDataMap['businessInfo']?['dotNumber'] ??
                    '')
                .toString();
        shippingOperationType.value =
            profileDataMap['operationType'] ?? appDataMap['operationType'];
        if (shippingOperationType.value == 'Independent Small Operation') {
          shippingOperationType.value = 'Independent / Small Operation';
        }
        shippingTravelScope.assignAll(
          List<String>.from(
            appDataMap['travelScope'] ?? profileDataMap['travelScope'] ?? [],
          ),
        );
        shippingRigTypes.assignAll(
          List<String>.from(
            appDataMap['rigTypes'] ?? profileDataMap['rigTypes'] ?? [],
          ),
        );
        shippingStallTypes.assignAll(
          List<String>.from(
            appDataMap['stallTypes'] ??
                appDataMap['stallType'] ??
                profileDataMap['stallTypes'] ??
                profileDataMap['stallType'] ??
                [],
          ),
        );
        shippingServicesOffered.assignAll(
          List<String>.from(profileDataMap['servicesOffered'] ?? [])
              .map(
                (s) => s == 'Long-Distance Transport'
                    ? 'Long distance transport'
                    : s,
              )
              .toList(),
        );
        shippingHasCDL.value =
            profileDataMap['hasCDL'] ?? appDataMap['hasCDL'] ?? false;
        shippingRigCapacity.value =
            appDataMap['rigCapacity'] ?? profileDataMap['rigCapacity'] ?? 1;
        final addNotes =
            profileDataMap['additionalNotes']?.toString().trim() ?? '';
        shippingNotesController.text = addNotes.isNotEmpty
            ? addNotes
            : (profileDataMap['notes']?.toString() ?? '');
        // shippingRigPhotos.assignAll(List<String>.from(profileDataMap['media']?['rigPhotos'] ?? appDataMap['media']?['rigPhotos'] ?? []));
        shippingExistingCDLUrl.value =
            profileDataMap['cdlFile'] ??
            appDataMap['cdlDoc'] ??
            appDataMap['media']?['cdlPhoto'] ??
            appDataMap['media']?['licensePhoto'] ??
            profileDataMap['media']?['cdlPhoto'] ??
            profileDataMap['media']?['licensePhoto'];
        shippingCdlFileName.value =
            profileDataMap['cdlFileName'] ??
            appDataMap['cdlDocName'] ??
            appDataMap['media']?['cdlDocName'] ??
            'CDL Document';

        shippingExistingInsuranceUrl.value =
            profileDataMap['insuranceFile'] ??
            appDataMap['insuranceFile'] ??
            appDataMap['media']?['insurance'] ??
            appDataMap['media']?['dotCopy'];
        shippingInsuranceFileName.value =
            profileDataMap['insuranceFileName'] ??
            appDataMap['insuranceFileName'] ??
            appDataMap['media']?['insuranceFileName'] ??
            'Insurance Document';
        insuranceExpiryController.text =
            profileDataMap['insuranceExpiry'] ??
            appDataMap['insuranceExpiry'] ??
            '';

        experience.value = appDataMap['experience']?.toString();
        selectedRegions.assignAll(
          List<String>.from(appDataMap['regions'] ?? []),
        );
      }

      final travelPrefRaw =
          draft['travelPreferences'] ??
          profileDataMap['travelPreferences'] ??
          merged['travelPreferences'] ??
          [];
      if (travelPrefRaw is List) {
        if (assignedServiceMatchesTab(activeService, 'Clipping')) {
          clippingTravelFees.clear();
          for (var pref in travelPrefRaw) {
            if (pref is! Map) continue;
            final m = Map<String, dynamic>.from(pref);
            final region = VendorTravelPreferencePayload.labelFromRow(m);
            if (region.isEmpty) continue;
            clippingTravelFees[region] =
                VendorTravelPreferencePayload.clippingFeeStructureFromRow(m);
          }
        } else if (assignedServiceMatchesTab(activeService, 'Bodywork')) {
          final Map<String, Map<String, dynamic>> travelMap = {};
          selectedTravel.clear();
          for (var item in travelPrefRaw) {
            if (item is Map) {
              final Map<String, dynamic> itemMap =
                  Map<String, dynamic>.from(item);
              final categoryName =
                  VendorTravelPreferencePayload.labelFromRow(itemMap);
              if (categoryName.isEmpty) continue;
              final ui =
                  VendorTravelPreferencePayload.toUiEditingState(itemMap);
              travelMap[categoryName] = {
                'type': categoryName,
                'feeType': ui['feeType']!,
                'price': ui['price']!,
                'disclaimer': ui['disclaimer']!,
              };
              if (!selectedTravel.contains(categoryName)) {
                selectedTravel.add(categoryName);
              }
            } else {
              final name = item.toString().trim();
              if (name.isNotEmpty) {
                travelMap[name] = {
                  'type': name,
                  'feeType': 'No travel fee',
                  'price': '',
                  'disclaimer': '',
                };
                if (!selectedTravel.contains(name)) {
                  selectedTravel.add(name);
                }
              }
            }
          }
          selectedTravelData.assignAll(travelMap);
        } else {
          final List<String> cats = travelPrefRaw
              .map(
                (e) => e is Map
                    ? VendorTravelPreferencePayload.labelFromRow(
                        Map<String, dynamic>.from(e),
                      )
                    : e.toString().trim(),
              )
              .where((s) => s.isNotEmpty)
              .toList();
          selectedTravel.assignAll(cats);
        }
      }

      final cp =
          draft['cancellationPolicy'] ?? profileDataMap['cancellationPolicy'];
      hydrateCancellationPolicyFrom(cp);

      // Populate service-specific photos (profile, draft, list application media, VendorModel subdoc)
      final serviceType = activeService['serviceType']?.toString();
      if (serviceType != null &&
          serviceExistingPhotos.containsKey(serviceType)) {
        final draftBlock = draft is Map
            ? Map<String, dynamic>.from(draft)
            : null;
        final urls = mergeServicePortfolioMediaUrls(
          serviceType: serviceType,
          vendorRoot: Map<String, dynamic>.from(vendorRootData),
          profileData: profileDataMap,
          appData: appDataMap,
          draftBlock: draftBlock,
        );
        serviceExistingPhotos[serviceType]!.assignAll(urls);
        existingPhotos.assignAll(urls);
      }
    }
  }

  Future<void> fetchDynamicTags() async {
    try {
      final response = await _apiService.getRequest(
        '/system-config/tag-types/with-values?category=Grooming',
      );
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List types = response.body['data'];

        final disciplineType = types.firstWhereOrNull(
          (t) => t['name'] == 'Disciplines',
        );
        if (disciplineType != null) {
          disciplineOptions.assignAll(
            List<String>.from(disciplineType['values'].map((v) => v['name'])),
          );
          if (!disciplineOptions.contains('Other'))
            disciplineOptions.add('Other');
          _cachedDisciplineOptions = List<String>.from(disciplineOptions);
        }

        final horseLevelType = types.firstWhereOrNull(
          (t) => t['name'] == 'Typical Level of Horses',
        );
        if (horseLevelType != null) {
          horseLevelOptions.assignAll(
            List<String>.from(horseLevelType['values'].map((v) => v['name'])),
          );
          _cachedHorseLevelOptions = List<String>.from(horseLevelOptions);
        }

      }

      // Fetch Shipping specific tags
      final shippingResponse = await _apiService.getRequest(
        '/system-config/tag-types/with-values?category=Shipping',
      );
      if (shippingResponse.statusCode == 200 &&
          shippingResponse.body['success'] == true) {
        final List types = shippingResponse.body['data'];

        for (var type in types) {
          final name = type['name'];
          final List<String> values = List<String>.from(
            type['values'].map((v) => v['name']),
          );

          if (name == 'Hauling Experience' || name == 'Operation Type') {
            shippingOperationOptions.assignAll(values);
            _cachedShippingOperationOptions = values;
          } else if (name == 'Travel Scope') {
            shippingTravelScopeOptions.assignAll(values);
            _cachedShippingTravelScopeOptions = values;
          } else if (name == 'Rig Type') {
            shippingRigTypeOptions.assignAll(values);
            _cachedShippingRigTypeOptions = values;
          } else if (name == 'Stall Type') {
            shippingStallOptions.assignAll(values);
            _cachedShippingStallOptions = values;
          } else if (name == 'Services Offered' ||
              name == 'Shipping Services') {
            shippingServicesOptions.assignAll(values);
            _cachedShippingServicesOptions = values;
          }
        }
      }

      // Fetch Bodywork specific tags
      final bodyworkResponse = await _apiService.getRequest(
        '/system-config/tag-types/with-values?category=Bodywork',
      );
      if (bodyworkResponse.statusCode == 200 &&
          bodyworkResponse.body['success'] == true) {
        final List types = bodyworkResponse.body['data'];
        for (var type in types) {
          final name = type['name'];
          final List<String> values = List<String>.from(
            type['values'].map((v) => v['name']),
          );

          if (name == 'Modality Offered' || name == 'Modalities Offered') {
            bodyworkModalityOptions.assignAll(values);
            if (!bodyworkModalityOptions.contains('Other'))
              bodyworkModalityOptions.add('Other');
          } else if (name == 'Disciplines') {
            // Append or set if empty
            for (var v in values) {
              if (!disciplineOptions.contains(v)) disciplineOptions.add(v);
            }
          } else if (name == 'Typical Level of Horses') {
             for(var v in values) { if(!horseLevelOptions.contains(v)) horseLevelOptions.add(v); }
          }
        }
        // Trigger re-population of services if we already have profile data
        if (assignedServices.isNotEmpty) {
          _mergeBodyworkModalities();
        }
      }

      await _fetchFarrierTagsAndHydrate();

      // Use SystemConfigController for regions (single source of truth)
      final systemConfig = Get.find<SystemConfigController>();
      if (systemConfig.regions.isEmpty) await systemConfig.fetchRegions();
      regionOptions.assignAll(systemConfig.regionNames);
      _cachedRegionOptions = List<String>.from(regionOptions);
    } catch (e) {
      debugPrint('Error fetching tags: $e');
    }
  }

  void _mergeBodyworkModalities() {
    final services = assignedServices;
    final activeService = services.firstWhereOrNull(
      (s) => assignedServiceMatchesTab(s, 'Bodywork'),
    );
    if (activeService == null) return;

    // Prefer draft + merged GET payload (VendorModel.servicesData + assigned profile)
    // so we stay aligned with Groom profile / Services & Rates — not only embedded
    // `assignedServices[].profile.profileData`, which can lag or omit rates.
    final draftBw = draftServicesData['bodywork'];
    Map<String, dynamic> mergedProfilePd = {};
    if (vendorRootData.isNotEmpty) {
      final merged = mergedVendorServiceDisplayData(
        Map<String, dynamic>.from(vendorRootData),
        'Bodywork',
      );
      final m = merged['profileData'];
      if (m is Map) mergedProfilePd = Map<String, dynamic>.from(m);
    }
    Map<String, dynamic> draftPd = {};
    if (draftBw is Map) {
      draftPd = Map<String, dynamic>.from(draftBw['profileData'] ?? {});
    }

    final application = activeService['application'] ?? {};
    final appData = application['applicationData'] ?? application ?? {};

    final List existingServices = List.from(
      draftPd['services'] ??
          mergedProfilePd['services'] ??
          activeService['profile']?['profileData']?['services'] ??
          [],
    );

    final List<String> appModalities = List<String>.from(
      appData['modalities'] ?? [],
    );

    List<String> baseModalities = bodyworkModalityOptions.isNotEmpty
        ? bodyworkModalityOptions.toList()
        : (existingServices
                      .map(
                        (s) => s is Map ? s['name'].toString() : s.toString(),
                      )
                      .toList() +
                  appModalities.map((m) => m.toString()).toList())
              .toSet()
              .toList();

    if (baseModalities.isEmpty) {
      baseModalities = [
        'Sports Massage',
        'Myofascial Release',
        'PEMF',
        'Chiropractic',
        'Acupuncture',
        'Other',
      ];
    }
    if (!baseModalities.contains('Other')) baseModalities.add('Other');

    final baseKeys = baseModalities.map(_editProfileBodyworkNameKey).toSet();

    Map<String, dynamic> rowForCatalogName(String name) {
      final existing = existingServices.firstWhereOrNull(
        (s) =>
            s is Map &&
            _editProfileBodyworkNameKey(s['name']) ==
                _editProfileBodyworkNameKey(name),
      );
      final inApp = appModalities.any(
        (m) =>
            _editProfileBodyworkNameKey(m) == _editProfileBodyworkNameKey(name),
      );

      if (existing != null) {
        final em = Map<String, dynamic>.from(existing!);
        return {
          'name': name,
          'rates': em['rates'] != null
              ? Map<String, dynamic>.from(em['rates'] as Map)
              : {'30': '', '45': '', '60': '', '90': ''},
          'isSelected': RxBool(
            em['isSelected'] == null || em['isSelected'] == true,
          ),
          'note': em['note'] ?? '',
          'trainerPresence': em['trainerPresence'],
          'vetApproval': em['vetApproval'],
        };
      }
      return {
        'name': name,
        'rates': {'30': '', '45': '', '60': '', '90': ''},
        'isSelected': RxBool(inApp),
      };
    }

    final rows = baseModalities.map(rowForCatalogName).toList();

    for (final es in existingServices) {
      if (es is! Map) continue;
      final em = Map<String, dynamic>.from(es);
      final n = em['name']?.toString() ?? '';
      if (n.isEmpty) continue;
      if (baseKeys.contains(_editProfileBodyworkNameKey(n))) continue;
      rows.add({
        'name': n,
        'rates': em['rates'] != null
            ? Map<String, dynamic>.from(em['rates'] as Map)
            : {'30': '', '45': '', '60': '', '90': ''},
        'isSelected': RxBool(
          em['isSelected'] == null || em['isSelected'] == true,
        ),
        'note': em['note'] ?? '',
        'trainerPresence': em['trainerPresence'],
        'vetApproval': em['vetApproval'],
      });
    }

    bodyworkServices.assignAll(rows);
  }

  // Actions
  void togglePayment(String method) {
    if (selectedPayments.contains(method)) {
      selectedPayments.remove(method);
    } else {
      selectedPayments.add(method);
    }
  }

  void addHighlight() => highlightControllers.add(TextEditingController());
  void removeHighlight(int index) => highlightControllers.removeAt(index);

  void toggleDiscipline(String disc) {
    if (selectedDisciplines.contains(disc)) {
      selectedDisciplines.remove(disc);
    } else {
      selectedDisciplines.add(disc);
    }
  }

  void toggleHorseLevel(String level) {
    if (selectedHorseLevels.contains(level)) {
      selectedHorseLevels.remove(level);
    } else {
      selectedHorseLevels.add(level);
    }
  }

  void toggleRegion(String region) {
    if (selectedRegions.contains(region)) {
      selectedRegions.remove(region);
    } else {
      selectedRegions.add(region);
    }
  }

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) newProfileImage.value = File(image.path);
  }

  Future<void> pickCoverImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) newCoverImage.value = File(image.path);
  }

  Future<void> addServicePhoto(String serviceType) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty && serviceNewPhotos.containsKey(serviceType)) {
      serviceNewPhotos[serviceType]!.addAll(
        images.map((image) => File(image.path)),
      );
      // Also sync to legacy newPhotos if on that tab
      newPhotos.addAll(images.map((image) => File(image.path)));
    }
  }

  void removeServiceExistingPhoto(String serviceType, int index) {
    if (serviceExistingPhotos.containsKey(serviceType)) {
      serviceExistingPhotos[serviceType]!.removeAt(index);
      existingPhotos.assignAll(serviceExistingPhotos[serviceType]!);
    }
  }

  void removeServiceNewPhoto(String serviceType, int index) {
    if (serviceNewPhotos.containsKey(serviceType)) {
      serviceNewPhotos[serviceType]!.removeAt(index);
      // We don't easily sync back to legacy newPhotos because it's shared,
      // but UI will use service-specific ones.
    }
  }

  Future<void> addShippingRigPhoto() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      newShippingRigPhotos.addAll(images.map((image) => File(image.path)));
    }
  }

  void removeExistingShippingRigPhoto(int index) =>
      shippingRigPhotos.removeAt(index);
  void removeNewShippingRigPhoto(int index) =>
      newShippingRigPhotos.removeAt(index);

  Future<void> pickShippingCDLFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result != null) {
      shippingCDLFile.value = File(result.files.single.path!);
      shippingCdlFileName.value = result.files.single.name;
    }
  }

  Future<void> pickShippingInsuranceFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result != null) {
      shippingInsuranceFile.value = File(result.files.single.path!);
      shippingInsuranceFileName.value = result.files.single.name;
    }
  }

  void addBraidingService(String name) {
    if (name.isNotEmpty) {
      braidingServices.add({
        'name': name,
        'price': TextEditingController(text: '0'),
        'isSelected': true.obs,
      });
      braidingServiceInputController.clear();
    }
  }

  void addClippingService(String name) {
    if (name.isNotEmpty) {
      clippingServices.add({
        'name': name,
        'price': TextEditingController(text: '0'),
        'isSelected': true.obs,
      });
      clippingServiceInputController.clear();
    }
  }

  Future<void> pickBodyworkCertification() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      bodyworkCertFiles.add(File(result.files.single.path!));
    }
  }

  void removeBodyworkCertFile(int index) => bodyworkCertFiles.removeAt(index);
  void removeBodyworkExistingCert(int index) {
    bodyworkExistingCertUrls.removeAt(index);
  }

  void toggleBraidingService(int index) {
    final service = braidingServices[index];
    service['isSelected'].value = !service['isSelected'].value;
  }

  void toggleClippingService(int index) {
    final service = clippingServices[index];
    service['isSelected'].value = !service['isSelected'].value;
  }

  Future<String?> _uploadFile(File file, String type) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': type,
      });
      final response = await _apiService.postRequest(
        '/upload?type=$type',
        formData,
      );
      if (response.statusCode == 200 && response.body['success'] == true) {
        return response.body['data']['filename'];
      }
    } catch (e) {
      debugPrint('Error uploading $type: $e');
    }
    return null;
  }

  Future<void> saveProfile() async {
    isSaving.value = true;
    try {
      // 1. Upload All Files
      String? profile = profilePhotoUrl.value;
      if (newProfileImage.value != null) {
        profile = await _uploadFile(newProfileImage.value!, 'profile');
      }

      String? bannerImage = coverImageUrl.value;
      if (newCoverImage.value != null) {
        bannerImage = await _uploadFile(newCoverImage.value!, 'profile');
      }

      // Upload media for each service
      final Map<String, List<String>> serviceMediaKeys = {};
      for (var serviceType in serviceNewPhotos.keys) {
        final List<String> mediaKeys = [
          ...(serviceExistingPhotos[serviceType] ?? []),
        ];
        final List<File> newFiles = serviceNewPhotos[serviceType] ?? [];

        if (newFiles.isNotEmpty) {
          final uploads = await Future.wait(
            newFiles.map((f) => _uploadFile(f, serviceType.toLowerCase())),
          );
          mediaKeys.addAll(uploads.whereType<String>());
        }
        serviceMediaKeys[serviceType] = mediaKeys;
      }

      // Handle Shipping specifically if needed (it uses shippingMedia currently)
      final List<String> shippingMedia = [...shippingRigPhotos];
      if (newShippingRigPhotos.isNotEmpty) {
        final uploads = await Future.wait(
          newShippingRigPhotos.map((f) => _uploadFile(f, 'shipping')),
        );
        shippingMedia.addAll(uploads.whereType<String>());
      }

      // 2. Prepare Payload
      final vendorPayload = {
        'firstName': fullNameController.text.split(' ').first,
        'lastName': fullNameController.text.contains(' ')
            ? fullNameController.text.split(' ').skip(1).join(' ')
            : '',
        'phone': phoneController.text,
        'businessName': businessNameController.text,
        'bio': aboutController.text,
        'notesForTrainer': notesForTrainerController.text,
        'profile': profile,
        'bannerImage': bannerImage,
        'otherPaymentDetails': otherPaymentController.text.trim(),
        'paymentMethods': selectedPayments.toList(),

        'highlights': highlightControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
        'homeBaseLocation': {
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'country': countryController.text.trim(),
        },

        'isProfileSetup': true,
      };

      // Start with cached data to preserve fields we don't manage
      final servicesData = Map<String, dynamic>.from(rawServicesData);

      // Save currently active tab into draft before payload building
      saveCurrentTabToCache(selectedServiceIndex.value);

      // Loop over assigned services and merge their drafts
      for (var s in assignedServices) {
        final type = s['serviceType']?.toString();
        if (type == null) continue;
        final typeKey = type.toLowerCase();

        final draft = draftServicesData[typeKey] ?? {};

        final existing = Map<String, dynamic>.from(servicesData[typeKey] ?? {});
        final existingApp = Map<String, dynamic>.from(
          existing['applicationData'] ?? {},
        );
        final existingProf = Map<String, dynamic>.from(
          existing['profileData'] ?? {},
        );

        final newApp = Map<String, dynamic>.from(
          draft['applicationData'] ?? {},
        );
        final newProf = Map<String, dynamic>.from(draft['profileData'] ?? {});

        if (type == 'Shipping') {
          final List<String> shippingMedia = [...shippingRigPhotos];
          for (var f in newShippingRigPhotos) {
            final key = await _uploadFile(f, 'shipping_rigs');
            if (key != null) shippingMedia.add(key);
          }
          String? cdlUrl = shippingExistingCDLUrl.value;
          if (shippingCDLFile.value != null) {
            cdlUrl = await _uploadFile(shippingCDLFile.value!, 'shipping_docs');
          }
          String? insUrl = shippingExistingInsuranceUrl.value;
          if (shippingInsuranceFile.value != null) {
            insUrl = await _uploadFile(
              shippingInsuranceFile.value!,
              'shipping_docs',
            );
          }

          newApp['cdlDoc'] = cdlUrl;
          newApp['cdlDocName'] = shippingCdlFileName.value;
          newApp['insuranceFile'] = insUrl;
          newApp['insuranceFileName'] = shippingInsuranceFileName.value;
          newApp['insuranceExpiry'] = insuranceExpiryController.text;

          newApp['media'] = {
            'cdlPhoto': cdlUrl,
            'insurance': insUrl,
            'rigPhotos': shippingMedia,
          };
          newProf['media'] = {'rigPhotos': shippingMedia};
        } else if (type == 'Farrier') {
          String? insUrl = farrierExistingInsuranceUrl.value;
          if (farrierInsuranceFile.value != null) {
            insUrl = await _uploadFile(
              farrierInsuranceFile.value!,
              'farrier_docs',
            );
          }
          newApp['insurance'] = {
            'status': farrierInsuranceStatus.value,
            'document': insUrl,
            'fileName': farrierInsuranceFileName.value,
            'expirationDate': farrierInsuranceExpiry.value?.toIso8601String(),
          };

          if (serviceMediaKeys.containsKey(type)) {
            newApp['media'] = serviceMediaKeys[type] ?? [];
            newProf['media'] = serviceMediaKeys[type] ?? [];
          }
        } else {
          if (serviceMediaKeys.containsKey(type)) {
            newApp['media'] = serviceMediaKeys[type] ?? [];
            newProf['media'] = serviceMediaKeys[type] ?? [];
          }
        }

        servicesData[typeKey] = {
          ...draft,
          'applicationData': {...existingApp, ...newApp},
          'profileData': {...existingProf, ...newProf},
        };
      }

      final servicesPayload = {
        'servicesData': servicesData,
        'isProfileSetup': true,
      };

      final combinedPayload = {...vendorPayload, ...servicesPayload};
      final vendorResponse = await _apiService.putRequest(
        '/vendors/me',
        combinedPayload,
      );

      if (vendorResponse.statusCode == 200) {
        final vid = vendorMongoIdFromRoot(
          Map<String, dynamic>.from(vendorRootData),
        );
        if (vid != null) {
          for (final s in assignedServices) {
            final type = s['serviceType']?.toString();
            if (type == null) continue;
            final typeKey = type.toLowerCase();
            final block = servicesData[typeKey];
            if (block is! Map) continue;
            await syncVendorServiceDocuments(
              api: _apiService,
              vendorMongoId: vid,
              assignedServiceRow: s,
              profileData: Map<String, dynamic>.from(
                block['profileData'] ?? {},
              ),
              applicationData: Map<String, dynamic>.from(
                block['applicationData'] ?? {},
              ),
            );
          }
        }

        // Update local AuthController state for immediate UI reflection in Menu/Personal Info
        if (_authController.currentUser.value != null) {
          final updatedUser = _authController.currentUser.value!.copyWith(
            firstName: fullNameController.text.split(' ').first,
            lastName: fullNameController.text.contains(' ')
                ? fullNameController.text.split(' ').skip(1).join(' ')
                : '',
            phone: phoneController.text,
            bio: aboutController.text,
            avatar: profile,
            photo: profile,
            coverImage: bannerImage,
          );
          _authController.currentUser.value = updatedUser;
          _authController.currentUser.refresh();
        }

        _authController.currentUser.refresh();

        // Refresh the view profile controller if it's active
        if (Get.isRegistered<GroomViewProfileController>()) {
          Get.find<GroomViewProfileController>().fetchProfile();
        }

        for (final list in serviceNewPhotos.values) {
          list.clear();
        }
        newShippingRigPhotos.clear();
        newProfileImage.value = null;
        newCoverImage.value = null;

        Get.back();
        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw vendorResponse.body['message'] ?? 'Failed to update profile';
      }
    } catch (e) {
      debugPrint('Save error: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Home base is edited on the Details tab (index 0). [saveCurrentTabToCache] used to
  /// return immediately for index 0, so `applicationData.homeBase` never reached PUT
  /// `/vendors/me` (backend merges this in `_applyServicesDataToVendorServiceProfiles`).
  void _mergeHomeBaseIntoAllServiceDrafts() {
    final hb = {
      'city': cityController.text.trim(),
      'state': stateController.text.trim(),
      'country': countryController.text.trim(),
    };
    for (final s in assignedServices) {
      final type = s['serviceType']?.toString();
      if (type == null) continue;
      final typeKey = type.toLowerCase();
      final existing = Map<String, dynamic>.from(draftServicesData[typeKey] ?? {});
      final existingApp = Map<String, dynamic>.from(existing['applicationData'] ?? {});
      final existingProf = Map<String, dynamic>.from(existing['profileData'] ?? {});
      draftServicesData[typeKey] = {
        ...existing,
        'applicationData': {
          ...existingApp,
          'homeBase': hb,
        },
        'profileData': existingProf,
      };
    }
  }

  void saveCurrentTabToCache(int index) {

    if (index == 0 && assignedServices.isNotEmpty) {
      _mergeHomeBaseIntoAllServiceDrafts();
    }
    if (index == 0 || assignedServices.isEmpty || index > assignedServices.length) return;

    final type = assignedServices[index - 1]['serviceType']?.toString();
    if (type == null) return;
    final typeKey = type.toLowerCase();

    final fb = facebookController.text.trim();
    final ig = instagramController.text.trim();

    final Map<String, dynamic> appData = {
      'homeBase': {
        'city': cityController.text,
        'state': stateController.text,
        'country': countryController.text.trim().toUpperCase() == 'USA'
            ? 'USA'
            : countryController.text.trim(),
      },
      'experience': experience.value,
      'disciplines': selectedDisciplines.toList(),
      'otherDiscipline': otherDisciplineController.text,
      'horseLevels': selectedHorseLevels.toList(),
      'regions': selectedRegions.map((regionName) {
        final systemConfig = Get.find<SystemConfigController>();
        final regionObj = systemConfig.regions.firstWhereOrNull(
            (r) => (r['region'] ?? r['label'] ?? r['name'] ?? '').toString() == regionName);
        return regionObj != null ? regionObj['_id'].toString() : regionName;
      }).toList(),
      'experienceHighlights': highlightControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
      'facebookLink': fb,
      'instagramLink': ig,
    };

    final Map<String, dynamic> profData = {
      'socialMedia': {'facebook': fb, 'instagram': ig},
      'cancellationPolicy': {
        'policy': isCustomCancellation.value
            ? customCancellationController.text
            : cancellationPolicy.value,
        'isCustom': isCustomCancellation.value,
      },
    };

    if (type == 'Grooming') {
      final existing = Map<String, dynamic>.from(
        draftServicesData[typeKey] ?? {},
      );
      final existingApp = Map<String, dynamic>.from(
        existing['applicationData'] ?? {},
      );
      final existingProf = Map<String, dynamic>.from(
        existing['profileData'] ?? {},
      );

      draftServicesData[typeKey] = {
        ...existing,
        'applicationData': {
          ...existingApp,
          ...appData,
          'socialMedia': {'facebook': fb, 'instagram': ig},
          'facebookLink': fb,
          'instagramLink': ig,
        },
        'profileData': {...existingProf, ...profData},
        'capabilities': {
          'support': selectedSupport.toList(),
          'handling': selectedHandling.toList(),
        },
        'additionalSkills': selectedAdditionalSkills.toList(),
        'travelPreferences':
            VendorTravelPreferencePayload.groomBraidTravelToApi(selectedTravel.toList()),
        'cancellationPolicy':
            profData['cancellationPolicy'], // Keep at root too
      };
      return; // Exit early as we've handled Grooming specially
    } else if (type == 'Braiding') {
      profData['services'] = braidingServices.map((s) {
        final ctrl = s['price'];
        return {
          'name': s['name'],
          'price': ctrl is TextEditingController
              ? ctrl.text
              : (ctrl?.toString() ?? '0'),
          'isSelected': s['isSelected'].value,
        };
      }).toList();
      profData['additionalSkills'] = selectedAdditionalSkills.toList();
      profData['travelPreferences'] =
          VendorTravelPreferencePayload.groomBraidTravelToApi(selectedTravel.toList());
    } else if (type == 'Clipping') {
      profData['services'] = clippingServices.map((s) {
        final ctrl = s['price'];
        return {
          'name': s['name'],
          'price': ctrl is TextEditingController
              ? ctrl.text
              : (ctrl?.toString() ?? '0'),
          'isSelected': s['isSelected'].value,
        };
      }).toList();
      profData['additionalSkills'] = selectedAdditionalSkills.toList();
      profData['travelPreferences'] = clippingTravelFees.entries
          .map(
            (e) => VendorTravelPreferencePayload.fromClippingRegionEntry(
              e.key,
              Map<String, dynamic>.from(e.value),
            ),
          )
          .toList();
    } else if (type == 'Farrier') {
      profData['services'] = farrierServices.map((s) {
        final ctrl = s['price'];
        return {
          'name': s['name'],
          'price': ctrl is TextEditingController
              ? ctrl.text
              : (ctrl?.toString() ?? '0'),
          'isSelected': s['isSelected'].value,
        };
      }).toList();
      profData['addOns'] = farrierAddOns.map((s) {
        final ctrl = s['price'];
        return {
          'name': s['name'],
          'price': ctrl is TextEditingController
              ? ctrl.text
              : (ctrl?.toString() ?? '0'),
          'isSelected': s['isSelected'].value,
        };
      }).toList();
      appData['relevantCertifications'] = selectedCertifications.toList();
      appData['certifications'] = selectedCertifications.toList();
      appData['otherCertification'] = otherCertificationController.text;
      appData['scopeOfWork'] = selectedFarrierScope.toList();
      appData['otherScope'] = otherFarrierScopeController.text;
      profData['travelPreferences'] = selectedTravelData.entries
          .map(
            (e) => VendorTravelPreferencePayload.fromUiZone(
              label: e.key,
              feeType:
                  e.value['feeType']?.toString() ?? 'No travel fee',
              price: e.value['price']?.toString().replaceAll(',', '') ?? '',
              disclaimer: e.value['disclaimer']?.toString() ?? '',
            ),
          )
          .toList();

      profData['clientIntake'] = {
        'policy': farrierNewClientPolicy.value,
        'minHorses': farrierMinHorses.value,
        'emergencySupport': farrierEmergencySupport.value,
      };

      profData['insurance'] = {
        'status': farrierInsuranceStatus.value,
        'document': farrierExistingInsuranceUrl.value,
        'fileName': farrierInsuranceFileName.value,
        'expirationDate': farrierInsuranceExpiry.value?.toIso8601String(),
      };

      // Also sync to applicationData for legacy reasons
      appData['facebookLink'] = fb;
      appData['instagramLink'] = ig;
      appData['clientIntake'] = profData['clientIntake'];
      appData['insurance'] = profData['insurance'];

      profData['insuranceStatus'] = farrierInsuranceStatus.value;
    } else if (_editProfileIsBodyworkServiceType(type)) {
      //       final selectedModalities = bodyworkServices
      //           .where((raw) {
      //             if (raw is! Map) return false;
      //             final m = Map<String, dynamic>.from(raw);
      //             final sel = m['isSelected'];
      //             if (sel is RxBool) return sel.value;
      //             if (sel is bool) return sel;
      //             return true;
      //           })
      //           .map((raw) => Map<String, dynamic>.from(raw as Map)['name']?.toString() ?? '')
      //           .where((n) => n.isNotEmpty)
      //           .toList();
      //       appData['modalities'] = selectedModalities;

      profData['insurance'] = {
        'status': farrierInsuranceStatus.value,
        'document': farrierExistingInsuranceUrl.value,
        'fileName': farrierInsuranceFileName.value,
        'expirationDate': farrierInsuranceExpiry.value?.toIso8601String(),
      };
    } else if (type == 'Bodywork') {
      appData['modalities'] = bodyworkModalityOptions.toList();

      appData['otherModality'] = otherModalityController.text;
      appData['professionalStandards'] = selectedBodyworkStandards.toList();
      final serialized = bodyworkServices
          .map(
            (s) => {
              'name': s['name'],
              'rates': s['rates'],
              'isSelected': s['isSelected'].value,
              'note': s['note'],
              'trainerPresence': s['trainerPresence'],
              'vetApproval': s['vetApproval'],
            },
          )
          .toList();

      // Never replace saved rates with [] when the Rx list was never hydrated (e.g. serviceType casing).
      final draftBlock = draftServicesData[typeKey];
      final prevServices = draftBlock is Map
          ? (Map<String, dynamic>.from(
              draftBlock['profileData'] ?? {},
            )['services'])
          : null;
      if (serialized.isNotEmpty) {
        profData['services'] = serialized;
      } else if (prevServices is List && prevServices.isNotEmpty) {
        // omit profData['services'] — merge keeps existing profile services
      } else {
        profData['services'] = serialized;
      }
      profData['travelPreferences'] = selectedTravelData.entries
          .map(
            (e) => VendorTravelPreferencePayload.fromUiZone(
              label: e.key,
              feeType:
                  e.value['feeType']?.toString() ?? 'No travel fee',
              price: e.value['price']?.toString().replaceAll(',', '') ?? '',
              disclaimer: e.value['disclaimer']?.toString() ?? '',
            ),
          )
          .toList();
    } else if (type == 'Shipping') {
      appData['businessInfo'] = {
        'legalName': businessNameController.text,
        'usdotNumber': dotNumberController.text,
      };
      appData['usdotNumber'] = dotNumberController.text;
      appData['operationType'] = shippingOperationType.value;
      appData['travelScope'] = shippingTravelScope.toList();
      appData['rigTypes'] = shippingRigTypes.toList();
      appData['stallType'] = shippingStallTypes.toList();
      appData['rigCapacity'] = shippingRigCapacity.value;
      appData['hasCDL'] = shippingHasCDL.value;
      appData['insuranceExpiry'] = insuranceExpiryController.text;
      appData['insuranceFileName'] = shippingInsuranceFileName.value;
      appData['cdlDocName'] = shippingCdlFileName.value;

      profData['servicesOffered'] = shippingServicesOffered.toList();
      profData['additionalNotes'] = shippingNotesController.text;
      profData['notes'] = shippingNotesController.text;
      profData['insuranceExpiry'] = insuranceExpiryController.text;
    }

    final existing = Map<String, dynamic>.from(
      draftServicesData[typeKey] ?? {},
    );
    final existingApp = Map<String, dynamic>.from(
      existing['applicationData'] ?? {},
    );
    final existingProf = Map<String, dynamic>.from(
      existing['profileData'] ?? {},
    );

    draftServicesData[typeKey] = {
      'applicationData': {...existingApp, ...appData},
      'profileData': {...existingProf, ...profData},
      if (profData['travelPreferences'] != null)
        'travelPreferences': profData['travelPreferences'],
    };
  }

  Future<void> pickFarrierInsuranceDoc() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        farrierInsuranceFile.value = File(result.files.single.path!);
        farrierInsuranceFileName.value = result.files.single.name;
        farrierExistingInsuranceUrl.value =
            null; // Clear existing if new one picked
      }
    } catch (e) {
      debugPrint('Error picking farrier insurance document: $e');
    }
  }

  Future<void> selectFarrierInsuranceExpiry(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          farrierInsuranceExpiry.value ??
          DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      farrierInsuranceExpiry.value = picked;
    }
  }
}
