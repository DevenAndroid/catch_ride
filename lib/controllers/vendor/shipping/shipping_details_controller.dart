import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final RxList<String> regionsCovered = <String>[].obs;
  final RxString operationType = 'Independent Small Operation'.obs;

  // ── Content ────────────────────────────────────────────────────────────────
  final equipmentSummaryController = TextEditingController();
  final additionalNotesController = TextEditingController();

  // ── Read-only displays (from profile) ──────────────────────────────────────
  final locationDisplay = "Denver, Colorado, USA".obs;
  final experienceDisplay = "4 years".obs;
  final usdotDisplay = "USDOT 1234567".obs;

  // ── Credentials & Insurance ────────────────────────────────────────────────
  final RxBool hasCDL = false.obs;
  final RxBool isCustomCancellation = false.obs;
  final customCancellationController = TextEditingController();
  final Rxn<File> cdlFile = Rxn<File>();
  final Rxn<File> insuranceFile = Rxn<File>();
  final RxnString currentCdlUrl = RxnString();
  final RxnString currentInsuranceUrl = RxnString();
  final insuranceExpiryController = TextEditingController();
  final cancellationPolicy = RxnString();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // ── Dynamic Options ────────────────────────────────────────────────────────
  final RxList<String> serviceOptions = <String>[].obs;
  final RxList<String> travelOptions = <String>[].obs;
  final RxList<String> rigOptions = <String>[].obs;
  final RxList<String> regionOptions = <String>[].obs;
  final List<String> cancellationOptions = [
    'Flexible (24+ hrs)',
    'Moderate (48+ hrs)',
    'Strict (72+ hrs)',
  ];

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
    if (appRegions.isNotEmpty) {
      regionOptions.assignAll(
        regionOptions.where((opt) => appRegions.contains(opt)).toList(),
      );
    }
  }

  Map<String, dynamic>? _shippingService;

  Future<void> fetchDynamicTags() async {
    try {
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
          } else if (name == 'Rig Types') {
            rigOptions.assignAll(values);
          } else if (name == 'Regions Covered') {
            regionOptions.assignAll(values);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching dynamic tags: $e');
    }
  }

  Future<void> fetchCurrentDetails({bool isInitializing = false}) async {
    if (!isInitializing) isLoading.value = true;
    try {
      final response = await apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final vendor = response.body['data'];
        final List assignedServices = vendor['assignedServices'] ?? [];
        final shippingService = assignedServices.firstWhereOrNull(
          (s) => s['serviceType'] == 'Shipping',
        );

        if (shippingService != null) {
          _shippingService = shippingService;
          final profileData = shippingService['profile']?['profileData'] ?? {};
          final applicationData =
              shippingService['application']?['applicationData'] ?? {};

          // Populate Pricing
          final pricing =
              profileData['pricing'] ?? applicationData['pricing'] ?? {};
          inquiryPrice.value = pricing['inquiryPrice'] ?? false;
          baseRateController.text =
              (pricing['baseRate'] ?? profileData['rates']?['baseRate'] ?? '')
                  .toString();
          loadedRateController.text =
              (pricing['loadedRate'] ??
                      profileData['rates']?['fullyLoaded'] ??
                      '')
                  .toString();

          // Populate Selections (Pre-fill from application if profile is empty)
          selectedServices.assignAll(
            List<String>.from(profileData['services'] ?? []),
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

          final List<String> appRegions = List<String>.from(
            applicationData['regions'] ?? [],
          );
          regionsCovered.assignAll(
            List<String>.from(profileData['regionsCovered'] ?? appRegions),
          );

          operationType.value =
              profileData['operationType'] ??
              applicationData['operationType'] ??
              'Independent Small Operation';

          // Note: Filtering is now handled in _applyApplicationFilters() called from _initializeData()

          // Populate Content
          equipmentSummaryController.text =
              profileData['equipmentSummary'] ?? '';
          additionalNotesController.text = profileData['additionalNotes'] ?? '';

          // Populate Read-only (from application)
          final city = applicationData['homeBase']?['city'] ?? '';
          final state = applicationData['homeBase']?['state'] ?? '';
          if (city.isNotEmpty && state.isNotEmpty) {
            locationDisplay.value = '$city, $state, USA';
          }
          if (applicationData['experience'] != null) {
            experienceDisplay.value = '${applicationData['experience']} years';
          }
          if (applicationData['businessInfo']?['dotNumber'] != null) {
            usdotDisplay.value =
                'USDOT ${applicationData['businessInfo']['dotNumber']}';
          }

          // Credentials
          hasCDL.value =
              profileData['hasCDL'] ??
              applicationData['confirmLicense'] ??
              false;

          // Documentation URLs from application media
          final appMedia = applicationData['media'] ?? {};
          currentCdlUrl.value =
              profileData['cdlFile'] ?? appMedia['licensePhoto'];
          currentInsuranceUrl.value =
              profileData['insuranceFile'] ??
              appMedia['insurance'] ??
              appMedia['dotCopy'];

          insuranceExpiryController.text = profileData['insuranceExpiry'] ?? '';
          final savedPolicy = profileData['cancellationPolicy'];
          if (savedPolicy != null) {
            if (cancellationOptions.contains(savedPolicy)) {
              cancellationPolicy.value = savedPolicy;
              isCustomCancellation.value = false;
            } else {
              isCustomCancellation.value = true;
              customCancellationController.text = savedPolicy;
              cancellationPolicy.value = null;
            }
          }
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
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      target.value = File(result.files.single.path!);
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
        'baseRate': baseRateController.text,
        'loadedRate': loadedRateController.text,
      };

      profileData['servicesOffered'] = selectedServices.toList();
      profileData['equipmentSummary'] = equipmentSummaryController.text;
      profileData['travelScope'] = travelScope.toList();
      profileData['rigTypes'] = rigTypes.toList();
      profileData['regionsCovered'] = regionsCovered.toList();
      profileData['operationType'] = operationType.value;
      profileData['hasCDL'] = hasCDL.value;
      if (cdlUrl != null) profileData['cdlFile'] = cdlUrl;
      if (insuranceUrl != null) profileData['insuranceFile'] = insuranceUrl;
      profileData['insuranceExpiry'] = insuranceExpiryController.text;
      profileData['cancellationPolicy'] = isCustomCancellation.value
          ? customCancellationController.text
          : cancellationPolicy.value;
      profileData['additionalNotes'] = additionalNotesController.text;

      currentShipping['profileData'] = profileData;
      currentShipping['isProfileCompleted'] = true;

      existingServicesData['shipping'] = currentShipping;

      final body = {
        'servicesData': existingServicesData,
        'isProfileSetup': true,
        'isProfileCompleted': true,
      };

      // 3. API Call
      final response = await apiService.putRequest('/vendors/$vendorId', body);

      if (response.statusCode == 200 && response.body['success'] == true) {
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
