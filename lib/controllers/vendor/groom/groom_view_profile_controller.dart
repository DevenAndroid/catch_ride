// Groom View Profile Controller - Multi-service support (Grooming, Bodywork, Farrier, Shipping)
import 'dart:developer';

import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/utils/vendor_service_payload.dart';
import 'package:catch_ride/utils/vendor_service_sync.dart';
import 'package:catch_ride/utils/vendor_travel_preference_payload.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/system_config_controller.dart';

class GroomViewProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  /// True while Services & Rates save is in flight (avoids swapping TabBarView for full-screen loader).
  final RxBool isSavingRates = false.obs;
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
    if (type.contains('shipping') || type.contains('transportation')) {
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
    return mergedVendorServiceDisplayData(
      Map<String, dynamic>.from(vendorData),
      type,
    );
  }

  dynamic get _activeService => allAssignedServices.isNotEmpty
      ? allAssignedServices[currentServiceIndex.value >=
                allAssignedServices.length
            ? 0
            : currentServiceIndex.value]
      : null;

  Map<String, dynamic> get _activeApplicationData =>
      effectiveApplicationData(_activeService);

  Map<String, dynamic> get activeServiceProfile => activeProfileData;
  Map<String, dynamic> get activeServiceApplication =>
      _activeService?['application'] ?? {};

  // Core Properties
  String get fullName =>
      '${vendorData['firstName'] ?? ''} ${vendorData['lastName'] ?? ''}'.trim();
  String get businessNameDisplay => vendorData['businessName'] ?? 'N/A';
  String get bioDisplay => vendorData['bio'] ?? 'No bio provided.';
  String get activeServiceType => _activeService?['serviceType'] ?? 'N/A';
  List<String> get highlights => List<String>.from(vendorData['highlights'] ?? []);

  // Shipping Getters
  String get shippingBaseRate {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    
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
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    
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
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    return flatData['operationType'] ?? activeProfileData['operationType'] ?? _activeApplicationData['operationType'] ?? 'N/A';
  }

  List<String> get shippingRigTypes {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final list = flatData['rigTypes'] ?? activeProfileData['rigTypes'] ?? _activeApplicationData['rigTypes'] ?? [];
    return List<String>.from(list);
  }

  String get shippingRigCapacity {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    return (flatData['rigCapacity'] ?? activeProfileData['rigCapacity'] ?? _activeApplicationData['rigCapacity'] ?? 'N/A').toString();
  }

  String get shippingEquipmentSummary {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    return flatData['equipmentSummary'] ?? activeProfileData['equipmentSummary'] ?? activeProfileData['equipmentsSummary'] ?? 'N/A';
  }

  /// VendorModel `shipping.additionalNotes` (+ legacy `notes` / nested profileData).
  String get shippingAdditionalNotes {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final pd = flatData['profileData'] is Map
        ? Map<String, dynamic>.from(flatData['profileData'] as Map)
        : <String, dynamic>{};
    for (final v in <dynamic>[
      flatData['additionalNotes'],
      pd['additionalNotes'],
      activeProfileData['additionalNotes'],
      flatData['notes'],
      pd['notes'],
      activeProfileData['notes'],
    ]) {
      final s = v?.toString().trim() ?? '';
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  String get shippingEquipmentsSummary => shippingEquipmentSummary;
  
  String get shippingDotNumber =>
      (_activeApplicationData['businessInfo']?['usdotNumber'] ??  _activeApplicationData["usdotNumber"] ??'N/A').toString();

  bool get hasDotNumber => shippingDotNumber != 'N/A' && shippingDotNumber.isNotEmpty;

  bool get isInsured {
    final media = _activeApplicationData['media'] ?? {};
    final insurance = media['insurance'] ?? activeProfileData['insurance'] ?? activeProfileData['insurancePhoto']?? activeProfileData['dotCopy'];
    return insurance != null && insurance.toString().isNotEmpty && insurance.toString() != 'null';
  }

  bool get shippingHasCDL {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    return flatData['hasCDL'] ?? activeProfileData['hasCDL'] ?? _activeApplicationData['confirmLicense'] ?? false;
  }
      
  String get shippingBusinessName => 
      vendorData['businessName'] ?? 
      _activeApplicationData['businessInfo']?['legalName'] ?? 
      'N/A';
  List<String> get shippingServicesOffered {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final list = flatData['services'] ?? activeProfileData['services'] ?? activeProfileData['servicesOffered'] ?? [];
    return List<String>.from(list);
  }

  List<String> get shippingRegionsCovered {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final list = flatData['regionsCovered'] ?? activeProfileData['regionsCovered'] ?? _activeApplicationData['regions'] ?? [];
    return List<String>.from(list);
  }

  List<String> get shippingTravelScope {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final list = flatData['travelScope'] ?? activeProfileData['travelScope'] ?? _activeApplicationData['travelScope'] ?? [];
    return List<String>.from(list);
  }
  List<String> get travelScope => shippingTravelScope;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void>? _fetchProfileFuture;

  Future<void> fetchProfile() async {
    if (_fetchProfileFuture != null) {
      return _fetchProfileFuture;
    }
    _fetchProfileFuture = _fetchProfileImpl();
    try {
      await _fetchProfileFuture;
    } finally {
      _fetchProfileFuture = null;
    }
  }

  Future<void> _fetchProfileImpl() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getRequest('/vendors/me');

      if (response.statusCode == 200 && response.body['success'] == true) {
        final data = response.body['data'];
        final map =
            data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
        vendorData.value = map;
        _applyNormalizedAssignedServices();
        paymentMethods.assignAll(
          List<String>.from(map['paymentMethods'] ?? []),
        );
        _updateActiveServiceData();
        fetchAvailability(map['_id']?.toString() ?? map['id']?.toString() ?? '');
      }
    } catch (e) {
      debugPrint('Error fetching vendor profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyNormalizedAssignedServices() {
    final map = Map<String, dynamic>.from(vendorData);
    final normalized = normalizeAssignedServices(map);
    map['assignedServices'] = normalized;
    vendorData.value = map;
    allAssignedServices.assignAll(normalized);
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
    final mergedScope = getProfileDataByType(activeServiceType);
    travelScopeList.assignAll(
      List<String>.from(
        mergedScope['travelScope'] ?? appDataMap['travelScope'] ?? [],
      ),
    );
  }

  void _updateTags(Map appData) {
    final merged = getProfileDataByType(activeServiceType);

    // Prefer **applicationData** (what Edit Profile / wizard persist on the service row).
    // Legacy [VendorModel] embeds can hold a short or stale `disciplines` list that would
    // otherwise win over the full multi-select saved on the application.
    List<String> d = List<String>.from(appData['disciplines'] ?? []);
    if (d.isEmpty) {
      d = List<String>.from(appData['desciplines'] ?? merged['disciplines'] ?? []);
    }
    if (d.isEmpty) d = List<String>.from(merged['disciplines'] ?? []);
    if (d.contains('Other') && appData['otherDiscipline'] != null && appData['otherDiscipline'].toString().isNotEmpty) {
      d = d.map((e) => e == 'Other' ? "${appData['otherDiscipline']}" : e).toList();
    }

    List<String> h = List<String>.from(appData['horseLevels'] ?? []);
    if (h.isEmpty) {
      h = List<String>.from(
        merged['horseLevels'] ?? merged['typicalLevelOfHorses'] ?? [],
      );
    }
    if (h.contains('Other') && appData['otherHorseLevel'] != null && appData['otherHorseLevel'].toString().isNotEmpty) {
      h = h.map((e) => e == 'Other' ? "${appData['otherHorseLevel']}" : e).toList();
    }

    List<String> r = List<String>.from(appData['regions'] ?? []);
    if (r.isEmpty) {
      r = List<String>.from(merged['regions'] ?? merged['regionsCovered'] ?? []);
    }

    if (d.isNotEmpty) {
      disciplinesSelected.assignAll(d);
    } else {
      // Fallback: VendorModel root or AuthController
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
    final merged = getProfileDataByType(activeServiceType);

    // 1. VendorModel root homeBaseLocation, then merged profile (embed + servicesData + ServiceProfile)
    String? city;
    String? state;
    String? country;

    final hbl = vendorData['homeBaseLocation'];
    if (hbl is Map) {
      city = hbl['city']?.toString();
      state = hbl['state']?.toString();
      country = hbl['country']?.toString();
    }

    if (!_isValid(city)) city = merged['city']?.toString();
    if (!_isValid(state)) state = merged['state']?.toString();
    if (!_isValid(country)) country = merged['country']?.toString();

    final hbMerged = merged['homeBase'];
    if (hbMerged is Map) {
      if (!_isValid(city)) city = hbMerged['city']?.toString();
      if (!_isValid(state)) state = hbMerged['state']?.toString();
      if (!_isValid(country)) country = hbMerged['country']?.toString();
    }

    // 2. Service application (legacy / wizard) when vendor + merged lack home base
    if (!_isValid(city)) city = appData['homeBase']?['city'] ?? appData['city'];
    if (!_isValid(state)) state = appData['homeBase']?['state'] ?? appData['state'];
    if (!_isValid(country)) country = appData['homeBase']?['country'] ?? appData['country'];

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

    // Experience: VendorModel merged profile first, then application, then vendor root / user
    dynamic exp = merged['experience'] ?? merged['yearsExperience'];

    if (!_isValid(exp)) {
      exp = appData['experience'] ?? appData['yearsExperience'];
    }

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
    final vp = vendorProfileImageFromRoot(vendorData);
    if (vp.isNotEmpty) return vp;
    return Get.find<AuthController>().currentUser.value?.displayAvatar ?? '';
  }

  String get coverImage {
    final vc = vendorBannerImageFromRoot(vendorData);
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
  String get instagramUrl => resolveServiceInstagram(
        serviceType: activeServiceType,
        vendorRoot: Map<String, dynamic>.from(vendorData),
        profileData: activeProfileData,
        appData: _activeApplicationData,
      );
  String get facebookUrl => resolveServiceFacebook(
        serviceType: activeServiceType,
        vendorRoot: Map<String, dynamic>.from(vendorData),
        profileData: activeProfileData,
        appData: _activeApplicationData,
      );

  // Travel & Policy
  List<String> get travelPreferences {
    final raw = activeProfileData['travelPreferences'] ?? activeProfileData['travelFees'] ?? [];
    if (raw is! List) return [];
    return raw
        .map((item) => VendorTravelPreferencePayload.summaryForListItem(item))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String get cancellationPolicy {
    final merged = activeProfileData;
    final raw = merged['cancellationPolicy'] ??
        (merged['profileData'] is Map
            ? (merged['profileData'] as Map)['cancellationPolicy']
            : null);
    return effectiveCancellationDisplayText(raw);
  }

  String get noteForTrainer {
    final merged = activeProfileData;
    for (final v in <dynamic>[
      vendorData['noteForTrainer'],
      merged['noteForTrainer'],
      _activeApplicationData['noteForTrainer'],
      _activeApplicationData['notesForTrainer'],
      vendorData['notes'],
      merged['notes'],
    ]) {
      final s = v?.toString().trim() ?? '';
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  // Experience Highlights
  // List<String> get highlights {
  //   final List<String> vh = List<String>.from(vendorData['highlights'] ?? []);
  //   if (vh.isNotEmpty) return vh;
  //
  //   final List<String> ah = List<String>.from(
  //     _activeApplicationData['highlights'] ??
  //         _activeApplicationData['additionalSkills'] ??
  //         [],
  //   );
  //   if (ah.isNotEmpty) return ah;
  //
  //   final List<String> ph = List<String>.from(
  //     activeProfileData['highlights'] ??
  //         activeProfileData['additionalSkills'] ??
  //         [],
  //   );
  //   return ph;
  // }

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
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      final existing = Map<String, dynamic>.from(existingServicesData['braiding'] ?? {});
      final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});

      existingServicesData['braiding'] = {
        ...existing,
        'services': services,
        'profileData': {
            ...existingProfile,
            'services': services
        },
      };

      final payload = {
        'servicesData': existingServicesData,
        'isProfileSetup': true,
      };
      final response = await _apiService.putRequest(
        '/vendors/me',
        payload,
      );
      if (response.statusCode == 200) {
        final vid = vendorMongoIdFromRoot(Map<String, dynamic>.from(vendorData));
        dynamic row;
        for (final s in allAssignedServices) {
          if (assignedServiceMatchesTab(s, 'Braiding')) {
            row = s;
            break;
          }
        }
        final block = existingServicesData['braiding'];
        if (vid != null && row != null && block is Map) {
          await syncVendorServiceDocuments(
            api: _apiService,
            vendorMongoId: vid,
            assignedServiceRow: row,
            profileData: Map<String, dynamic>.from(block['profileData'] ?? {}),
            applicationData:
                Map<String, dynamic>.from(block['applicationData'] ?? {}),
          );
        }
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
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      final existing = Map<String, dynamic>.from(existingServicesData['clipping'] ?? {});
      final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});

      existingServicesData['clipping'] = {
        ...existing,
        'services': services,
        'profileData': {
            ...existingProfile,
            'services': services
        },
      };

      final payload = {
        'servicesData': existingServicesData,
        'isProfileSetup': true,
      };
      final response = await _apiService.putRequest(
        '/vendors/me',
        payload,
      );
      if (response.statusCode == 200) {
        final vid = vendorMongoIdFromRoot(Map<String, dynamic>.from(vendorData));
        dynamic row;
        for (final s in allAssignedServices) {
          if (assignedServiceMatchesTab(s, 'Clipping')) {
            row = s;
            break;
          }
        }
        final block = existingServicesData['clipping'];
        if (vid != null && row != null && block is Map) {
          await syncVendorServiceDocuments(
            api: _apiService,
            vendorMongoId: vid,
            assignedServiceRow: row,
            profileData: Map<String, dynamic>.from(block['profileData'] ?? {}),
            applicationData:
                Map<String, dynamic>.from(block['applicationData'] ?? {}),
          );
        }
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
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      final existing = Map<String, dynamic>.from(existingServicesData['farrier'] ?? {});
      final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});

      final mappedServices = services.map((s) => {
          ...s,
          'price': s['price']?.toString().replaceAll(',', '') ?? '0'
      }).toList();
      final mappedAddOns = addOns.map((s) => {
          ...s,
          'price': s['price']?.toString().replaceAll(',', '') ?? '0'
      }).toList();

      existingServicesData['farrier'] = {
        ...existing,
        'services': mappedServices,
        'addOns': mappedAddOns,
        'profileData': {
            ...existingProfile,
            'services': mappedServices, 
            'addOns': mappedAddOns
        },
      };

      final payload = {
        'servicesData': existingServicesData,
        'isProfileSetup': true,
      };
      final response = await _apiService.putRequest(
        '/vendors/me',
        payload,
      );
      if (response.statusCode == 200) {
        final vid = vendorMongoIdFromRoot(Map<String, dynamic>.from(vendorData));
        dynamic row;
        for (final s in allAssignedServices) {
          if (assignedServiceMatchesTab(s, 'Farrier')) {
            row = s;
            break;
          }
        }
        final block = existingServicesData['farrier'];
        if (vid != null && row != null && block is Map) {
          await syncVendorServiceDocuments(
            api: _apiService,
            vendorMongoId: vid,
            assignedServiceRow: row,
            profileData: Map<String, dynamic>.from(block['profileData'] ?? {}),
            applicationData:
                Map<String, dynamic>.from(block['applicationData'] ?? {}),
          );
        }
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

  /// Bodywork **Services & Rates** tab (same persistence path as [updateGroomingRates]).
  Future<bool> updateBodyworkServiceRates({
    required List<Map<String, dynamic>> services,
  }) =>
      updateBodyworkServices(services: services);

  Future<bool> updateBodyworkServices({
    required List<Map<String, dynamic>> services,
  }) async {
    try {
      isLoading.value = true;
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      final existing = Map<String, dynamic>.from(existingServicesData['bodywork'] ?? {});
      final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});

      final mappedServices = services.map((s) => {
          ...s,
          'price': s['price']?.toString().replaceAll(',', '') ?? '0',
          if (s['rates'] != null && s['rates'] is Map)
            'rates': (s['rates'] as Map).map((key, value) => MapEntry(key, value?.toString().replaceAll(',', '') ?? '0'))
      }).toList();

      existingServicesData['bodywork'] = {
        ...existing,
        'services': mappedServices,
        'profileData': {
            ...existingProfile,
            'services': mappedServices
        },
      };

      final payload = {
        'servicesData': existingServicesData,
        'isProfileSetup': true,
      };
      final response = await _apiService.putRequest(
        '/vendors/me',
        payload,
      );
      if (response.statusCode == 200) {
        final vid = vendorMongoIdFromRoot(Map<String, dynamic>.from(vendorData));
        dynamic row;
        for (final s in allAssignedServices) {
          if (assignedServiceMatchesTab(s, 'Bodywork')) {
            row = s;
            break;
          }
        }
        final block = existingServicesData['bodywork'];
        if (vid != null && row != null && block is Map) {
          await syncVendorServiceDocuments(
            api: _apiService,
            vendorMongoId: vid,
            assignedServiceRow: row,
            profileData: Map<String, dynamic>.from(block['profileData'] ?? {}),
            applicationData:
                Map<String, dynamic>.from(block['applicationData'] ?? {}),
          );
        }
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
      isSavingRates.value = true;
      final Map<String, dynamic> existingServicesData =
          Map<String, dynamic>.from(vendorData['servicesData'] ?? {});

      final existing = Map<String, dynamic>.from(existingServicesData['grooming'] ?? {});
      final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});

      final ratesPayload = <String, dynamic>{
        'daily': daily.replaceAll(',', ''),
        'weekly': <String, dynamic>{
          'price': weekly.replaceAll(',', ''),
          'days': int.tryParse(weeklyDays) ?? 5,
        },
        'monthly': <String, dynamic>{
          'price': monthly.replaceAll(',', ''),
          'days': int.tryParse(monthlyDays) ?? 5,
        },
      };

      final normalizedAdditional = additional
          .map(
            (s) => <String, dynamic>{
              'name': s['name'],
              'label': s['name'],
              'price': s['price']?.toString().replaceAll(',', '') ?? '0',
              'ratePerHour': s['price']?.toString().replaceAll(',', '') ?? '0',
              if (s['description'] != null) 'description': s['description'],
            },
          )
          .toList();

      final profilePayload = <String, dynamic>{
        ...existingProfile,
        'services': services,
        'groomingServices': services,
        'rates': ratesPayload,
        'additionalServices': normalizedAdditional,
      };

      // Mirror [GroomingDetailsController.submit]: root-level fields on the grooming block
      // (backend / GET /vendors/me often read here), plus nested profileData for service sync.
      existingServicesData['grooming'] = <String, dynamic>{
        ...existing,
        'profileData': profilePayload,
        'rates': ratesPayload,
        'services': services,
        'groomingServices': services,
        'additionalServices': normalizedAdditional,
      };

      final payload = <String, dynamic>{
        'servicesData': existingServicesData,
        'isProfileSetup': true,
      };
      final response = await _apiService.putRequest(
        '/vendors/me',
        payload,
      );
      final body = response.body;
      final ok = response.statusCode == 200 &&
          body is Map &&
          body['success'] == true;

      if (!ok) {
        final msg = body is Map
            ? (body['message']?.toString() ?? 'Failed to save grooming rates')
            : 'Failed to save grooming rates';
        Get.snackbar(
          'Error',
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final vid = vendorMongoIdFromRoot(Map<String, dynamic>.from(vendorData));
      dynamic row;
      for (final s in allAssignedServices) {
        if (assignedServiceMatchesTab(s, 'Grooming')) {
          row = s;
          break;
        }
      }
      final block = existingServicesData['grooming'];
      if (vid != null && row != null && block is Map) {
        await syncVendorServiceDocuments(
          api: _apiService,
          vendorMongoId: vid,
          assignedServiceRow: row,
          profileData: Map<String, dynamic>.from(block['profileData'] ?? {}),
          applicationData:
              Map<String, dynamic>.from(block['applicationData'] ?? {}),
        );
      }
      await fetchProfile();
      return true;
    } catch (e) {
      debugPrint('updateGroomingRates error: $e');
      Get.snackbar(
        'Error',
        'Failed to save grooming rates',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSavingRates.value = false;
    }
  }
}
