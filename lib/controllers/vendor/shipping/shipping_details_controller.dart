import 'dart:io';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/system_config_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/vendor/profile_completed_view.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/vendor/groom/groom_bottom_nav.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/grooming_details_view.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_details_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_detail_view.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_details_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_details_view.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:catch_ride/utils/vendor_service_payload.dart';
import 'package:catch_ride/utils/vendor_service_sync.dart';

class ShippingDetailsController extends GetxController {
  final apiService = Get.find<ApiService>();
  final formKey = GlobalKey<FormState>();
  final RxBool editModeEnabled = false.obs;

  // ── Pricing ────────────────────────────────────────────────────────────────
  final RxBool inquiryPrice = false.obs;
  final baseRateController = TextEditingController();
  final loadedRateController = TextEditingController();

  // ── Selections ──────────────────────────────────────────────────────────────
  final RxList<String> selectedServices = <String>[].obs;
  final RxList<String> travelScope = <String>[].obs;
  final RxList<String> rigTypes = <String>[].obs;
  final RxList<String> stallTypes = <String>[].obs;
  final RxList<String> regionsCovered = <String>[].obs;
  final RxString operationType = ''.obs;
  final RxList<String> operationOptions = <String>[].obs;

  // ── Content ────────────────────────────────────────────────────────────────
  final equipmentSummaryController = TextEditingController();
  final additionalNotesController = TextEditingController();

  // Summary Data (Read-only -> Editable)
  final locationDisplay = 'N/A'.obs;
  final experienceDisplay = RxnString();
  final experienceOptions = ['0-1', '2-4', '5-9', '10+'];

  final disciplines = <String>[].obs;
  final disciplineOptions = <String>[].obs;

  final horseLevels = <String>[].obs;
  final horseLevelOptions = <String>[].obs;

 // final regionsCovered = <String>[].obs;
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

  final usdotDisplay = "USDOT 1234567".obs;

  // ── Credentials & Insurance ────────────────────────────────────────────────
  final RxBool hasCDL = false.obs;
  final RxBool isCustomCancellation = false.obs;
  final customCancellationController = TextEditingController();
  final Rxn<File> cdlFile = Rxn<File>();
  final Rxn<File> insuranceFile = Rxn<File>();
  final RxnString currentCdlUrl = RxnString();
  final RxnString currentInsuranceUrl = RxnString();
  final RxnString currentCdlFileName = RxnString();
  final RxnString currentInsuranceFileName = RxnString();
  final insuranceExpiryController = TextEditingController();
  final cancellationPolicy = RxnString();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // ── Dynamic Options ────────────────────────────────────────────────────────
  final RxList<String> serviceOptions = <String>[].obs;
  final RxList<String> travelOptions = <String>[].obs;
  final RxList<String> rigOptions = <String>[].obs;
  final RxList<String> stallOptions = <String>[].obs;
 // final RxList<String> regionOptions = <String>[].obs;
  final List<String> cancellationOptions = [
    'Flexible (24+ hrs)',
    'Moderate (48+ hrs)',
    'Strict (72+ hrs)',
  ];

  /// Label for preset row; invalid/empty while not in custom mode shows hint.
  String? get cancellationPresetForDropdown {
    if (isCustomCancellation.value) return null;
    final v = cancellationPolicy.value?.trim();
    if (v == null || v.isEmpty) return null;
    return cancellationOptions.contains(v) ? v : null;
  }

  void setCustomCancellation(bool enabled) {
    isCustomCancellation.value = enabled;
    if (enabled) cancellationPolicy.value = null;
  }

  void toggleCustomCancellation() {
    setCustomCancellation(!isCustomCancellation.value);
  }

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      // Run both in parallel
      await Future.wait([
        fetchDynamicTags(),
        fetchCurrentDetails(isInitializing: true),
      ]);
      _applyApplicationFilters();
    } catch (e) {
      debugPrint('Error initializing shipping data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyApplicationFilters() {
    // This logic relies on both dynamic tags and vendor data being loaded
    final shippingService =
        _shippingService; // I'll need to store this or re-find it
    if (shippingService == null) return;

    final applicationData =
        shippingService['application']?['applicationData'] ?? {};

    final List<String> appTravel = List<String>.from(
      applicationData['travelScope'] ?? [],
    );
    final List<String> appRigs = List<String>.from(
      applicationData['rigTypes'] ?? [],
    );
    final List<String> appStalls = List<String>.from(
      applicationData['stallTypes'] ?? applicationData['stallType'] ?? [],
    );
    final List<String> appRegions = List<String>.from(
      applicationData['regions'] ?? [],
    );

    if (appTravel.isNotEmpty) {
      travelOptions.assignAll(
        travelOptions.where((opt) => appTravel.contains(opt)).toList(),
      );
    }
    if (appRigs.isNotEmpty) {
      rigOptions.assignAll(
        rigOptions.where((opt) => appRigs.contains(opt)).toList(),
      );
    }
    if (appStalls.isNotEmpty) {
      stallOptions.assignAll(
        stallOptions.where((opt) => appStalls.contains(opt)).toList(),
      );
    }
    if (appRegions.isNotEmpty) {
      regionOptions.assignAll(
        regionOptions.where((opt) => appRegions.contains(opt)).toList(),
      );
    }
  }

  Map<String, dynamic>? _shippingService;

  Future<void> fetchDynamicTags() async {
    try {
      final systemConfig = Get.find<SystemConfigController>();
      if (systemConfig.regions.isEmpty) await systemConfig.fetchRegions();
      final response = await apiService.getRequest(
        '/system-config/tag-types/with-values?category=Shipping',
      );
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List types = response.body['data'];

        for (var type in types) {
          final name = type['name'];
          final List<String> values = List<String>.from(
            type['values'].map((v) => v['name']),
          );

          if (name == 'Services Offered') {
            serviceOptions.assignAll(values);
          } else if (name == 'Travel Scope') {
            travelOptions.assignAll(values);
          } else if (name == 'Rig Types' || name == 'Rig Type') {
            rigOptions.assignAll(values);
          } else if (name == 'Stall Type' || name == 'Stall Types') {
            stallOptions.assignAll(values);
          } else if (name == 'Operation Type') {
            operationOptions.assignAll(values);
          } else if (name == 'Disciplines') {
            disciplineOptions.assignAll(values);
          } else if (name == 'Typical Level of Horses') {
            horseLevelOptions.assignAll(values);
          }
        }
      }
      // Use SystemConfigController for regions (single source of truth)
      regionOptions.assignAll(systemConfig.regionNames);
    } catch (e) {
      debugPrint('Error fetching dynamic tags: $e');
    }
  }

  void _hydrateCancellationFromShippingProfile(dynamic savedPolicy) {
    if (savedPolicy == null) return;
    if (savedPolicy is List) {
      if (savedPolicy.isEmpty) {
        cancellationPolicy.value = null;
        isCustomCancellation.value = false;
        customCancellationController.clear();
        return;
      }
      final presets = savedPolicy
          .map((e) => e.toString())
          .where((e) => cancellationOptions.contains(e))
          .toList();
      if (presets.length == 1) {
        cancellationPolicy.value = presets.first;
        isCustomCancellation.value = false;
        customCancellationController.clear();
        return;
      }
      isCustomCancellation.value = true;
      cancellationPolicy.value = null;
      customCancellationController.text =
          savedPolicy.map((e) => e.toString()).join('; ');
      return;
    }
    final str = savedPolicy.toString();
    if (str.isEmpty) {
      cancellationPolicy.value = null;
      isCustomCancellation.value = false;
      customCancellationController.clear();
      return;
    }
    if (cancellationOptions.contains(str)) {
      cancellationPolicy.value = str;
      isCustomCancellation.value = false;
      customCancellationController.clear();
      return;
    }
    isCustomCancellation.value = true;
    cancellationPolicy.value = null;
    customCancellationController.text = str;
  }

  void _setLocationDisplayFromVendor(
    Map<String, dynamic> vendor,
    Map<String, dynamic> profileData,
    Map<String, dynamic> applicationData,
  ) {
    Map<String, dynamic>? homeBaseMap;

    final appHb = applicationData['homeBase'];
    if (appHb is Map) {
      homeBaseMap = Map<String, dynamic>.from(appHb as Map);
    } else if (profileData['homeBase'] is Map) {
      homeBaseMap = Map<String, dynamic>.from(profileData['homeBase'] as Map);
    } else {
      final rootHb = vendor['homeBaseLocation'];
      if (rootHb is Map) {
        homeBaseMap = Map<String, dynamic>.from(rootHb as Map);
      }
    }

    if (homeBaseMap != null) {
      final line = _formatLocationFromHomeBase(homeBaseMap);
      if (line.isNotEmpty) {
        locationDisplay.value = line;
        return;
      }
    }

    final rootLoc = vendor['location']?.toString().trim() ?? '';
    if (rootLoc.isNotEmpty) {
      locationDisplay.value = rootLoc;
      return;
    }

    locationDisplay.value = 'N/A';
  }

  String _formatLocationFromHomeBase(Map<String, dynamic> m) {
    final c = (m['city'] ?? '').toString().trim();
    final s = (m['state'] ?? '').toString().trim();
    var co = (m['country'] ?? '').toString().trim();
    final lower = co.toLowerCase();
    if (lower == 'usa' || lower == 'us') {
      co = 'USA';
    } else if (lower == 'canada') {
      co = 'Canada';
    }
    final parts = <String>[];
    if (c.isNotEmpty) parts.add(c);
    if (s.isNotEmpty) parts.add(s);
    if (co.isNotEmpty) parts.add(co);
    return parts.join(', ');
  }

  Future<void> fetchCurrentDetails({bool isInitializing = false}) async {
    if (!isInitializing) isLoading.value = true;
    try {
      final systemConfig = Get.find<SystemConfigController>();
      if (systemConfig.regions.isEmpty) await systemConfig.fetchRegions();
      final response = await apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final vendor = response.body['data'];
        Map<String, dynamic> profileData = {};
        Map<String, dynamic> applicationData = {};

        final sdRaw = vendor['servicesData']?['shipping'];
        if (sdRaw is Map) {
          final sd = Map<String, dynamic>.from(sdRaw as Map);
          profileData =
              Map<String, dynamic>.from(sd['profileData'] ?? {});
          applicationData =
              Map<String, dynamic>.from(sd['applicationData'] ?? {});
        }

        final List assignedServices = vendor['assignedServices'] ?? [];
        final shippingService = assignedServices.firstWhereOrNull(
          (s) => s['serviceType'] == 'Shipping',
        );

        if (shippingService != null) {
          _shippingService = shippingService;
          if (profileData.isEmpty) {
            profileData = Map<String, dynamic>.from(
                shippingService['profile']?['profileData'] ?? {});
          }
          if (applicationData.isEmpty) {
            applicationData = Map<String, dynamic>.from(
                shippingService['application']?['applicationData'] ?? {});
          }
        }

        final hasAnything = profileData.isNotEmpty ||
            applicationData.isNotEmpty ||
            shippingService != null;

        _setLocationDisplayFromVendor(
          Map<String, dynamic>.from(vendor as Map),
          profileData,
          applicationData,
        );

        if (hasAnything) {
          final pricing =
              profileData['pricing'] ?? applicationData['pricing'] ?? {};
          inquiryPrice.value = pricing['inquiryPrice'] == true ||
              pricing['inquiryPrice'] == 'true';
          baseRateController.text =
              (pricing['baseRate'] ?? profileData['rates']?['baseRate'] ?? '')
                  .toString();
          loadedRateController.text =
              (pricing['loadedRate'] ??
                      profileData['rates']?['fullyLoaded'] ??
                      '')
                  .toString();

          selectedServices.assignAll(
            List<String>.from(profileData['servicesOffered'] ??
                profileData['services'] ??
                []),
          );

          final List<String> appTravel = List<String>.from(
            applicationData['travelScope'] ?? [],
          );
          travelScope.assignAll(
            List<String>.from(profileData['travelScope'] ?? appTravel),
          );

          final List<String> appRigs = List<String>.from(
            applicationData['rigTypes'] ?? [],
          );
          rigTypes.assignAll(
            List<String>.from(profileData['rigTypes'] ?? appRigs),
          );

          final List<String> appStalls = List<String>.from(
            applicationData['stallTypes'] ?? applicationData['stallType'] ?? [],
          );
          stallTypes.assignAll(
            List<String>.from(
              profileData['stallTypes'] ??
                  profileData['stallType'] ??
                  appStalls,
            ),
          );

          final List<String> appRegions = List<String>.from(
            applicationData['regions'] ?? [],
          );
          final systemConfig = Get.find<SystemConfigController>();
          final List rawRegions = profileData['regionsCovered'] ?? appRegions;
          final List<String> regionNames = rawRegions.map((r) {
            final rStr = r.toString();
            final regionObj = systemConfig.regions.firstWhereOrNull((reg) => reg['_id'].toString() == rStr);
            if (regionObj != null) {
              return (regionObj['region'] ?? regionObj['label'] ?? regionObj['name'] ?? rStr).toString();
            }
            return rStr;
          }).toList();
          regionsCovered.assignAll(regionNames);



          disciplines.assignAll(List<String>.from(
              profileData['disciplines'] ??
                  applicationData['disciplines'] ??
                  []));
          horseLevels.assignAll(List<String>.from(
              profileData['horseLevels'] ??
                  applicationData['horseLevels'] ??
                  []));

          final opProf = profileData['operationType']?.toString().trim() ?? '';
          final opApp =
              applicationData['operationType']?.toString().trim() ?? '';
          operationType.value = opProf.isNotEmpty
              ? opProf
              : (opApp.isNotEmpty
                  ? opApp
                  : 'Independent Small Operation');

          equipmentSummaryController.text =
              profileData['equipmentSummary'] ?? '';
          additionalNotesController.text =
              profileData['additionalNotes'] ?? '';

          experienceDisplay.value =
              (profileData['experience'] ??
                      applicationData['experience'])
                  ?.toString();

          final bi = applicationData['businessInfo'];
          if (bi is Map &&
              bi['dotNumber'] != null &&
              bi['dotNumber'].toString().isNotEmpty) {
            usdotDisplay.value = 'USDOT ${bi['dotNumber']}';
          } else if (bi is Map &&
              bi['usdotNumber'] != null &&
              bi['usdotNumber'].toString().isNotEmpty) {
            usdotDisplay.value = 'USDOT ${bi['usdotNumber']}';
          }

          hasCDL.value = profileData['hasCDL'] ==
                  true ||
              applicationData['confirmLicense'] == true;

          final appMedia = Map<String, dynamic>.from(
              applicationData['media'] is Map
                  ? applicationData['media'] as Map
                  : {});
          currentCdlUrl.value = profileData['cdlFile'] ??
              applicationData['cdlDoc'] ??
              appMedia['licensePhoto'] ??
              appMedia['cdlDoc'];
          currentCdlFileName.value =
              profileData['cdlFileName'] ??
                  applicationData['cdlDocName'] ??
                  appMedia['cdlDocName'] ??
                  'CDL Document';

          currentInsuranceUrl.value = profileData['insuranceFile'] ??
              applicationData['insuranceFile'] ??
              appMedia['insurance'] ??
              appMedia['dotCopy'];
          currentInsuranceFileName.value =
              profileData['insuranceFileName'] ??
                  applicationData['insuranceFileName'] ??
                  appMedia['insuranceFileName'] ??
                  'Insurance Document';

          insuranceExpiryController.text =
              (profileData['insuranceExpiry'] ?? '').toString();

          _hydrateCancellationFromShippingProfile(
              profileData['cancellationPolicy']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching shipping details: $e');
    } finally {
      if (!isInitializing) isLoading.value = false;
    }
  }

  Future<void> pickFile(Rxn<File> target) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result != null && result.files.single.path != null) {
      target.value = File(result.files.single.path!);
      final name = result.files.single.name;
      if (target == insuranceFile) {
        currentInsuranceFileName.value = name;
      } else if (target == cdlFile) {
        currentCdlFileName.value = name;
      }
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      insuranceExpiryController.text =
          "${picked.day} ${monthName(picked.month)} ${picked.year}";
    }
  }

  String monthName(int month) {
    const list = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return list[month - 1];
  }

  Future<String?> _uploadFile(File file, String type) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': type,
      });
      final response = await apiService.postRequest(
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

  void submitDetails() async {
    isSubmitting.value = true;
    try {
      final vendorResponse = await apiService.getRequest('/vendors/me');
      if (vendorResponse.statusCode != 200 ||
          vendorResponse.body['success'] != true) {
        Get.snackbar(
          'Error',
          'Failed to fetch vendor details',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      final vendorId = vendorResponse.body['data']['_id']?? vendorResponse.body['data']['id'];

      // 1. Upload Files
      String? cdlUrl;
      if (cdlFile.value != null)
        cdlUrl = await _uploadFile(cdlFile.value!, 'shipping_details');

      String? insuranceUrl;
      if (insuranceFile.value != null)
        insuranceUrl = await _uploadFile(
          insuranceFile.value!,
          'shipping_details',
        );

      // 2. Build Payload
      // Merge with existing servicesData safely
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(
            vendorResponse.body['data']['servicesData'] ?? {},
          );
      final Map<String, dynamic> currentShipping =
          existingServicesData['shipping'] is Map
          ? Map<String, dynamic>.from(existingServicesData['shipping'])
          : <String, dynamic>{};
      final Map<String, dynamic> profileData =
          currentShipping['profileData'] is Map
          ? Map<String, dynamic>.from(currentShipping['profileData'])
          : <String, dynamic>{};

      profileData['pricing'] = {
        'inquiryPrice': inquiryPrice.value,
        'baseRate': baseRateController.text.replaceAll(',', ''),
        'loadedRate': loadedRateController.text.replaceAll(',', ''),
      };

      profileData['servicesOffered'] = selectedServices.toList();
      profileData['equipmentSummary'] = equipmentSummaryController.text;
      profileData['travelScope'] = travelScope.toList();
      profileData['rigTypes'] = rigTypes.toList();
      profileData['stallTypes'] = stallTypes.toList();
      profileData['stallType'] = stallTypes.toList();
      final systemConfig = Get.find<SystemConfigController>();
      final resolvedRegions = regionsCovered.map((name) {
        final r = systemConfig.regions.firstWhereOrNull(
            (r) => (r['region'] ?? r['label'] ?? r['name'] ?? '').toString() == name);
        return r != null ? r['_id'].toString() : name;
      }).toList();
      profileData['regionsCovered'] = resolvedRegions;
      profileData['operationType'] = operationType.value;
      profileData['hasCDL'] = hasCDL.value;
      if (cdlUrl != null) profileData['cdlFile'] = cdlUrl;
      if (insuranceUrl != null) profileData['insuranceFile'] = insuranceUrl;
      profileData['insuranceExpiry'] = insuranceExpiryController.text;
      profileData['cancellationPolicy'] = isCustomCancellation.value
          ? customCancellationController.text
          : cancellationPolicy.value;
      profileData['additionalNotes'] = additionalNotesController.text;

      profileData['experience'] = experienceDisplay.value;
      profileData['disciplines'] = disciplines.toList();
      profileData['horseLevels'] = horseLevels.toList();
      profileData['regionsCovered'] = resolvedRegions;

      currentShipping['profileData'] = profileData;

      existingServicesData['shipping'] = currentShipping;

      final body = {
        'servicesData': existingServicesData,
        'isProfileSetup': true,
      };

      // 3. API Call
      final response = await apiService.putRequest('/vendors/me', body);

      if (response.statusCode == 200 && response.body['success'] == true) {
        final dynamic rawMe = vendorResponse.body['data'];
        if (rawMe is Map) {
          final me = Map<String, dynamic>.from(rawMe);
          final vid = vendorMongoIdFromRoot(me);
          dynamic shippingRow;
          for (final s in (me['assignedServices'] ?? [])) {
            if (assignedServiceMatchesTab(s, 'Shipping')) {
              shippingRow = s;
              break;
            }
          }
          final syncBlock = existingServicesData['shipping'];
          if (vid != null && shippingRow != null && syncBlock is Map) {
            await syncVendorServiceDocuments(
              api: apiService,
              vendorMongoId: vid,
              assignedServiceRow: shippingRow,
              profileData: Map<String, dynamic>.from(syncBlock['profileData'] ?? {}),
              applicationData:
                  Map<String, dynamic>.from(syncBlock['applicationData'] ?? {}),
            );
          }
        }

        // Sync local state
        await Get.find<AuthController>().updateUserMetadata();

        if (editModeEnabled.value) {
          if (Get.isRegistered<GroomViewProfileController>()) {
            Get.find<GroomViewProfileController>().fetchProfile();
          }
          Get.back();
          Get.snackbar(
            'Success',
            'Shipping rates updated successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
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
            } else if (nextService == 'Farrier') {
              Get.off(
                () => const FarrierDetailsView(),
                arguments: {'remainingServices': nextRemaining},
              );
            } else if (nextService == 'Bodywork') {
              Get.off(
                () => const BodyworkDetailsView(),
                arguments: {'remainingServices': nextRemaining},
              );
            } else {
              Get.offAll(
                () => const ProfileCompletedView(
                  subtitle: 'Your shipping services are now live',
                  destinationWidget: GroomBottomNav(),
                ),
              );
            }
          } else {
            Get.offAll(
              () => const ProfileCompletedView(
                subtitle: 'Your shipping services are now live',
                destinationWidget: GroomBottomNav(),
              ),
            );
          }
        }
      } else {
        Get.snackbar(
          'Error',
          response.body['message'] ?? 'Failed to update details',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
