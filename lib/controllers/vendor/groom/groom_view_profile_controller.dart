// Groom View Profile Controller - Multi-service support (Grooming, Bodywork, Farrier, Shipping)
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
  final RxList<String> travelScopeList = <String>[].obs;
  final RxString locationStr = 'N/A'.obs;
  final RxString experienceStr = 'N/A'.obs;

  dynamic get _activeService => allAssignedServices.isNotEmpty 
      ? allAssignedServices[currentServiceIndex.value >= allAssignedServices.length ? 0 : currentServiceIndex.value] 
      : null;
      
  Map<String, dynamic> get _activeProfileData => _activeService?['profile']?['profileData'] ?? {};
  Map<String, dynamic> get _activeApplicationData => _activeService?['application']?['applicationData'] ?? {};

  Map<String, dynamic> get activeServiceProfile => _activeService?['profile'] ?? {};
  Map<String, dynamic> get activeServiceApplication => _activeService?['application'] ?? {};

  // Core Properties
  String get fullName => '${vendorData['firstName'] ?? ''} ${vendorData['lastName'] ?? ''}'.trim();
  String get businessNameDisplay => vendorData['businessName'] ?? 'N/A';
  String get bioDisplay => vendorData['bio'] ?? 'No bio provided.';
  String get activeServiceType => _activeService?['serviceType'] ?? 'N/A';

  // Shipping Getters
  String get shippingBaseRate => (_activeProfileData['pricing']?['baseRate'] ?? _activeProfileData['rates']?['baseRate'] ?? _activeProfileData['rates']?['base'] ?? 'N/A').toString();
  String get shippingLoadedRate => (_activeProfileData['pricing']?['loadedRate'] ?? _activeProfileData['rates']?['fullyLoaded'] ?? _activeProfileData['rates']?['loaded'] ?? 'N/A').toString();
  String get shippingOperationType => _activeProfileData['operationType'] ?? _activeApplicationData['operationType'] ?? 'N/A';
  List<String> get shippingRigTypes => List<String>.from(_activeProfileData['rigTypes'] ?? _activeApplicationData['rigTypes'] ?? []);
  String get shippingRigCapacity => (_activeProfileData['rigCapacity'] ?? _activeApplicationData['rigCapacity'] ?? 'N/A').toString();
  String get shippingEquipmentSummary => _activeProfileData['equipmentSummary'] ?? _activeProfileData['equipmentsSummary'] ?? 'N/A';
  String get shippingEquipmentsSummary => shippingEquipmentSummary;
  List<String> get shippingServicesOffered => List<String>.from(_activeProfileData['services'] ?? _activeProfileData['servicesOffered'] ?? []);
  List<String> get shippingRegionsCovered => List<String>.from(_activeProfileData['regionsCovered'] ?? _activeApplicationData['regions'] ?? []);
  List<String> get shippingTravelScope => List<String>.from(_activeProfileData['travelScope'] ?? _activeApplicationData['travelScope'] ?? []);
  List<String> get travelScope => shippingTravelScope;

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
        paymentMethods.assignAll(List<String>.from(data['paymentMethods'] ?? []));
        final List assignedServices = data['assignedServices'] ?? [];
        allAssignedServices.assignAll(assignedServices);
        _updateActiveServiceData();
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
    final profile = activeService['profile'] ?? {};
    final profileDataMap = profile['profileData'] ?? {};
    final List addServices = profileDataMap['additionalServices'] ?? [];
    additionalServices.assignAll(addServices.cast<Map<String, dynamic>>());
    final List bwServices = profileDataMap['services'] ?? profileDataMap['additionalServices'] ?? [];
    bodyworkServices.assignAll(bwServices.cast<Map<String, dynamic>>());
    final application = activeService['application'] ?? {};
    final appDataMap = application['applicationData'] ?? {};
    final city = appDataMap['homeBase']?['city'] ?? appDataMap['location']?['city'] ?? '';
    final state = appDataMap['homeBase']?['state'] ?? appDataMap['location']?['state'] ?? '';
    locationStr.value = city.isNotEmpty && state.isNotEmpty ? '$city, $state, USA' : 'N/A';
    experienceStr.value = appDataMap['experience'] != null ? '${appDataMap['experience']} Years' : 'N/A';
    disciplinesSelected.assignAll(List<String>.from(appDataMap['disciplines'] ?? []));
    horseLevels.assignAll(List<String>.from(appDataMap['horseLevels'] ?? []));
    operatingRegions.assignAll(List<String>.from(appDataMap['regions'] ?? []));
    travelScopeList.assignAll(List<String>.from(appDataMap['travelScope'] ?? []));
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

  String get profilePhoto {
    final vp = vendorData['profilePhoto']?.toString() ?? '';
    if (vp.isNotEmpty) return vp;
    return Get.find<AuthController>().currentUser.value?.displayAvatar ?? '';
  }

  String get coverImage {
    final vc = vendorData['coverImage']?.toString() ?? '';
    if (vc.isNotEmpty) return vc;
    return Get.find<AuthController>().currentUser.value?.coverImage ?? '';
  }
  
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
    ..._extractMedia(_activeProfileData['media']),
    ..._extractMedia(_activeApplicationData['media']),
    ..._extractMedia(_activeApplicationData['rigPhotos']), 
    ..._extractMedia(_activeApplicationData['photos']),
  }.toList();

  List<String> _extractMedia(dynamic source) {
    if (source == null) return [];
    if (source is List) return List<String>.from(source.where((e) => e != null));
    if (source is Map) {
      final List<String> results = [];
      source.forEach((key, value) {
        if (value is String && value.isNotEmpty) {
          results.add(value);
        } else if (value is List) {
          results.addAll(List<String>.from(value.where((e) => e != null)));
        }
      });
      return results;
    }
    return [];
  }
  
  // Farrier Getters
  List<dynamic> get farrierServices => List<dynamic>.from(_activeProfileData['services'] ?? []);
  List<dynamic> get farrierAddOns => List<dynamic>.from(_activeProfileData['addOns'] ?? []);
  List<String> get farrierScopeOfWork => List<String>.from(_activeApplicationData['scopeOfWork'] ?? []);
  List<String> get farrierDisciplines => List<String>.from(_activeApplicationData['disciplines'] ?? []);
  List<String> get farrierHorseLevels => List<String>.from(_activeApplicationData['horseLevels'] ?? []);
  List<String> get farrierRegionsCovered => List<String>.from(_activeApplicationData['regions'] ?? []);

  Future<bool> updateBraidingServices(List<Map<String, dynamic>> services) async {
    try {
      isLoading.value = true;
      final vendorId = vendorData['_id'];
      final payload = {
        'servicesData': {
          'braiding': { 
            'profileData': { 'services': services },
            'isProfileCompleted': true,
          }
        }
      };
      final response = await _apiService.putRequest('/vendors/$vendorId', payload);
      if (response.statusCode == 200) {
        await fetchProfile();
        Get.snackbar('Success', 'Braiding services updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateClippingServices(List<Map<String, dynamic>> services) async {
    try {
      isLoading.value = true;
      final vendorId = vendorData['_id'];
      final payload = {
        'servicesData': {
          'clipping': { 
            'profileData': { 'services': services },
            'isProfileCompleted': true,
          }
        }
      };
      final response = await _apiService.putRequest('/vendors/$vendorId', payload);
      if (response.statusCode == 200) {
        await fetchProfile();
        Get.snackbar('Success', 'Clipping services updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      }
      return false;
    } catch (e) {
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
            'profileData': { 'services': services, 'addOns': addOns },
            'isProfileCompleted': true,
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
            'profileData': { 'services': services },
            'isProfileCompleted': true,
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
            },
            'isProfileCompleted': true,
          }
        }
      };
      final response = await _apiService.putRequest('/vendors/$vendorId', payload);
      if (response.statusCode == 200) {
        await fetchProfile();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
