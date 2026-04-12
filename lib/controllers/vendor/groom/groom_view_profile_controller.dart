// Groom View Profile Controller - Multi-service support (Grooming, Bodywork, Farrier, Shipping)
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:get/get.dart';

class GroomViewProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> vendorData = <String, dynamic>{}.obs;

  // Multi-service support
  final RxList<dynamic> allAssignedServices = <dynamic>[].obs;
  final RxInt currentServiceIndex = 0.obs;

  final RxList<Map<String, dynamic>> bodyworkServices =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> additionalServices =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> availabilityList =
      <Map<String, dynamic>>[].obs;
  final RxBool isAvailabilityLoading = false.obs;

  final RxList<String> paymentMethods = <String>[].obs;
  final RxList<String> disciplinesSelected = <String>[].obs;
  final RxList<String> horseLevels = <String>[].obs;
  final RxList<String> operatingRegions = <String>[].obs;
  final RxList<String> travelScopeList = <String>[].obs;
  final RxString locationStr = 'N/A'.obs;
  final RxString experienceStr = 'N/A'.obs;

  dynamic get _activeService => allAssignedServices.isNotEmpty
      ? allAssignedServices[currentServiceIndex.value >=
                allAssignedServices.length
            ? 0
            : currentServiceIndex.value]
      : null;

  Map<String, dynamic> get _activeProfileData =>
      _activeService?['profile']?['profileData'] ?? {};
  Map<String, dynamic> get _activeApplicationData =>
      _activeService?['application']?['applicationData'] ?? {};

  Map<String, dynamic> get activeServiceProfile =>
      _activeService?['profile'] ?? {};
  Map<String, dynamic> get activeServiceApplication =>
      _activeService?['application'] ?? {};

  // Core Properties
  String get fullName =>
      '${vendorData['firstName'] ?? ''} ${vendorData['lastName'] ?? ''}'.trim();
  String get businessNameDisplay => vendorData['businessName'] ?? 'N/A';
  String get bioDisplay => vendorData['bio'] ?? 'No bio provided.';
  String get activeServiceType => _activeService?['serviceType'] ?? 'N/A';

  // Shipping Getters
  String get shippingBaseRate =>
      (_activeProfileData['pricing']?['baseRate'] ??
              _activeProfileData['rates']?['baseRate'] ??
              _activeProfileData['rates']?['base'] ??
              'N/A')
          .toString();
  String get shippingLoadedRate =>
      (_activeProfileData['pricing']?['loadedRate'] ??
              _activeProfileData['rates']?['fullyLoaded'] ??
              _activeProfileData['rates']?['loaded'] ??
              'N/A')
          .toString();
  String get shippingOperationType =>
      _activeProfileData['operationType'] ??
      _activeApplicationData['operationType'] ??
      'N/A';
  List<String> get shippingRigTypes => List<String>.from(
    _activeProfileData['rigTypes'] ?? _activeApplicationData['rigTypes'] ?? [],
  );
  String get shippingRigCapacity =>
      (_activeProfileData['rigCapacity'] ??
              _activeApplicationData['rigCapacity'] ??
              'N/A')
          .toString();
  String get shippingEquipmentSummary =>
      _activeProfileData['equipmentSummary'] ??
      _activeProfileData['equipmentsSummary'] ??
      'N/A';
  String get shippingEquipmentsSummary => shippingEquipmentSummary;
  List<String> get shippingServicesOffered => List<String>.from(
    _activeProfileData['services'] ??
        _activeProfileData['servicesOffered'] ??
        [],
  );
  List<String> get shippingRegionsCovered => List<String>.from(
    _activeProfileData['regionsCovered'] ??
        _activeApplicationData['regions'] ??
        [],
  );
  List<String> get shippingTravelScope => List<String>.from(
    _activeProfileData['travelScope'] ??
        _activeApplicationData['travelScope'] ??
        [],
  );
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
        paymentMethods.assignAll(
          List<String>.from(data['paymentMethods'] ?? []),
        );
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
    final currentIndex = currentServiceIndex.value >= allAssignedServices.length
        ? 0
        : currentServiceIndex.value;
    final activeService = allAssignedServices[currentIndex];
    final profile = activeService['profile'] ?? {};
    final profileDataMap = profile['profileData'] ?? {};
    // Update Additional Services
    final List addServices = profileDataMap['additionalServices'] ?? [];
    additionalServices.assignAll(addServices.map((s) {
      if (s is Map) return s.cast<String, dynamic>();
      return {'name': s.toString(), 'price': '0'};
    }).toList());

    // Update Bodywork Services (if applicable)
    final List bwServices =
        profileDataMap['services'] ??
        profileDataMap['additionalServices'] ??
        [];
    bodyworkServices.assignAll(bwServices.map((s) {
      if (s is Map) return s.cast<String, dynamic>();
      return {'name': s.toString(), 'price': '0', 'isSelected': true};
    }).toList());

    final application = activeService['application'] ?? {};
    final appDataMap = application['applicationData'] ?? application ?? {};

    _updateLocationAndExperience(appDataMap, activeService);
    _updateTags(appDataMap);
    travelScopeList.assignAll(
      List<String>.from(appDataMap['travelScope'] ?? []),
    );
  }

  void _updateTags(Map appData) {
    // 1. Try Service Application Data
    final List<String> d = List<String>.from(appData['disciplines'] ?? []);
    final List<String> h = List<String>.from(appData['horseLevels'] ?? []);
    final List<String> r = List<String>.from(appData['regions'] ?? []);

    if (d.isNotEmpty) {
      disciplinesSelected.assignAll(d);
    } else {
      // Fallback: Vendor Level or AuthController
      final vendorDisciplines = List<String>.from(
        vendorData['disciplines'] ?? [],
      );
      if (vendorDisciplines.isNotEmpty) {
        disciplinesSelected.assignAll(vendorDisciplines);
      } else {
        final profileController = Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : null;
        if (profileController != null) {
          disciplinesSelected.assignAll(profileController.disciplines);
        }
      }
    }

    if (h.isNotEmpty) {
      horseLevels.assignAll(h);
    } else {
      horseLevels.assignAll(List<String>.from(vendorData['horseLevels'] ?? []));
    }

    if (r.isNotEmpty) {
      operatingRegions.assignAll(r);
    } else {
      operatingRegions.assignAll(
        List<String>.from(vendorData['regions'] ?? []),
      );
    }
  }

  void _updateLocationAndExperience(Map appData, dynamic activeService) {
    // 1. Try Current Service Application Data
    String? city = appData['homeBase']?['city'] ?? appData['city'];
    String? state = appData['homeBase']?['state'] ?? appData['state'];
    String? country = appData['homeBase']?['country'] ?? appData['country'];

    if (!_isValid(city) || !_isValid(state)) {
      // Try one level up if applicationData was flat
      final topAppData = activeService['application'] ?? {};
      city ??= topAppData['homeBase']?['city'] ?? topAppData['city'];
      state ??= topAppData['homeBase']?['state'] ?? topAppData['state'];
      country ??= topAppData['homeBase']?['country'] ?? topAppData['country'];
    }

    // Build location string with available components
    if (_isValid(city) || _isValid(state) || _isValid(country)) {
      List<String> locationParts = [];
      if (_isValid(city)) locationParts.add(city!);
      if (_isValid(state)) locationParts.add(state!);
      if (_isValid(country)) locationParts.add(country!);

      // If no country found, don't hardcode USA - just use what we have
      if (locationParts.isNotEmpty) {
        locationStr.value = locationParts.join(', ');
      }
    } else {
      // 2. Deep search across ALL services
      for (var service in allAssignedServices) {
        final serviceApp = service['application'] ?? {};
        final sData = serviceApp['applicationData'] ?? serviceApp ?? {};
        final sCity = sData['homeBase']?['city'] ?? sData['city'];
        final sState = sData['homeBase']?['state'] ?? sData['state'];
        final sCountry = sData['homeBase']?['country'] ?? sData['country'];

        if (_isValid(sCity) || _isValid(sState) || _isValid(sCountry)) {
          List<String> locationParts = [];
          if (_isValid(sCity)) locationParts.add(sCity!);
          if (_isValid(sState)) locationParts.add(sState!);
          if (_isValid(sCountry)) locationParts.add(sCountry!);

          locationStr.value = locationParts.join(', ');
          break;
        }
      }

      if (!_isValid(locationStr.value) || locationStr.value.isEmpty) {
        // 3. Try Vendor Level
        final dynamic loc = vendorData['location'] ?? vendorData['homeBase'];
        if (loc is Map) {
          city = loc['city']?.toString();
          state = loc['state']?.toString();
          country = loc['country']?.toString();
        } else if (loc is String && loc.isNotEmpty) {
          locationStr.value = loc;
        } else {
          city = vendorData['city']?.toString();
          state = vendorData['state']?.toString();
          country = vendorData['country']?.toString();
        }

        if (_isValid(city) || _isValid(state) || _isValid(country)) {
          List<String> locationParts = [];
          if (_isValid(city)) locationParts.add(city!);
          if (_isValid(state)) locationParts.add(state!);
          if (_isValid(country)) locationParts.add(country!);

          if (locationParts.isNotEmpty) {
            locationStr.value = locationParts.join(', ');
          }
        } else if (locationStr.value == 'N/A' || locationStr.value.isEmpty) {
          // 4. Try AuthController User
          final user = Get.find<AuthController>().currentUser.value;
          if (user?.location != null && user!.location!.isNotEmpty) {
            locationStr.value = user.location!;
          } else {
            locationStr.value = 'N/A';
          }
        }
      }
    }

    // Experience Deep Search
    dynamic exp = appData['experience'] ?? appData['yearsExperience'];

    if (!_isValid(exp)) {
      final topAppData = activeService['application'] ?? {};
      exp = topAppData['experience'] ?? topAppData['yearsExperience'];
    }

    if (!_isValid(exp)) {
      for (var service in allAssignedServices) {
        final serviceApp = service['application'] ?? {};
        final sData = serviceApp['applicationData'] ?? serviceApp ?? {};
        final sExp = sData['experience'] ?? sData['yearsExperience'];
        if (_isValid(sExp)) {
          exp = sExp;
          break;
        }
      }
    }

    if (!_isValid(exp)) {
      exp =
          vendorData['yearsExperience'] ??
          vendorData['experience'] ??
          vendorData['yearsOfExperience'] ??
          vendorData['yearsInIndustry'] ??
          Get.find<AuthController>().currentUser.value?.yearsExperience;
    }

    if (_isValid(exp) && exp.toString() != '0') {
      String val = exp.toString();
      experienceStr.value = val.toLowerCase().contains('year')
          ? val
          : '$val Years';
    } else {
      experienceStr.value = 'N/A';
    }
  }

  bool _isValid(dynamic value) {
    if (value == null) return false;
    if (value is String && (value.isEmpty || value.toLowerCase() == 'n/a'))
      return false;
    return true;
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
      final response = await _apiService.getRequest(
        '/availability/vendors/$vendorId',
      );
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
  String get weeklyRate =>
      _activeProfileData['rates']?['weekly']?['price'] ?? 'N/A';
  String get weeklyDays =>
      _activeProfileData['rates']?['weekly']?['days']?.toString() ?? '5';
  String get monthlyRate =>
      _activeProfileData['rates']?['monthly']?['price'] ?? 'N/A';
  String get monthlyDays =>
      _activeProfileData['rates']?['monthly']?['days']?.toString() ?? '5';

  // Capabilities
  List<dynamic> get groomingServices =>
      List<dynamic>.from(_activeProfileData['services'] ?? []);
  List<String> get supportOptions =>
      List<String>.from(_activeProfileData['capabilities']?['support'] ?? []);
  List<String> get handlingOptions =>
      List<String>.from(_activeProfileData['capabilities']?['handling'] ?? []);

  // Social Media
  String get instagramUrl =>
      _activeProfileData['socialMedia']?['instagram'] ?? '';
  String get facebookUrl =>
      _activeProfileData['socialMedia']?['facebook'] ?? '';

  // Travel & Policy
  List<String> get travelPreferences {
    final raw = _activeProfileData['travelPreferences'] ?? [];
    if (raw is! List) return [];
    return raw
        .map((item) {
          if (item is Map)
            return item['region']?.toString() ?? item['name']?.toString() ?? '';
          return item.toString();
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String get cancellationPolicy {
    final raw = _activeProfileData['cancellationPolicy'];
    if (raw is Map) {
      return raw['policy']?.toString() ?? 'Flexible (24+ hrs)';
    }
    if (raw is String && raw.isNotEmpty) {
      return raw;
    }
    return 'Flexible (24+ hrs)';
  }

  // Experience Highlights
  List<String> get highlights {
    final List<String> vh = List<String>.from(vendorData['highlights'] ?? []);
    if (vh.isNotEmpty) return vh;

    final List<String> ah = List<String>.from(
      _activeApplicationData['highlights'] ??
          _activeApplicationData['additionalSkills'] ??
          [],
    );
    if (ah.isNotEmpty) return ah;

    final List<String> ph = List<String>.from(
      _activeProfileData['highlights'] ??
          _activeProfileData['additionalSkills'] ??
          [],
    );
    return ph;
  }

  // Combined Media
  List<String> get allMedia => {
    ..._extractMedia(_activeProfileData['media']),
    ..._extractMedia(_activeApplicationData['media']),
    ..._extractMedia(_activeApplicationData['rigPhotos']),
    ..._extractMedia(_activeApplicationData['photos']),
  }.toList();

  List<String> _extractMedia(dynamic source) {
    if (source == null) return [];
    if (source is List)
      return List<String>.from(source.where((e) => e != null));
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
  List<dynamic> get farrierServices =>
      List<dynamic>.from(_activeProfileData['services'] ?? []);
  List<dynamic> get farrierAddOns =>
      List<dynamic>.from(_activeProfileData['addOns'] ?? []);
  List<String> get farrierScopeOfWork =>
      List<String>.from(_activeApplicationData['scopeOfWork'] ?? []);
  List<String> get farrierDisciplines =>
      List<String>.from(_activeApplicationData['disciplines'] ?? []);
  List<String> get farrierHorseLevels =>
      List<String>.from(_activeApplicationData['horseLevels'] ?? []);
  List<String> get farrierRegionsCovered =>
      List<String>.from(_activeApplicationData['regions'] ?? []);

  Future<bool> updateBraidingServices(
    List<Map<String, dynamic>> services,
  ) async {
    try {
      isLoading.value = true;
      final vendorId = vendorData['_id'];
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      existingServicesData['braiding'] = {
        'profileData': {'services': services},
        'isProfileCompleted': true,
      };

      final payload = {
        'servicesData': existingServicesData,
        'isProfileCompleted': true,
        'isProfileSetup': true,
      };
      final response = await _apiService.putRequest(
        '/vendors/$vendorId',
        payload,
      );
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

  Future<bool> updateClippingServices(
    List<Map<String, dynamic>> services,
  ) async {
    try {
      isLoading.value = true;
      final vendorId = vendorData['_id'];
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      existingServicesData['clipping'] = {
        'profileData': {'services': services},
        'isProfileCompleted': true,
      };

      final payload = {
        'servicesData': existingServicesData,
        'isProfileCompleted': true,
        'isProfileSetup': true,
      };
      final response = await _apiService.putRequest(
        '/vendors/$vendorId',
        payload,
      );
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

  Future<bool> updateFarrierServices({
    required List<Map<String, dynamic>> services,
    required List<Map<String, dynamic>> addOns,
  }) async {
    try {
      isLoading.value = true;
      final vendorId = vendorData['_id'];
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      existingServicesData['farrier'] = {
        'profileData': {'services': services, 'addOns': addOns},
        'isProfileCompleted': true,
      };

      final payload = {
        'servicesData': existingServicesData,
        'isProfileCompleted': true,
        'isProfileSetup': true,
      };
      final response = await _apiService.putRequest(
        '/vendors/$vendorId',
        payload,
      );
      if (response.statusCode == 200) {
        await fetchProfile();
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.body['message'] ?? 'Failed to update farrier services',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
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
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      existingServicesData['bodywork'] = {
        'profileData': {'services': services},
        'isProfileCompleted': true,
      };

      final payload = {
        'servicesData': existingServicesData,
        'isProfileCompleted': true,
        'isProfileSetup': true,
      };
      final response = await _apiService.putRequest(
        '/vendors/$vendorId',
        payload,
      );
      if (response.statusCode == 200) {
        await fetchProfile();
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.body['message'] ?? 'Failed to update bodywork services',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
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
    required List<dynamic> services,
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
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      existingServicesData['grooming'] = {
        'profileData': {
          'services': services,
          'rates': {
            'daily': daily,
            'weekly': {
              'price': weekly,
              'days': int.tryParse(weeklyDays) ?? 5,
            },
            'monthly': {
              'price': monthly,
              'days': int.tryParse(monthlyDays) ?? 5,
            },
          },
          'additionalServices': additional,
        },
        'isProfileCompleted': true,
      };

      final payload = {
        'servicesData': existingServicesData,
        'isProfileCompleted': true,
        'isProfileSetup': true,
      };
      final response = await _apiService.putRequest(
        '/vendors/$vendorId',
        payload,
      );
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
