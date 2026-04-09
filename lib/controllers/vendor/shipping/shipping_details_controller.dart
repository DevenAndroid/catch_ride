import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/vendor/profile_completed_view.dart';
import 'package:catch_ride/controllers/auth_controller.dart';

class ShippingDetailsController extends GetxController {
  final apiService = Get.find<ApiService>();
  final formKey = GlobalKey<FormState>();

  // ── Pricing ────────────────────────────────────────────────────────────────
  final RxBool inquiryPrice = false.obs;
  final baseRateController = TextEditingController();
  final loadedRateController = TextEditingController();

  // ── Selections ──────────────────────────────────────────────────────────────
  final RxList<String> selectedServices = <String>[].obs;
  final RxList<String> travelScope = <String>[].obs;
  final RxList<String> rigTypes = <String>[].obs;
  final RxList<String> regionsCovered = <String>[].obs;
  final RxString operationType = 'Independent'.obs;

  // ── Content ────────────────────────────────────────────────────────────────
  final equipmentSummaryController = TextEditingController();
  final additionalNotesController = TextEditingController();

  // ── Read-only displays (from profile) ──────────────────────────────────────
  final locationDisplay = "Denver, Colorado, USA".obs;
  final experienceDisplay = "4 years".obs;
  final usdotDisplay = "USDOT 1234567".obs;

  // ── Credentials & Insurance ────────────────────────────────────────────────
  final RxBool hasCDL = false.obs;
  final Rxn<File> cdlFile = Rxn<File>();
  final Rxn<File> insuranceFile = Rxn<File>();
  final insuranceExpiryController = TextEditingController();
  final cancellationPolicy = RxnString();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // ── Options ────────────────────────────────────────────────────────────────
  final List<String> serviceOptions = [
    'Long-Distance Transport', 
    'GPS Tracking', 
    'Team Drivers', 
    'Climate-Controlled Equipment', 
    'Layover/Overnight Stops'
  ];
  final List<String> travelOptions = ['Local', 'Nationwide', 'Statewide', 'Regional (Northeast, Southeast)'];
  final List<String> rigOptions = ['Bumper pull', 'Gooseneck', 'Semi', 'Step-up'];
  final List<String> regionOptions = [
    'Florida (Wellington / Ocala / Gulf Coast)', 
    'Southwest (Thermal / AZ winter circuits)',
    'Southeast (Aiken / Tryon / Wills Park / Chatt Hills)'
  ];
  final List<String> cancellationOptions = ['Flexible', 'Moderate', 'Strict'];

  @override
  void onInit() {
    super.onInit();
    fetchCurrentDetails();
  }

  Future<void> fetchCurrentDetails() async {
    isLoading.value = true;
    try {
      // Logic to fetch existing vendor details if any
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      isLoading.value = false;
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
      insuranceExpiryController.text = "${picked.day} ${monthName(picked.month)} ${picked.year}";
    }
  }

  String monthName(int month) {
    const list = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return list[month - 1];
  }

  Future<String?> _uploadFile(File file, String type) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': type,
      });
      final response = await apiService.postRequest('/upload?type=$type', formData);
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
      // 1. Upload Files
      String? cdlUrl;
      if (cdlFile.value != null) cdlUrl = await _uploadFile(cdlFile.value!, 'shipping_details');
      
      String? insuranceUrl;
      if (insuranceFile.value != null) insuranceUrl = await _uploadFile(insuranceFile.value!, 'shipping_details');

      // 2. Build Payload
      final detailsData = {
        'pricing': {
          'inquiryPrice': inquiryPrice.value,
          'baseRate': baseRateController.text,
          'loadedRate': loadedRateController.text,
        },
        'services': selectedServices.toList(),
        'equipmentSummary': equipmentSummaryController.text,
        'travelScope': travelScope.toList(),
        'rigTypes': rigTypes.toList(),
        'regionsCovered': regionsCovered.toList(),
        'operationType': operationType.value,
        'hasCDL': hasCDL.value,
        'cdlFile': cdlUrl,
        'insuranceFile': insuranceUrl,
        'insuranceExpiry': insuranceExpiryController.text,
        'cancellationPolicy': cancellationPolicy.value,
        'additionalNotes': additionalNotesController.text,
      };

      // 3. API Call
      final response = await apiService.putRequest('/vendors/profile', {
        'shippingDetails': detailsData,
        'isProfileSetup': true,
      });

      if (response.statusCode == 200 && response.body['success'] == true) {
        // Sync local state
        await Get.find<AuthController>().updateUserMetadata();
        
        // Redirect to success
        Get.offAll(() => const ProfileCompletedView(subtitle: 'Your shipping services are now live',) );
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to update details', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }
}

