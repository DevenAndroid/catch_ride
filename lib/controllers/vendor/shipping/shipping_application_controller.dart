import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/vendor/vendor_application_submit_view.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/setup_groom_application_view.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_application_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_application_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_application_view.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_application_view.dart';

class ShippingApplicationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.find<ApiService>();
  final authController = Get.find<AuthController>();

  // ── Controllers ─────────────────────────────────────────────────────────────
  final fullNameController = TextEditingController();
  final bioController = TextEditingController();
  final legalNameController = TextEditingController();
  final dotNumberController = TextEditingController();
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  
  // Locations
  final countryController = TextEditingController(text: 'USA');
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final Rxn<Map<String, dynamic>> selectedState = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> selectedCity = Rxn<Map<String, dynamic>>();
  final RxList<Map<String, dynamic>> states = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> cities = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingStates = false.obs;
  final RxBool isLoadingCities = false.obs;
  final selectedCountryCode = 'US'.obs;
  final countries = [
    {'name': 'USA', 'code': 'US'},
    {'name': 'Canada', 'code': 'CA'},
  ];

  // ── Selections ──────────────────────────────────────────────────────────────
  final RxnString experience = RxnString();
  final RxnString operationType = RxnString();
  final RxList<String> selectedTravelScope = <String>[].obs;
  final RxList<String> selectedRegions = <String>[].obs;
  final RxList<String> selectedRigTypes = <String>[].obs;
  final RxList<String> selectedStallTypes = <String>[].obs;
  final RxInt rigCapacity = 2.obs;
  
  // Experience Highlights
  final RxList<TextEditingController> highlightsControllers = <TextEditingController>[
    TextEditingController(),
  ].obs;

  // ── File & Image Uploads ────────────────────────────────────────────────────
  final Rxn<File> dotCopy = Rxn<File>();
  final Rxn<File> insuranceFile = Rxn<File>();
  final Rxn<File> licensePhoto = Rxn<File>();
  final RxList<File> rigPhotos = <File>[].obs;

  // Checkboxes
  final RxBool confirmUSDOT = false.obs;
  final RxBool confirmLicense = false.obs;
  final RxBool is18OrOlder = false.obs;
  final RxBool agreeTerms = false.obs;
  final RxBool agreeReferences = false.obs;
  final RxBool agreeCompliance = false.obs;
  final RxBool agreeVerification = false.obs;
  final RxBool isSubmitting = false.obs;

  // ── Options ────────────────────────────────────────────────────────────────
  final RxList<String> experienceOptions = <String>[].obs;
  final RxList<String> operationTypeOptions = <String>[].obs;
  final RxList<String> travelScopeOptions = <String>[].obs;
  final RxList<String> rigTypeOptions = <String>[].obs;
  final RxList<String> stallTypeOptions = <String>[].obs;
  final RxList<String> regionOptions = <String>[].obs;

  // ── References ─────────────────────────────────────────────────────────────
  final RxList<ReferenceController> referenceControllers = <ReferenceController>[
    ReferenceController(),
    ReferenceController(),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    final user = authController.currentUser.value;
    if (user != null) {
      fullNameController.text = user.fullName ?? '';
    }
    _fetchStates();
    fetchDynamicTags();
  }

  // ── Methods ────────────────────────────────────────────────────────────────

  Future<void> fetchDynamicTags() async {
    try {
      final response = await apiService.getRequest('/system-config/tag-types/with-values?category=Shipping');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List types = response.body['data'];
        
        for (var type in types) {
          final name = type['name'];
          final List<String> values = List<String>.from(type['values'].map((v) => v['name']));
          
          if (name == 'Hauling Experience') {
            experienceOptions.assignAll(values);
          } else if (name == 'Operation Type') {
            operationTypeOptions.assignAll(values);
          } else if (name == 'Travel Scope') {
            travelScopeOptions.assignAll(values);
          } else if (name == 'Rig Types') {
            rigTypeOptions.assignAll(values);
          } else if (name == 'Stall Type' || name == 'Stall Types') {
            stallTypeOptions.assignAll(values);
          } else if (name == 'Regions Covered') {
            regionOptions.assignAll(values);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching dynamic tags: $e');
    } finally {
      if (experienceOptions.isEmpty) {
        experienceOptions.assignAll(['0-1', '2-4', '5-9', '10+']);
      }
    }
  }

  void _fetchStates() async {
    isLoadingStates.value = true;
    try {
      final countryCode = selectedCountryCode.value;
      final res = await apiService.getRequest('/locations/states?countryCode=$countryCode');
      if (res.statusCode == 200 && res.body['success'] == true) {
        states.assignAll(List<Map<String, dynamic>>.from(res.body['data']));
      }
    } finally {
      isLoadingStates.value = false;
    }
  }

  void _fetchCities(String stateCode) async {
    isLoadingCities.value = true;
    try {
      final countryCode = selectedCountryCode.value;
      final res = await apiService.getRequest('/locations/states/$stateCode/cities?countryCode=$countryCode');
      if (res.statusCode == 200 && res.body['success'] == true) {
        cities.assignAll(List<Map<String, dynamic>>.from(res.body['data']));
      }
    } finally {
      isLoadingCities.value = false;
    }
  }

  void onStateSelected(Map<String, dynamic> state) {
    selectedState.value = state;
    stateController.text = state['name'] ?? '';
    selectedCity.value = null;
    cityController.clear();
    cities.clear();
    _fetchCities(state['isoCode']);
  }

  void onCountrySelected(Map<String, dynamic> country) {
    if (selectedCountryCode.value != country['code']) {
      selectedCountryCode.value = country['code'] ?? 'US';
      countryController.text = country['name'] ?? 'USA';
      
      // Reset state and city when country changes
      selectedState.value = null;
      selectedCity.value = null;
      stateController.clear();
      cityController.clear();
      states.clear();
      cities.clear();
      
      _fetchStates();
    }
  }

  void onCitySelected(Map<String, dynamic> city) {
    selectedCity.value = city;
    cityController.text = city['name'] ?? '';
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

  Future<void> pickRigPhotos() async {
    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      rigPhotos.addAll(images.map((img) => File(img.path)));
    }
  }

  void removeRigPhoto(int index) {
    rigPhotos.removeAt(index);
  }

  void addHighlight() {
    highlightsControllers.add(TextEditingController());
  }

  void removeHighlight(int index) {
    if (highlightsControllers.length > 1) {
      highlightsControllers[index].dispose();
      highlightsControllers.removeAt(index);
    } else {
      highlightsControllers[index].clear();
    }
  }

  Future<String?> _uploadFile(File file, String type) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': type,
      });
      // Assuming /upload is the shared upload endpoint
      final response = await apiService.postRequest('/upload?type=$type', formData);
      if (response.statusCode == 200 && response.body['success'] == true) {
        return response.body['data']['filename'];
      }
    } catch (e) {
      debugPrint('Error uploading $type: $e');
    }
    return null;
  }

  void submitApplication() async {
    if (!formKey.currentState!.validate()) return;
    if (!is18OrOlder.value || !agreeTerms.value || !agreeReferences.value || !agreeCompliance.value || !agreeVerification.value) {
      Get.snackbar('Error', 'Please agree to all terms before submitting.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      // 1. Upload Files
      String? dotUrl;
      if (dotCopy.value != null) dotUrl = await _uploadFile(dotCopy.value!, 'shipping_docs');
      
      String? insuranceUrl;
      if (insuranceFile.value != null) insuranceUrl = await _uploadFile(insuranceFile.value!, 'shipping_docs');
      
      String? licenseUrl;
      if (licensePhoto.value != null) licenseUrl = await _uploadFile(licensePhoto.value!, 'shipping_docs');
      
      List<String> rigPhotoUrls = [];
      for (var f in rigPhotos) {
        final url = await _uploadFile(f, 'shipping_rigs');
        if (url != null) rigPhotoUrls.add(url);
      }

      // 2. Build Payload
      final applicationData = {
        'fullName': fullNameController.text,
        'bio': bioController.text,
        'homeBase': {
          'country': countryController.text,
          'state': selectedState.value?['name'],
          'city': selectedCity.value?['name'],
        },
        'businessInfo': {
          'legalName': legalNameController.text,
          'dotNumber': dotNumberController.text,
        },
        'experience': experience.value,
        'operationType': operationType.value,
        'travelScope': selectedTravelScope.toList(),
        'regions': selectedRegions.toList(),
        'rigTypes': selectedRigTypes.toList(),
        'stallTypes': selectedStallTypes.toList(),
        'rigCapacity': rigCapacity.value,
        'highlights': highlightsControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
        'references': referenceControllers.map((r) => {
          'fullName': r.fullName.text,
          'relationship': r.relationship.text,
          'phone': r.phone.text,
        }).toList(),
        'media': {
          'dotCopy': dotUrl,
          'insurance': insuranceUrl,
          'licensePhoto': licenseUrl,
          'rigPhotos': rigPhotoUrls,
        },
        'socialMedia': {
          'facebook': facebookController.text,
          'instagram': instagramController.text,
        }
      };

      // 3. API Call
      final response = await apiService.postRequest('/vendors/setup-service', {
        'serviceType': 'Shipping',
        'applicationData': applicationData,
        'profileData': {
          'bio': bioController.text,
          'isProfileSetup': true,
        },
      });

      if (response.statusCode == 200 && response.body['success'] == true) {
        // Update local auth state
        await authController.updateUserMetadata();

        // Handle navigation to next service or success
        final args = Get.arguments as Map<String, dynamic>?;
        final remaining = args?['remainingServices'] as List<String>? ?? [];

        if (remaining.isNotEmpty) {
          final nextService = remaining.first;
          final nextRemaining = remaining.skip(1).toList();

          if (nextService == 'Grooming') {
            Get.to(() => const SetupGroomApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Braiding') {
            Get.to(() => const BraidingApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Clipping') {
            Get.to(() => const ClippingApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Farrier') {
            Get.to(() => const FarrierApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else if (nextService == 'Bodywork') {
            Get.to(() => const BodyworkApplicationView(), arguments: {'remainingServices': nextRemaining});
          } else {
            Get.to(() => const VendorApplicationSubmitView(), arguments: Get.arguments);
          }
        } else {
          Get.to(() => const VendorApplicationSubmitView(), arguments: Get.arguments);
        }
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to submit application', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    bioController.dispose();
    legalNameController.dispose();
    dotNumberController.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    for (var ctrl in highlightsControllers) {
      ctrl.dispose();
    }
    for (var ctrl in referenceControllers) {
      ctrl.dispose();
    }
    super.onClose();
  }
}

class ReferenceController {
  final fullName = TextEditingController();
  final relationship = TextEditingController();
  final phone = TextEditingController();

  void dispose() {
    fullName.dispose();
    relationship.dispose();
    phone.dispose();
  }
}
