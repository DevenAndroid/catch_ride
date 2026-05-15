import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/utils/vendor_service_payload.dart';
import 'package:catch_ride/utils/vendor_travel_preference_payload.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/system_config_controller.dart';

import '../chat_controller.dart';

class VendorDetailsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxString vendorId = ''.obs;
  final RxBool isLoading = true.obs;
  final RxMap vendorData = {}.obs;
  final RxList<dynamic> availabilityList = <dynamic>[].obs;
  final RxBool isAvailabilityLoading = false.obs;

  List<dynamic> get filteredAvailabilityList {
    if (availabilityList.isEmpty) return [];
    if (availableServices.isEmpty) return availabilityList;
    
    final activeService = availableServices[selectedTabIndex.value].toLowerCase();
    
    if (activeService.contains('shipping') || activeService.contains('transportation')) {
      return availabilityList.where((a) => a is Map && a['isTrip'] == true).toList();
    }
    
    return availabilityList.where((a) {
      if (a is Map && a['isTrip'] == true) return false;
      if (a is VendorAvailabilityModel) {
        return a.serviceTypes.any((st) => 
          st.toLowerCase().contains(activeService) || activeService.contains(st.toLowerCase())
        );
      }
      return true;
    }).toList();
  }
  final RxBool canMessage = false.obs;

  // Booking specific (if coming from booking screen)
  final RxString bookingId = ''.obs;
  final RxBool fromBooking = false.obs;
  final RxString bookingStatus = ''.obs;

  // Tabs management
  final RxInt selectedTabIndex = 0.obs;
  final RxList<String> availableServices = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    String? id;
    if (args != null && args is Map) {
      id = args['id'] ?? args['vendorId'];
      bookingId.value = args['bookingId'] ?? '';
      fromBooking.value = args['fromBooking'] ?? false;
      bookingStatus.value = args['bookingStatus'] ?? '';
    }
    id ??= Get.parameters['id'];

    if (id != null) {
      vendorId.value = id;
      fetchVendorDetails(id);
      fetchAvailability(id);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> fetchVendorDetails(String id) async {
    isLoading.value = true;
    try {
      final response = await _apiService.getRequest('/vendors/$id');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final raw = response.body['data'];
        vendorData.value =
            raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
        _applyNormalizedAssignedServices();
        
        // Check if user can message (allow messaging all vendors by default now)
        canMessage.value = true;
      }
    } catch (e) {
      debugPrint('Error fetching vendor details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Aligns payload with [VendorModel.assignedServices] (`serviceType`, nested profile/application).
  void _applyNormalizedAssignedServices() {
    final map = Map<String, dynamic>.from(vendorData);
    final normalized = normalizeAssignedServices(map);
    map['assignedServices'] = normalized;
    vendorData.value = map;

    availableServices.assignAll(
      normalized
          .map((s) => s['serviceType']?.toString() ?? '')
          .where((t) => t.isNotEmpty),
    );
    if (availableServices.isNotEmpty) {
      selectedTabIndex.value = 0;
    }
  }

  /// Same merge as [GroomViewProfileController.getProfileDataByType]: root VendorModel
  /// subdoc + `assignedServices` profile + `servicesData` so public details match own profile.
  Map<String, dynamic> getProfileDataByType(String serviceType) {
    if (serviceType.trim().isEmpty) return {};
    return mergedVendorServiceDisplayData(
      Map<String, dynamic>.from(vendorData),
      serviceType,
    );
  }

  /// Normalized match for tab label (e.g. `Grooming` vs stored casing).
  dynamic assignedServiceRowFor(String selectedServiceType) {
    final list = vendorData['assignedServices'];
    if (list is! List) return null;
    for (final s in list) {
      if (assignedServiceMatchesTab(s, selectedServiceType)) return s;
    }
    return null;
  }

  /// Flat merged profile for the selected tab (VendorModel subdoc + profileData + servicesData).
  Map<String, dynamic> get _mergedActiveDisplay {
    if (availableServices.isEmpty) return {};
    return getProfileDataByType(availableServices[selectedTabIndex.value].toString());
  }

  Map<String, dynamic> get _mergedProfileFlat {
    final m = _mergedActiveDisplay;
    final pd = m['profileData'];
    if (pd is Map) return Map<String, dynamic>.from(pd as Map);
    return Map<String, dynamic>.from(m);
  }

  void navigateToChat() {
    final chatController = Get.put(ChatController());
    chatController.openBookingChat(
      bookingId: bookingId.value,
      otherId: vendorId.value,
      otherName: fullName,
      otherImage: profilePhoto,
    );
  }

  Future<void> fetchBookingStatus(String id) async {
    // Keep this for backward compatibility or if we need to check specific permissions later
    // For now, we set canMessage to true in fetchVendorDetails
  }

  Future<void> fetchAvailability(String id) async {
    if (id.isEmpty) return;
    try {
      isAvailabilityLoading.value = true;
      final List<dynamic> localCombinedList = [];

      final responses = await Future.wait([
        _apiService.getRequest('/availability/vendors/$id'),
        _apiService.getRequest('/trips/vendor/$id'),
      ]);

      final availabilityResponse = responses[0];
      final tripsResponse = responses[1];

      if (availabilityResponse.statusCode == 200 && availabilityResponse.body['success'] == true) {
        final List data = availabilityResponse.body['data'] ?? [];
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            localCombinedList.add(VendorAvailabilityModel.fromJson(item));
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
        DateTime dateA;
        DateTime dateB;

        if (a is VendorAvailabilityModel) {
          dateA = a.startDate ?? a.specificDate ?? DateTime(2099);
        } else {
          dateA = DateTime.tryParse(a['startDate']?.toString() ?? '') ?? DateTime(2099);
        }

        if (b is VendorAvailabilityModel) {
          dateB = b.startDate ?? b.specificDate ?? DateTime(2099);
        } else {
          dateB = DateTime.tryParse(b['startDate']?.toString() ?? '') ?? DateTime(2099);
        }

        return dateA.compareTo(dateB);
      });

      availabilityList.assignAll(localCombinedList);
    } catch (e) {
      debugPrint('Error in fetchAvailability: $e');
    } finally {
      isAvailabilityLoading.value = false;
    }
  }

  // Getters for display (aligned with catch-ride-backend/models/VendorModel.js root fields)
  String get fullName => '${vendorData['firstName'] ?? ''} ${vendorData['lastName'] ?? ''}'.trim();
  String get businessName => vendorData['businessName']?.toString() ?? '';
  /// API may expose `profilePhoto` / `coverImage`; VendorModel uses `profile` / `bannerImage` strings.
  String get profilePhoto =>
      (vendorData['profilePhoto'] ?? vendorData['profile'])?.toString() ?? '';
  String get coverImage =>
      (vendorData['coverImage'] ?? vendorData['bannerImage'])?.toString() ?? '';
  /// VendorModel: `about`. Legacy / mobile may use `bio`.
  String get bio {
    final about = vendorData['about']?.toString().trim();
    if (about != null && about.isNotEmpty) return about;
    final legacy = vendorData['bio']?.toString().trim();
    if (legacy != null && legacy.isNotEmpty) return legacy;
    return 'N/A';
  }

  String get noteForTrainer => vendorData['noteForTrainer']?.toString().trim() ?? '';

  /// VendorModel service preform `experienceHighlights`; GET /vendors/:id may add `userHighlights` from User.
  List<String> get displayHighlights {
    final fromMerged = List<String>.from(
      _mergedProfileFlat['experienceHighlights'] ?? [],
    );
    if (fromMerged.isNotEmpty) {
      return fromMerged.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    final uh = vendorData['userHighlights'];
    if (uh is List && uh.isNotEmpty) {
      return uh.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return List<String>.from(vendorData['highlights'] ?? []);
  }
  
  // Active Service Getters (VendorModel.assignedServices + nested profile/application maps)
  dynamic get _activeService {
    final list = vendorData['assignedServices'];
    if (list is! List || list.isEmpty || availableServices.isEmpty) return null;
    final selected = availableServices[selectedTabIndex.value].toString();
    for (final s in list) {
      if (assignedServiceMatchesTab(s, selected)) return s;
    }
    return null;
  }

  Map<String, dynamic> get _activeProfileData => effectiveProfileData(_activeService);
  Map<String, dynamic> get _activeApplicationData => effectiveApplicationData(_activeService);
  
  String get location {
    // VendorModel root: homeBaseLocation { city, state, country }
    final hbl = vendorData['homeBaseLocation'];
    String? city;
    String? state;
    String? country;
    if (hbl is Map) {
      city = hbl['city']?.toString();
      state = hbl['state']?.toString();
      country = hbl['country']?.toString();
    }

    final merged = _mergedProfileFlat;
    if (!_isValid(city)) city = merged['city']?.toString();
    if (!_isValid(state)) state = merged['state']?.toString();
    if (!_isValid(country)) country = merged['country']?.toString();
    final hbMerged = merged['homeBase'];
    if (hbMerged is Map) {
      if (!_isValid(city)) city = hbMerged['city']?.toString();
      if (!_isValid(state)) state = hbMerged['state']?.toString();
      if (!_isValid(country)) country = hbMerged['country']?.toString();
    }

    final appData = _activeApplicationData;
    if (!_isValid(city)) city = appData['homeBase']?['city'] ?? appData['city'];
    if (!_isValid(state)) state = appData['homeBase']?['state'] ?? appData['state'];
    if (!_isValid(country)) country = appData['homeBase']?['country'] ?? appData['country'];

    if (!_isValid(city) || !_isValid(state)) {
      final topAppData = _activeService?['application'] ?? {};
      city ??= topAppData['homeBase']?['city'] ?? topAppData['city'];
      state ??= topAppData['homeBase']?['state'] ?? topAppData['state'];
      country ??= topAppData['homeBase']?['country'] ?? topAppData['country'];
    }

    if (_isValid(city) || _isValid(state) || _isValid(country)) {
      final parts = <String>[];
      if (_isValid(city)) parts.add(city!);
      if (_isValid(state)) parts.add(state!);
      if (_isValid(country)) parts.add(country!);
      return parts.join(', ');
    }

    final loc = vendorData['location'] ?? vendorData['homeBase'];
    if (loc is Map) {
      city = loc['city']?.toString();
      state = loc['state']?.toString();
    }
    if (_isValid(city) && _isValid(state)) return '$city, $state';
    if (loc != null) return '$loc';

    return '';
  }

  String get experienceStr {
    final exp = _mergedProfileFlat['experience'] ??
        _mergedProfileFlat['yearsExperience'] ??
        _activeApplicationData['experience'] ??
        _activeApplicationData['yearsExperience'] ??
        vendorData['yearsExperience'] ??
        vendorData['experience'] ??
        '';
    if (exp == '' || exp == 'N/A') return '';
    final val = exp.toString();
    return val.toLowerCase().contains('year') ? val : '$val Years';
  }

  bool _isValid(dynamic v) => v != null && v.toString().isNotEmpty && v.toString().toLowerCase() != 'n/a';

  List<String> get paymentMethods => List<String>.from(vendorData['paymentMethods'] ?? []);
  String get otherPaymentDetails => vendorData['otherPaymentDetails']?.toString() ?? '';
  /// VendorModel preform uses `instagramLink` / `facebookLink` on service subdocs; profiles may use nested socialMedia.
  String get instagramUrl =>
      _activeProfileData['socialMedia']?['instagram']?.toString().trim() ??
      _mergedProfileFlat['socialMedia']?['instagram']?.toString().trim() ??
      _mergedProfileFlat['instagramLink']?.toString().trim() ??
      _activeApplicationData['instagramLink']?.toString().trim() ??
      '';
  String get facebookUrl =>
      _activeProfileData['socialMedia']?['facebook']?.toString().trim() ??
      _mergedProfileFlat['socialMedia']?['facebook']?.toString().trim() ??
      _mergedProfileFlat['facebookLink']?.toString().trim() ??
      _activeApplicationData['facebookLink']?.toString().trim() ??
      '';

  // Service specific getters
  String get dailyRate =>
      _mergedProfileFlat['rates']?['daily']?.toString() ??
      _activeProfileData['rates']?['daily']?.toString() ??
      '';
  String get weeklyRate =>
      _mergedProfileFlat['rates']?['weekly']?['price']?.toString() ??
      _activeProfileData['rates']?['weekly']?['price']?.toString() ??
      '';
  String get weeklyDays =>
      _mergedProfileFlat['rates']?['weekly']?['days']?.toString() ??
      _activeProfileData['rates']?['weekly']?['days']?.toString() ??
      '5';
  String get monthlyRate =>
      _mergedProfileFlat['rates']?['monthly']?['price']?.toString() ??
      _activeProfileData['rates']?['monthly']?['price']?.toString() ??
      '';
  String get monthlyDays =>
      _mergedProfileFlat['rates']?['monthly']?['days']?.toString() ??
      _activeProfileData['rates']?['monthly']?['days']?.toString() ??
      '5';

  // Shipping Specific Getters
  String get shippingBaseRate {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final pricing = _mergedProfileFlat['pricing'] ??
        _activeProfileData['pricing'] ??
        flatData['pricing'] ??
        _activeApplicationData['pricing'] ??
        {};
    if (pricing['inquiryPrice'] == true || pricing['inquireForPrice'] == true) {
      return 'Inquire for price';
    }
    final rate = pricing['baseRate'] ??
        pricing['basePrice'] ??
        _activeProfileData['rates']?['baseRate'] ??
        _activeProfileData['rates']?['base'] ??
        '';
    return rate.toString();
  }

  String get shippingLoadedRate {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final pricing = _mergedProfileFlat['pricing'] ??
        _activeProfileData['pricing'] ??
        flatData['pricing'] ??
        _activeApplicationData['pricing'] ??
        {};
    if (pricing['inquiryPrice'] == true || pricing['inquireForPrice'] == true) {
      return 'Inquire for price';
    }
    final rate = pricing['loadedRate'] ??
        pricing['fullyLoadedRate'] ??
        _activeProfileData['rates']?['fullyLoaded'] ??
        _activeProfileData['rates']?['loaded'] ??
        '';
    return rate.toString();
  }

  String get shippingOperationType {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    return flatData['operationType'] ??
        _mergedProfileFlat['operationType'] ??
        _activeProfileData['operationType'] ??
        _activeApplicationData['operationType'] ??
        '';
  }

  List<String> get shippingRigTypes {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final list = flatData['rigTypes'] ??
        flatData['rigType'] ??
        _mergedProfileFlat['rigTypes'] ??
        _mergedProfileFlat['rigType'] ??
        _activeProfileData['rigTypes'] ??
        _activeApplicationData['rigTypes'] ??
        [];
    return List<String>.from(list);
  }

  String get shippingRigCapacity {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    return (flatData['rigCapacity'] ??
            _mergedProfileFlat['rigCapacity'] ??
            _mergedProfileFlat['horseCapacity'] ??
            _activeProfileData['rigCapacity'] ??
            _activeApplicationData['rigCapacity'] ??
            '')
        .toString();
  }

  String get shippingEquipmentSummary {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    return flatData['equipmentSummary'] ??
        _mergedProfileFlat['equipmentSummary'] ??
        _mergedProfileFlat['equipmentsSummary'] ??
        _activeProfileData['equipmentSummary'] ??
        _activeProfileData['equipmentsSummary'] ??
        '';
  }

  String get shippingAdditionalNotes {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final pd = flatData['profileData'] is Map
        ? Map<String, dynamic>.from(flatData['profileData'] as Map)
        : <String, dynamic>{};
    for (final v in <dynamic>[
      flatData['additionalNotes'],
      pd['additionalNotes'],
      _mergedProfileFlat['additionalNotes'],
      _activeProfileData['additionalNotes'],
      flatData['notes'],
      pd['notes'],
      _activeProfileData['notes'],
    ]) {
      final s = v?.toString().trim() ?? '';
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  String get shippingDotNumber =>
      (_activeApplicationData['businessInfo']?['dotNumber'] ??
              _activeApplicationData['businessInfo']?['usdotNumber'] ??
              _mergedProfileFlat['businessInformation']?['usdotNumber'] ??
              _mergedProfileFlat['businessInfo']?['usdotNumber'] ??
              '')
          .toString();
      
  bool get shippingHasCDL {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    return flatData['hasCDL'] ?? _activeProfileData['hasCDL'] ?? _activeApplicationData['confirmLicense'] ?? false;
  }

  List<String> get shippingServicesOffered {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final list = flatData['services'] ??
        flatData['serviceOffered'] ??
        _mergedProfileFlat['services'] ??
        _mergedProfileFlat['serviceOffered'] ??
        _activeProfileData['services'] ??
        _activeProfileData['servicesOffered'] ??
        [];
    return List<String>.from(list);
  }

  List<String> get shippingRegionsCovered {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final list = flatData['regionsCovered'] ??
        _mergedProfileFlat['regionsCovered'] ??
        _activeProfileData['regionsCovered'] ??
        _activeApplicationData['regions'] ??
        [];
    return List<String>.from(list);
  }

  List<String> get shippingTravelScope {
    final servicesData = vendorData['servicesData'] ?? {};
    final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};
    final list = flatData['travelScope'] ??
        _mergedProfileFlat['travelScope'] ??
        _activeProfileData['travelScope'] ??
        _activeApplicationData['travelScope'] ??
        [];
    return List<String>.from(list);
  }

  List<dynamic> get coreServices =>
      List<dynamic>.from(_mergedProfileFlat['services'] ?? _activeProfileData['services'] ?? []);
  List<String> get supportOptions => List<String>.from(
        _mergedProfileFlat['capabilities']?['support'] ??
            _activeProfileData['capabilities']?['support'] ??
            [],
      );
  List<String> get handlingOptions => List<String>.from(
        _mergedProfileFlat['capabilities']?['handling'] ??
            _activeProfileData['capabilities']?['handling'] ??
            [],
      );
  List<String> get disciplinesSelected {
    final fromApp = List<String>.from(_activeApplicationData['disciplines'] ?? []);
    if (fromApp.isNotEmpty) return fromApp;
    final m = _mergedProfileFlat;
    final d = List<String>.from(m['disciplines'] ?? m['desciplines'] ?? []);
    return d;
  }

  List<String> get horseLevels {
    final fromApp = List<String>.from(_activeApplicationData['horseLevels'] ?? []);
    if (fromApp.isNotEmpty) return fromApp;
    final m = _mergedProfileFlat;
    return List<String>.from(
      m['horseLevels'] ?? m['typicalLevelOfHorses'] ?? [],
    );
  }

  List<String> get operatingRegions {
    final fromApp = List<String>.from(_activeApplicationData['regions'] ?? []);
    if (fromApp.isNotEmpty) return fromApp;
    final m = _mergedProfileFlat;
    return List<String>.from(
      m['regions'] ?? m['regionsCovered'] ?? [],
    );
  }

  List<String> get travelPreferences {
    final raw = _mergedProfileFlat['travelPreferences'] ??
        _activeProfileData['travelPreferences'] ??
        [];
    if (raw is! List) return [];
    return raw
        .map((item) => VendorTravelPreferencePayload.summaryForListItem(item))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// VendorModel `farrier.scopeOfWork` + application wizard data.
  List<String> get farrierScopeOfWork {
    final fromApp = List<String>.from(
      _activeApplicationData['scopeOfWork'] ?? [],
    );
    if (fromApp.isNotEmpty) return fromApp;
    return List<String>.from(_mergedProfileFlat['scopeOfWork'] ?? []);
  }

  List get additionalServices =>
      _mergedProfileFlat['additionalServices'] ?? _activeProfileData['additionalServices'] ?? [];

  List<String> get photos {
    final vendorRoot = Map<String, dynamic>.from(vendorData);
    String? type;
    if (availableServices.isNotEmpty) {
      type = availableServices[selectedTabIndex.value].toString();
    } else {
      final types = serviceTypesFromVendorRoot(vendorRoot);
      if (types.isEmpty) {
        final urls = <String>[];
        for (final u in [profilePhoto, coverImage]) {
          if (u.trim().isNotEmpty) urls.add(u);
        }
        return urls;
      }
      type = types.first;
    }
    final merged = getProfileDataByType(type!);
    final pd = merged['profileData'] is Map
        ? Map<String, dynamic>.from(merged['profileData'] as Map)
        : <String, dynamic>{};
    final app = effectiveApplicationData(assignedServiceRowFor(type));
    return mergeServicePortfolioMediaUrls(
      serviceType: type,
      vendorRoot: vendorRoot,
      profileData: pd,
      appData: app,
    );
  }

  dynamic get cancellationPolicy {
    final data = _mergedProfileFlat['cancellationPolicy'] ?? _activeProfileData['cancellationPolicy'];
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is Map) return data['policy'] ?? 'Flexible (24+ hrs)';
    return 'Flexible (24+ hrs)';
  }

  bool get isAcceptingRequests => vendorData['compliance']?['acceptingRequests'] ?? true;
}
