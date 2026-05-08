// Groom View Profile Controller - Multi-service support (Grooming, Bodywork, Farrier, Shipping)
import 'dart:developer';

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

  List<Map<String, dynamic>> get filteredAvailabilityList {
    if (availabilityList.isEmpty) return [];
    final type = activeServiceType.toLowerCase();

    // Shipping/Transportation special case
    if (type.contains('shipping')) {
      return availabilityList.where((a) => a['isTrip'] == true).toList();
    }

    // Standard service types
    return availabilityList.where((a) {
      if (a['isTrip'] == true) return false;
      final List serviceTypes = a['serviceTypes'] ?? [];
      return serviceTypes.any((st) => st.toString().toLowerCase().contains(type) || type.contains(st.toString().toLowerCase()));
    }).toList();
  }

  final RxList<String> paymentMethods = <String>[].obs;
  final RxList<String> disciplinesSelected = <String>[].obs;
  final RxList<String> horseLevels = <String>[].obs;
  final RxList<String> operatingRegions = <String>[].obs;
  final RxList<String> travelScopeList = <String>[].obs;
  final RxString locationStr = 'N/A'.obs;
  final RxString experienceStr = 'N/A'.obs;

  Map<String, dynamic> getProfileDataByType(String type) {
    final serviceTypeKey = type.toLowerCase().replaceAll(' ', '');
    final _activeService = allAssignedServices.firstWhereOrNull(
      (s) => s['serviceType'].toString().toLowerCase() == type.toLowerCase()
    );
    
    final servicesData = vendorData['servicesData'] ?? {};
    
    // Data from specific service block in vendorData (usually most up-to-date)
    final Map<String, dynamic> directServiceData = servicesData[serviceTypeKey] is Map 
        ? Map<String, dynamic>.from(servicesData[serviceTypeKey]) 
        : {};

    // Base profile data from assignedServices
    final profile = _activeService?['profile'] ?? {};
    final pProfileData = profile['profileData'] ?? {};
    
    // Profile data from direct services block
    final dProfileData = directServiceData['profileData'] ?? {};

    // Merge the profileData maps together first
    final Map<String, dynamic> mergedProfileData = {
      if (pProfileData is Map) ...pProfileData,
      if (dProfileData is Map) ...dProfileData,
    };

    // Construct the final merged map
    final Map<String, dynamic> merged = {
      if (profile is Map) ...profile,
      if (directServiceData is Map) ...directServiceData,
      ...mergedProfileData, // Spread merged profile data at top level for convenience
      'profileData': mergedProfileData, // Keep nested for compatibility
    };

    // Special handling for lists that should be merged and deduplicated
    void mergeList(String key) {
      final List<dynamic> list1 = mergedProfileData[key] is List ? mergedProfileData[key] : [];
      final List<dynamic> list2 = merged[key] is List ? merged[key] : [];
      
      if (list1.isNotEmpty || list2.isNotEmpty) {
        final Map<String, dynamic> uniqueMap = {};
        for (var item in [...list1, ...list2]) {
          String? name;
          if (item is Map && item['name'] != null) {
            name = item['name'].toString().toLowerCase().trim();
          } else if (item is String && item.isNotEmpty) {
            name = item.toLowerCase().trim();
          }
          
          if (name != null) {
            uniqueMap[name] = item;
          }
        }
        final mergedList = uniqueMap.values.toList();
        merged[key] = mergedList;
        mergedProfileData[key] = mergedList;
      }
    }

    mergeList('services');
    mergeList('additionalServices');
    mergeList('addOns');

    return merged;
  }

  dynamic get _activeService => allAssignedServices.isNotEmpty
      ? allAssignedServices[currentServiceIndex.value >=
                allAssignedServices.length
            ? 0
            : currentServiceIndex.value]
      : null;

  Map<String, dynamic> get _activeApplicationData =>
      _activeService?['application']?['applicationData'] ?? _activeService?['application'] ?? {};

  Map<String, dynamic> get activeServiceProfile => activeProfileData;
  Map<String, dynamic> get activeServiceApplication =>
      _activeService?['application'] ?? {};

  // Core Properties
  String get fullName =>
      '${vendorData['firstName'] ?? ''} ${vendorData['lastName'] ?? ''}'.trim();
  String get businessNameDisplay => vendorData['businessName'] ?? 'N/A';
  String get bioDisplay => vendorData['bio'] ?? 'No bio provided.';
  String get activeServiceType => _activeService?['serviceType'] ?? 'N/A';

  // Shipping Getters
  String get shippingBaseRate {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? {};
    
    // Check possible locations for pricing data
    final pricing = activeProfileData['pricing'] ?? 
                    flatData['pricing'] ?? 
                    _activeApplicationData['pricing'] ?? {};
    
    if (pricing['inquiryPrice'] == true) return "Inquire for price";
    
    // Check multiple possible key names for base rate
    final rate = pricing['baseRate'] ?? 
                 activeProfileData['rates']?['baseRate'] ?? 
                 activeProfileData['rates']?['base'] ?? 
                 _activeApplicationData['pricing']?['baseRate'] ?? 
                 'N/A';
                 
    return rate.toString();
  }

  String get shippingLoadedRate {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? {};
    
    // Check possible locations for pricing data
    final pricing = activeProfileData['pricing'] ?? 
                    flatData['pricing'] ?? 
                    _activeApplicationData['pricing'] ?? {};
    
    if (pricing['inquiryPrice'] == true) return "Inquire for price";
    
    // Check multiple possible key names for loaded rate
    final rate = pricing['loadedRate'] ?? 
                 activeProfileData['rates']?['fullyLoaded'] ?? 
                 activeProfileData['rates']?['loaded'] ?? 
                 _activeApplicationData['pricing']?['loadedRate'] ?? 
                 'N/A';
                 
    return rate.toString();
  }
  String get shippingOperationType {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? {};
    return flatData['operationType'] ?? activeProfileData['operationType'] ?? _activeApplicationData['operationType'] ?? 'N/A';
  }

  List<String> get shippingRigTypes {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? {};
    final list = flatData['rigTypes'] ?? activeProfileData['rigTypes'] ?? _activeApplicationData['rigTypes'] ?? [];
    return List<String>.from(list);
  }

  String get shippingRigCapacity {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? {};
    return (flatData['rigCapacity'] ?? activeProfileData['rigCapacity'] ?? _activeApplicationData['rigCapacity'] ?? 'N/A').toString();
  }

  String get shippingEquipmentSummary {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? {};
    return flatData['equipmentSummary'] ?? activeProfileData['equipmentSummary'] ?? activeProfileData['equipmentsSummary'] ?? 'N/A';
  }

  String get shippingEquipmentsSummary => shippingEquipmentSummary;
  
  String get shippingDotNumber =>
      (_activeApplicationData['businessInfo']?['usdotNumber'] ??  _activeApplicationData["usdotNumber"] ??'N/A').toString();

  bool get hasDotNumber => shippingDotNumber != 'N/A' && shippingDotNumber.isNotEmpty;

  bool get isInsured {
    final status = insuranceStatus.toLowerCase();
    if (status.contains('carries insurance')) return true;
    
    final media = _activeApplicationData['media'] ?? {};
    final insurance = media['insurance'] ?? activeProfileData['insurance'] ?? activeProfileData['insurancePhoto']?? activeProfileData['dotCopy'];
    return insurance != null && insurance.toString().isNotEmpty && insurance.toString() != 'null';
  }

  String get insuranceStatus {
    final servicesData = vendorData['servicesData'] ?? {};
    final type = activeServiceType.toLowerCase().replaceAll(' ', '');
    final flatData = servicesData[type] ?? {};
    
    return flatData['insuranceStatus']?.toString() ?? 
           activeProfileData['insuranceStatus']?.toString() ?? 
           _activeApplicationData['insuranceStatus']?.toString() ?? 
           '';
  }

  List<String> get certifications {
    final servicesData = vendorData['servicesData'] ?? {};
    final type = activeServiceType.toLowerCase().replaceAll(' ', '');
    final flatData = servicesData[type] ?? {};
    
    final list = flatData['certifications'] ?? 
                 activeProfileData['certifications'] ?? 
                 _activeApplicationData['certifications'] ?? 
                 [];
    return List<String>.from(list);
  }

  bool get shippingHasCDL {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? {};
    return flatData['hasCDL'] ?? activeProfileData['hasCDL'] ?? _activeApplicationData['confirmLicense'] ?? false;
  }
      
  String get shippingBusinessName => 
      vendorData['businessName'] ?? 
      _activeApplicationData['businessInfo']?['legalName'] ?? 
      'N/A';
  List<String> get shippingServicesOffered {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? {};
    final list = flatData['services'] ?? activeProfileData['services'] ?? activeProfileData['servicesOffered'] ?? [];
    return List<String>.from(list);
  }

  List<String> get shippingRegionsCovered {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? {};
    final list = flatData['regionsCovered'] ?? activeProfileData['regionsCovered'] ?? _activeApplicationData['regions'] ?? [];
    return List<String>.from(list);
  }

  List<String> get shippingTravelScope {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? {};
    final list = flatData['travelScope'] ?? activeProfileData['travelScope'] ?? _activeApplicationData['travelScope'] ?? [];
    return List<String>.from(list);
  }
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
        fetchAvailability(data['_id']??["id"]);
      }
    } catch (e) {
      debugPrint('Error fetching vendor profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateActiveServiceData() {
    if (allAssignedServices.isEmpty) return;
    final profileDataMap = activeProfileData;

    // Update Additional Services
    final List addServices = profileDataMap['additionalServices'] ?? [];
    additionalServices.assignAll(addServices.map((s) {
      if (s is Map) return s.cast<String, dynamic>();
      return {'name': s.toString(), 'price': '0'};
    }).toList());

    log("Active Profile Data Services: ${profileDataMap['services']}");
    final List bwServices =
        profileDataMap['services'] ??
        profileDataMap['additionalServices'] ??
        [];
    bodyworkServices.assignAll(bwServices.map((s) {
      if (s is Map) return s.cast<String, dynamic>();
      return {'name': s.toString(), 'price': '0', 'isSelected': true};
    }).toList());

    final appDataMap = _activeApplicationData;

    _updateLocationAndExperience(appDataMap, _activeService);
    _updateTags(appDataMap);
    travelScopeList.assignAll(
      List<String>.from(appDataMap['travelScope'] ?? []),
    );
  }

  void _updateTags(Map appData) {
    // 1. Try Service Application Data
    List<String> d = List<String>.from(appData['disciplines'] ?? []);
    if (d.contains('Other') && appData['otherDiscipline'] != null && appData['otherDiscipline'].toString().isNotEmpty) {
      d = d.map((e) => e == 'Other' ? "${appData['otherDiscipline']}" : e).toList();
    }

    List<String> h = List<String>.from(appData['horseLevels'] ?? []);
    if (h.contains('Other') && appData['otherHorseLevel'] != null && appData['otherHorseLevel'].toString().isNotEmpty) {
      h = h.map((e) => e == 'Other' ? "${appData['otherHorseLevel']}" : e).toList();
    }

    List<String> r = List<String>.from(appData['regions'] ?? []);

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

  Future<void> fetchAvailability(String vId) async {
    final vendorId = vId;
    if (vendorId.isEmpty) return;
    try {
      isAvailabilityLoading.value = true;
      final List<Map<String, dynamic>> localCombinedList = [];

      // Parallel fetch for speed
      final responses = await Future.wait([
        _apiService.getRequest('/availability/vendors/$vendorId'),
        _apiService.getRequest('/trips/vendor/$vendorId'),
      ]);

      final availabilityResponse = responses[0];
      final tripsResponse = responses[1];

      if (availabilityResponse.statusCode == 200 && availabilityResponse.body['success'] == true) {
        final List data = availabilityResponse.body['data'] ?? [];
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            localCombinedList.add(item);
          }
        }
      }

      if (tripsResponse.statusCode == 200 && tripsResponse.body['success'] == true) {
        final List tripsData = tripsResponse.body['data'] ?? [];
        for (var t in tripsData) {
          if (t is Map<String, dynamic>) {
            final Map<String, dynamic> tripMap = Map<String, dynamic>.from(t);
            tripMap['isTrip'] = true;
            localCombinedList.add(tripMap);
          }
        }
      }

      // Sort by soonest date
      localCombinedList.sort((a, b) {
        final dateStrA = a['startDate']?.toString() ?? a['specificDate']?.toString() ?? '';
        final dateStrB = b['startDate']?.toString() ?? b['specificDate']?.toString() ?? '';
        final dateA = DateTime.tryParse(dateStrA) ?? DateTime(2099);
        final dateB = DateTime.tryParse(dateStrB) ?? DateTime(2099);
        return dateA.compareTo(dateB);
      });

      availabilityList.assignAll(localCombinedList);
    } catch (e) {
      debugPrint('Error in fetchAvailability: $e');
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
  String get dailyRate {
    final rate = activeProfileData['rates']?['daily'];
    return (rate == null || rate.toString() == 'N/A') ? '' : rate.toString();
  }
  String get weeklyRate {
    final rate = activeProfileData['rates']?['weekly']?['price'];
    return (rate == null || rate.toString() == 'N/A') ? '' : rate.toString();
  }
  String get weeklyDays =>
      activeProfileData['rates']?['weekly']?['days']?.toString() ?? '5';
  String get monthlyRate {
    final rate = activeProfileData['rates']?['monthly']?['price'];
    return (rate == null || rate.toString() == 'N/A') ? '' : rate.toString();
  }
  String get monthlyDays =>
      activeProfileData['rates']?['monthly']?['days']?.toString() ?? '5';

  // Capabilities
  List<dynamic> get groomingServices =>
      List<dynamic>.from(activeProfileData['services'] ?? []);
  List<String> get supportOptions =>
      List<String>.from(activeProfileData['capabilities']?['support'] ?? []);
  List<String> get handlingOptions =>
      List<String>.from(activeProfileData['capabilities']?['handling'] ?? []);

  // Social Media
  String get instagramUrl =>
      activeProfileData['socialMedia']?['instagram'] ?? '';
  String get facebookUrl =>
      activeProfileData['socialMedia']?['facebook'] ?? '';

  // Travel & Policy
  List<String> get travelPreferences {
    final raw = activeProfileData['travelPreferences'] ?? activeProfileData['travelFees'] ?? [];
    if (raw is! List) return [];
    return raw
        .map((item) {
          if (item is Map) {
            final category = item['category']?.toString() ?? item['region']?.toString() ?? item['name']?.toString() ?? item['type']?.toString();
            final type = item['type']?.toString();
            final price = item['price']?.toString();
            
            if (category != null && type != null && type != 'No travel fee' && type.isNotEmpty) {
              String str = "$category: $type";
              if (price != null && price.isNotEmpty && price != '0') {
                str += " (\$ $price)";
              }
              return str;
            }
            return category ?? '';
          }
          return item.toString();
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String get cancellationPolicy {
    final raw = activeProfileData['cancellationPolicy'];
    if (raw is Map) {
      return raw['policy']?.toString() ?? "";
    }
    if (raw is String && raw.isNotEmpty) {
      return raw;
    }
    return '';
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
      activeProfileData['highlights'] ??
          activeProfileData['additionalSkills'] ??
          [],
    );
    return ph;
  }

  // Combined Media
  List<String> get allMedia => {
    ..._extractMedia(activeProfileData['media']),
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

  // Methods to get specific data by type
  List<dynamic> getServicesByType(String type) => getProfileDataByType(type)['services'] ?? [];
  List<dynamic> getAdditionalServicesByType(String type) => getProfileDataByType(type)['additionalServices'] ?? [];

  // Legacy getters
  Map<String, dynamic> get activeProfileData => getProfileDataByType(
    allAssignedServices.isEmpty ? '' : allAssignedServices[currentServiceIndex.value]['serviceType'].toString()
  );

  List<dynamic> get farrierServices =>
      List<dynamic>.from(activeProfileData['services'] ?? []);
  List<dynamic> get farrierAddOns =>
      List<dynamic>.from(activeProfileData['addOns'] ?? []);
  List<String> get farrierScopeOfWork {
    List<String> scope = List<String>.from(_activeApplicationData['scopeOfWork'] ?? []);
    if (scope.contains('Other') && _activeApplicationData['otherScopeOfWork'] != null && _activeApplicationData['otherScopeOfWork'].toString().isNotEmpty) {
      scope = scope.map((e) => e == 'Other' ? "${_activeApplicationData['otherScopeOfWork']}" : e).toList();
    }
    return scope;
  }
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

      final existing = Map<String, dynamic>.from(existingServicesData['braiding'] ?? {});
      final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});

      existingServicesData['braiding'] = {
        ...existing,
        'profileData': {
            ...existingProfile,
            'services': services
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

  Future<bool> updateClippingServices(
    List<Map<String, dynamic>> services,
  ) async {
    try {
      isLoading.value = true;
      final vendorId = vendorData['_id'];
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      final existing = Map<String, dynamic>.from(existingServicesData['clipping'] ?? {});
      final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});

      existingServicesData['clipping'] = {
        ...existing,
        'profileData': {
            ...existingProfile,
            'services': services
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

  Future<bool> updateFarrierServices({
    required List<Map<String, dynamic>> services,
    required List<Map<String, dynamic>> addOns,
  }) async {
    try {
      isLoading.value = true;
      final vendorId = vendorData['_id'];
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      final existing = Map<String, dynamic>.from(existingServicesData['farrier'] ?? {});
      final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});

      existingServicesData['farrier'] = {
        ...existing,
        'profileData': {
            ...existingProfile,
            'services': services.map((s) => {
                ...s,
                'price': s['price']?.toString().replaceAll(',', '') ?? '0'
            }).toList(), 
            'addOns': addOns.map((s) => {
                ...s,
                'price': s['price']?.toString().replaceAll(',', '') ?? '0'
            }).toList()
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

      final existing = Map<String, dynamic>.from(existingServicesData['bodywork'] ?? {});
      final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});

      existingServicesData['bodywork'] = {
        ...existing,
        'profileData': {
            ...existingProfile,
            'services': services.map((s) => {
                ...s,
                'price': s['price']?.toString().replaceAll(',', '') ?? '0',
                if (s['rates'] != null && s['rates'] is Map)
                  'rates': (s['rates'] as Map).map((key, value) => MapEntry(key, value?.toString().replaceAll(',', '') ?? '0'))
            }).toList()
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

      final existing = Map<String, dynamic>.from(existingServicesData['grooming'] ?? {});
      final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});

      existingServicesData['grooming'] = {
        ...existing,
        'profileData': {
          ...existingProfile,
          'services': services,
          'rates': {
            'daily': daily.replaceAll(',', ''),
            'weekly': {
              'price': weekly.replaceAll(',', ''),
              'days': int.tryParse(weeklyDays) ?? 5,
            },
            'monthly': {
              'price': monthly.replaceAll(',', ''),
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
