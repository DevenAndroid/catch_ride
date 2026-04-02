import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

class GroomViewProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> vendorData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> groomingData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> applicationData = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> additionalServices = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> availabilityList = <Map<String, dynamic>>[].obs;
  final RxBool isAvailabilityLoading = false.obs;
  
  final RxList<String> paymentMethods = <String>[].obs;
  final RxList<String> disciplinesSelected = <String>[].obs;
  final RxList<String> horseLevels = <String>[].obs;
  final RxList<String> operatingRegions = <String>[].obs;
  final RxString locationStr = 'N/A'.obs;
  final RxString experienceStr = 'N/A'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getRequest('/vendors/me');

      if (response.statusCode == 200 && response.body['success'] == true) {
        final data = response.body['data'];
        vendorData.value = data;
        
        // Vendor level fields
        paymentMethods.assignAll(List<String>.from(data['paymentMethods'] ?? []));

        // Extract grooming specific data
        final List assignedServices = data['assignedServices'] ?? [];
        final groomingService = assignedServices.firstWhereOrNull(
          (s) => s['serviceType'] == 'Grooming',
        );

        if (groomingService != null) {
          // 1. Process Profile Data
          final profile = groomingService['profile'] ?? {};
          final profileDataMap = profile['profileData'] ?? {};
          groomingData.value = profileDataMap;

          final List services = profileDataMap['additionalServices'] ?? [];
          additionalServices.assignAll(services.cast<Map<String, dynamic>>());
          
          // 2. Process Application Data
          final application = groomingService['application'] ?? {};
          final appDataMap = application['applicationData'] ?? {};
          applicationData.value = appDataMap;
          
          // Map application fields
          final city = appDataMap['homeBase']?['city'] ?? '';
          final state = appDataMap['homeBase']?['state'] ?? '';
          locationStr.value = city.isNotEmpty && state.isNotEmpty ? '$city, $state, USA' : 'N/A';
          
          experienceStr.value = appDataMap['experience'] != null ? '${appDataMap['experience']} Years' : 'N/A';
          disciplinesSelected.assignAll(List<String>.from(appDataMap['disciplines'] ?? []));
          horseLevels.assignAll(List<String>.from(appDataMap['horseLevels'] ?? []));
          operatingRegions.assignAll(List<String>.from(appDataMap['regions'] ?? []));
        }

        // Fetch availability
        fetchAvailability(data['_id']);
      }
    } catch (e) {
      debugPrint('Error fetching grooming profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAvailability(String vendorId) async {
    try {
      isAvailabilityLoading.value = true;
      final response = await _apiService.getRequest('/availability/vendors/$vendorId');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List list = response.body['data'] ?? [];
        availabilityList.assignAll(list.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Error fetching availability: $e');
    } finally {
      isAvailabilityLoading.value = false;
    }
  }

  String get fullName => '${vendorData['firstName'] ?? ''} ${vendorData['lastName'] ?? ''}'.trim();
  String get businessNameDisplay => vendorData['businessName'] ?? 'N/A';
  String get bioDisplay => vendorData['bio'] ?? 'No bio provided.';
  String get profilePhoto {
    final vp = vendorData['profilePhoto']?.toString() ?? '';
    if (vp.isNotEmpty) return vp;
    // Fallback to user avatar if vendor photo is missing
    return Get.find<AuthController>().currentUser.value?.displayAvatar ?? '';
  }

  String get coverImage {
    final vc = vendorData['coverImage']?.toString() ?? '';
    if (vc.isNotEmpty) return vc;
    // Fallback to user cover if vendor cover is missing
    return Get.find<AuthController>().currentUser.value?.coverImage ?? '';
  }
  
  // Rates
  String get dailyRate => groomingData['rates']?['daily'] ?? 'N/A';
  String get weeklyRate => groomingData['rates']?['weekly']?['price'] ?? 'N/A';
  String get weeklyDays => groomingData['rates']?['weekly']?['days']?.toString() ?? '5';
  String get monthlyRate => groomingData['rates']?['monthly']?['price'] ?? 'N/A';
  String get monthlyDays => groomingData['rates']?['monthly']?['days']?.toString() ?? '5';

  // Capabilities
  List<String> get groomingServices => List<String>.from(groomingData['services'] ?? []);
  List<String> get supportOptions => List<String>.from(groomingData['capabilities']?['support'] ?? []);
  List<String> get handlingOptions => List<String>.from(groomingData['capabilities']?['handling'] ?? []);
  
  // Social Media
  String get instagramUrl => groomingData['socialMedia']?['instagram'] ?? '';
  String get facebookUrl => groomingData['socialMedia']?['facebook'] ?? '';
  
  // Travel & Policy
  List<String> get travelPreferences => List<String>.from(groomingData['travelPreferences'] ?? []);
  String get cancellationPolicy => groomingData['cancellationPolicy']?['policy'] ?? 'Flexible (24+ hrs)';
  
  // Experience Highlights
  List<String> get highlights => List<String>.from(vendorData['highlights'] ?? []);
  
  // Combined Media
  List<String> get allMedia => {
    ...List<String>.from(groomingData['media'] ?? []),
    ...List<String>.from(applicationData['media'] ?? []),
  }.toList();

  Future<bool> updateGroomingRates({
    required String daily,
    required String weekly,
    required String weeklyDays,
    required String monthly,
    required String monthlyDays,
    required List<Map<String, dynamic>> additional,
  }) async {
    try {
      isLoading.value = true;
      final vendorId = vendorData['_id'];
      
      final payload = {
        'servicesData': {
          'grooming': {
            'profileData': {
              'rates': {
                'daily': daily,
                'weekly': {'price': weekly, 'days': int.tryParse(weeklyDays) ?? 5},
                'monthly': {'price': monthly, 'days': int.tryParse(monthlyDays) ?? 5},
              },
              'additionalServices': additional,
            }
          }
        }
      };

      final response = await _apiService.putRequest('/vendors/$vendorId', payload);
      if (response.statusCode == 200) {
        await fetchProfile();
        Get.snackbar('Success', 'Rates updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to update rates', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      debugPrint('Update rates error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
