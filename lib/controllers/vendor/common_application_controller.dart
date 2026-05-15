import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_application_view.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_application_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_application_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_application_view.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/setup_groom_application_view.dart';
import 'package:catch_ride/view/vendor/shipping/create_profile/shipping_application_view.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/system_config_controller.dart';

class CommonApplicationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final apiService = Get.put(ApiService());

  // Form Fields
  final fullNameController = TextEditingController();
  final joinCommunityController = TextEditingController();

  // Location
  final countryController = TextEditingController(text: 'USA');
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final states = <Map<String, dynamic>>[].obs;
  final cities = <Map<String, dynamic>>[].obs;

  final selectedState = Rxn<Map<String, dynamic>>();
  final selectedCity = Rxn<Map<String, dynamic>>();
  final selectedCountryCode = 'US'.obs;
  final countries = [
    {'name': 'USA', 'code': 'US'},
    {'name': 'Canada', 'code': 'CA'},
  ].obs;

  final isLoadingStates = false.obs;
  final isLoadingCities = false.obs;

  // Professional References
  final ref1FullNameController = TextEditingController();
  final ref1BusinessNameController = TextEditingController();
  final ref1RelationshipController = TextEditingController();
  final ref1PhoneController = TextEditingController();

  final ref2FullNameController = TextEditingController();
  final ref2BusinessNameController = TextEditingController();
  final ref2RelationshipController = TextEditingController();
  final ref2PhoneController = TextEditingController();

  // Checkboxes
  final is18OrOlder = false.obs;
  final agreeToTerms = false.obs;
  final confirmReferences = false.obs;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.put(AuthController());
    fullNameController.text = authController.currentUser.value?.fullName ?? '';
    fetchStates();
  }

  Future<void> fetchStates() async {
    isLoadingStates.value = true;
    try {
      final countryCode = selectedCountryCode.value;
      final Response response = await apiService.getRequest('/locations/states?countryCode=$countryCode');
      if (response.statusCode == 200 && response.body['success'] == true) {
        states.value = List<Map<String, dynamic>>.from(response.body['data']);
      }
    } catch (e) {
      debugPrint('Error fetching states: $e');
    } finally {
      isLoadingStates.value = false;
    }
  }

  Future<void> fetchCities(String stateCode) async {
    isLoadingCities.value = true;
    selectedCity.value = null;
    cities.clear();
    try {
      final countryCode = selectedCountryCode.value;
      final Response response = await apiService.getRequest('/locations/states/$stateCode/cities?countryCode=$countryCode');
      if (response.statusCode == 200 && response.body['success'] == true) {
        cities.value = List<Map<String, dynamic>>.from(response.body['data']);
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
      
      selectedState.value = null;
      selectedCity.value = null;
      stateController.clear();
      cityController.clear();
      states.clear();
      cities.clear();
      
      fetchStates();
    }
  }

  void onStateSelected(Map<String, dynamic> state) {
    selectedState.value = state;
    stateController.text = state['name'] ?? '';
    cityController.clear();
    selectedCity.value = null;
    fetchCities(state['isoCode']);
  }

  void onCitySelected(Map<String, dynamic> city) {
    selectedCity.value = city;
    cityController.text = city['name'] ?? '';
  }

  void next() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (selectedState.value == null || selectedCity.value == null) {
      Get.snackbar('Missing Info', 'Please select your home base city and state', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (!is18OrOlder.value) {
      Get.snackbar('Age Verification', 'Please confirm that you are at least 18 years of age', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (!agreeToTerms.value) {
      Get.snackbar('Terms & Privacy', 'Please agree to the Terms of Service and Privacy Policy', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (!confirmReferences.value) {
      Get.snackbar('References', 'Please confirm that we may contact your professional references', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Navigation logic
    final List<String> remaining = Get.arguments?['remainingServices'] as List<String>? ?? [];
    if (remaining.isNotEmpty) {
      final nextService = remaining.first;
      final nextRemaining = remaining.skip(1).toList();
      
      // I'll need to define the navigation routes here similar to GroomApplicationController
      // Note: We are NOT using named routes in many places, so we use direct Widget navigation.
      
      if (nextService == 'Grooming') {
        Get.to(() => const SetupGroomApplicationView(), arguments: {'remainingServices': nextRemaining});
      } else if (nextService == 'Braiding') {
        Get.to(() => const BraidingApplicationView(), arguments: {'remainingServices': nextRemaining});
      } else if (nextService == 'Clipping') {
        Get.to(() => const ClippingApplicationView(), arguments: {'remainingServices': nextRemaining});
      } else if (nextService == 'Bodywork') {
        Get.to(() => const BodyworkApplicationView(), arguments: {'remainingServices': nextRemaining});
      } else if (nextService == 'Farrier') {
        Get.to(() => const FarrierApplicationView(), arguments: {'remainingServices': nextRemaining});
      } else if (nextService == 'Shipping') {
        Get.to(() => const ShippingApplicationView(), arguments: {'remainingServices': nextRemaining});
      } else {
        // Fallback or error
        Get.snackbar('Error', 'Invalid service selected', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
       Get.snackbar('Error', 'No services selected', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    joinCommunityController.dispose();
    ref1FullNameController.dispose();
    ref1BusinessNameController.dispose();
    ref1RelationshipController.dispose();
    ref1PhoneController.dispose();
    ref2FullNameController.dispose();
    ref2BusinessNameController.dispose();
    ref2RelationshipController.dispose();
    ref2PhoneController.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    super.onClose();
  }
}
