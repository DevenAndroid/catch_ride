import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:get/get.dart';

class GroomViewProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> vendorData = <String, dynamic>{}.obs;
  
  // Multi-service support
  final RxList<dynamic> allAssignedServices = <dynamic>[].obs;
  final RxInt currentServiceIndex = 0.obs;

  final RxList<Map<String, dynamic>> bodyworkServices = <Map<String, dynamic>>[].obs;

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

        // Extract all assigned services
        final List assignedServices = data['assignedServices'] ?? [];
        allAssignedServices.assignAll(assignedServices);

        // Update active data based on current index
        _updateActiveServiceData();
        
        // Fetch availability
        fetchAvailability(data['_id']);
      }
    } catch (e) {
      debugPrint('Error fetching vendor profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateActiveServiceData() {
    if (allAssignedServices.isEmpty) return;
    
    final currentIndex = currentServiceIndex.value >= allAssignedServices.length ? 0 : currentServiceIndex.value;
    final activeService = allAssignedServices[currentIndex];

    // 1. Process Profile Data
    final profile = activeService['profile'] ?? {};
    final profileDataMap = profile['profileData'] ?? {};
    
    final List addServices = profileDataMap['additionalServices'] ?? [];
    additionalServices.assignAll(addServices.cast<Map<String, dynamic>>());

    final List bwServices = profileDataMap['services'] ?? profileDataMap['additionalServices'] ?? [];
    bodyworkServices.assignAll(bwServices.cast<Map<String, dynamic>>());
    
    // 2. Process Application Data
    final application = activeService['application'] ?? {};
    final appDataMap = application['applicationData'] ?? {};
    
    // Map application fields
    final city = appDataMap['homeBase']?['city'] ?? appDataMap['location']?['city'] ?? '';
    final state = appDataMap['homeBase']?['state'] ?? appDataMap['location']?['state'] ?? '';
    locationStr.value = city.isNotEmpty && state.isNotEmpty ? '$city, $state, USA' : 'N/A';
    
    experienceStr.value = appDataMap['experience'] != null ? '${appDataMap['experience']} Years' : 'N/A';
    disciplinesSelected.assignAll(List<String>.from(appDataMap['disciplines'] ?? []));
    horseLevels.assignAll(List<String>.from(appDataMap['horseLevels'] ?? []));
    operatingRegions.assignAll(List<String>.from(appDataMap['regions'] ?? []));
  }

  void selectService(int index) {
    if (index >= 0 && index < allAssignedServices.length) {
      currentServiceIndex.value = index;
      _updateActiveServiceData();
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
  
  // Active Service Getters
  dynamic get _activeService => allAssignedServices.isNotEmpty 
      ? allAssignedServices[currentServiceIndex.value >= allAssignedServices.length ? 0 : currentServiceIndex.value] 
      : null;
      
  Map<String, dynamic> get _activeProfileData => _activeService?['profile']?['profileData'] ?? {};
  Map<String, dynamic> get _activeApplicationData => _activeService?['application']?['applicationData'] ?? {};

  String get activeServiceType => _activeService?['serviceType'] ?? 'N/A';

  // Rates
  String get dailyRate => _activeProfileData['rates']?['daily'] ?? 'N/A';
  String get weeklyRate => _activeProfileData['rates']?['weekly']?['price'] ?? 'N/A';
  String get weeklyDays => _activeProfileData['rates']?['weekly']?['days']?.toString() ?? '5';
  String get monthlyRate => _activeProfileData['rates']?['monthly']?['price'] ?? 'N/A';
  String get monthlyDays => _activeProfileData['rates']?['monthly']?['days']?.toString() ?? '5';

  // Capabilities
  List<dynamic> get groomingServices => List<dynamic>.from(_activeProfileData['services'] ?? []);
  List<String> get supportOptions => List<String>.from(_activeProfileData['capabilities']?['support'] ?? []);
  List<String> get handlingOptions => List<String>.from(_activeProfileData['capabilities']?['handling'] ?? []);
  
  // Social Media
  String get instagramUrl => _activeProfileData['socialMedia']?['instagram'] ?? '';
  String get facebookUrl => _activeProfileData['socialMedia']?['facebook'] ?? '';
  
  // Travel & Policy
  List<String> get travelPreferences {
    final raw = _activeProfileData['travelPreferences'] ?? [];
    if (raw is! List) return [];
    return raw.map((item) {
      if (item is Map) return item['region']?.toString() ?? item['name']?.toString() ?? '';
      return item.toString();
    }).where((s) => s.isNotEmpty).toList();
  }
  String get cancellationPolicy => _activeProfileData['cancellationPolicy']?['policy'] ?? 'Flexible (24+ hrs)';
  
  // Experience Highlights
  List<String> get highlights => List<String>.from(vendorData['highlights'] ?? []);
  
  // Combined Media
  List<String> get allMedia => {
    ...List<String>.from(_activeProfileData['media'] ?? []),
    ...List<String>.from(_activeApplicationData['media'] ?? []),
  }.toList();
  
  // Farrier Getters
  List<dynamic> get farrierServices => List<dynamic>.from(_activeProfileData['services'] ?? []);
  List<dynamic> get farrierAddOns => List<dynamic>.from(_activeProfileData['addOns'] ?? []);
  List<String> get farrierScopeOfWork => List<String>.from(_activeApplicationData['scopeOfWork'] ?? []);
  List<String> get farrierTravelPreferences => List<String>.from((_activeProfileData['travelPreferences'] as List? ?? []).map((t) => (t as Map)['category']?.toString() ?? '').where((s) => s.isNotEmpty));
  List<String> get farrierDisciplines => List<String>.from(_activeApplicationData['disciplines'] ?? []);
  List<String> get farrierHorseLevels => List<String>.from(_activeApplicationData['horseLevels'] ?? []);
  List<String> get farrierRegionsCovered => List<String>.from(_activeApplicationData['regions'] ?? []);

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

  Future<bool> updateBraidingServices(List<Map<String, dynamic>> services) async {
    try {
      isLoading.value = true;
      final vendorId = vendorData['_id'];
      
      final payload = {
        'servicesData': {
          'braiding': {
            'profileData': {
              'services': services,
            }
          }
        }
      };

      final response = await _apiService.putRequest('/vendors/$vendorId', payload);
      if (response.statusCode == 200) {
        await fetchProfile();
        Get.snackbar('Success', 'Braiding services updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to update services', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      debugPrint('Update braiding services error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateFarrierServices({
    required List<Map<String, dynamic>> services,
    required List<Map<String, dynamic>> addOns,
  }) async {
    try {
      isLoading.value = true;
      final vendorId = vendorData['_id'];
      
      final payload = {
        'servicesData': {
          'farrier': {
            'profileData': {
              'services': services,
              'addOns': addOns,
            }
          }
        }
      };

      final response = await _apiService.putRequest('/vendors/$vendorId', payload);
      if (response.statusCode == 200) {
        await fetchProfile();
        Get.snackbar('Success', 'Farrier services updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to update farrier services', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      debugPrint('Update farrier services error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateBodyworkServices({
    required List<Map<String, dynamic>> services,
  }) async {
    try {
      isLoading.value = true;
      final vendorId = vendorData['_id'];

      final payload = {
        'servicesData': {
          'bodywork': {
            'profileData': {
              'services': services,
            }
          }
        }
      };

      final response = await _apiService.putRequest('/vendors/$vendorId', payload);
      if (response.statusCode == 200) {
        await fetchProfile();
        Get.snackbar('Success', 'Bodywork services updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to update bodywork services', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      debugPrint('Update bodywork services error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
