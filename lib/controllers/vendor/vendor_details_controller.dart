import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorDetailsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxString vendorId = ''.obs;
  final RxBool isLoading = true.obs;
  final RxMap vendorData = {}.obs;
  final RxList<VendorAvailabilityModel> availabilityList = <VendorAvailabilityModel>[].obs;
  final RxBool isAvailabilityLoading = false.obs;
  final RxBool canMessage = false.obs;

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

  void _setMockData() {
    // Keeping this empty or minimal to avoid showing wrong data
    vendorData.value = {};
    availableServices.clear();
  }

  Future<void> fetchVendorDetails(String id) async {
    isLoading.value = true;
    try {
      final response = await _apiService.getRequest('/vendors/$id');
      if (response.statusCode == 200 && response.body['success'] == true) {
        vendorData.value = response.body['data'] ?? {};
        
        // Identify available services
        final List services = vendorData['assignedServices'] ?? [];
        availableServices.assignAll(services.map((s) => s['serviceType'].toString()).toList());
        
        if (availableServices.isNotEmpty) {
          selectedTabIndex.value = 0;
        }
        
        // Check if user can message (has accepted booking)
        fetchBookingStatus(id);
      }
    } catch (e) {
      debugPrint('Error fetching vendor details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBookingStatus(String id) async {
    try {
      final response = await _apiService.getRequest('/bookings/check-status/$id');
      if (response.statusCode == 200 && response.body['success'] == true) {
        // canMessage is true only if there is an accepted booking
        canMessage.value = response.body['data']?['status'] == 'accepted';
      }
    } catch (e) {
      debugPrint('Error checking booking status: $e');
      canMessage.value = false;
    }
  }

  Future<void> fetchAvailability(String id) async {
    isAvailabilityLoading.value = true;
    try {
      final response = await _apiService.getRequest('/availability/vendors/$id');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List data = response.body['data'] ?? [];
        final list = data.map((e) => VendorAvailabilityModel.fromJson(e)).toList();
        
        // Sort by date (most recent first for 'last 3') or whatever order user prefers
        list.sort((a, b) => (b.startDate ?? b.specificDate ?? DateTime.now())
            .compareTo(a.startDate ?? a.specificDate ?? DateTime.now()));
            
        availabilityList.assignAll(list);
      }
    } catch (e) {
      debugPrint('Error fetching availability: $e');
    } finally {
      isAvailabilityLoading.value = false;
    }
  }

  // Getters for display
  // Getters for display
  String get fullName => '${vendorData['firstName'] ?? ''} ${vendorData['lastName'] ?? ''}'.trim();
  String get businessName => vendorData['businessName'] ?? 'N/A';
  String get profilePhoto => vendorData['profilePhoto'] ?? '';
  String get coverImage => vendorData['coverImage'] ?? '';
  String get bio => vendorData['bio'] ?? 'No bio provided.';
  
  // Active Service Getters
  dynamic get _activeService => (vendorData['assignedServices'] as List?)?.firstWhereOrNull(
      (s) => s['serviceType'] == (availableServices.isNotEmpty ? availableServices[selectedTabIndex.value] : null));

  Map<String, dynamic> get _activeProfileData => _activeService?['profile']?['profileData'] ?? {};
  Map<String, dynamic> get _activeApplicationData => _activeService?['application']?['applicationData'] ?? {};
  
  String get homeCity => (vendorData['homeBase'] ?? _activeApplicationData['homeBase'])?['city'] ?? '';
  String get homeState => (vendorData['homeBase'] ?? _activeApplicationData['homeBase'])?['state'] ?? '';
  String get homeCountry => (vendorData['homeBase'] ?? _activeApplicationData['homeBase'])?['country'] ?? 'USA';

  String get location => homeCity.isNotEmpty && homeState.isNotEmpty 
      ? '$homeCity, $homeState, $homeCountry' 
      : 'N/A';

  String get experienceStr => (vendorData['experience'] ?? _activeApplicationData['experience'])?.toString() ?? 'N/A';

  List<String> get paymentMethods => List<String>.from(vendorData['paymentMethods'] ?? []);
  String get instagramUrl => _activeProfileData['socialMedia']?['instagram'] ?? '';
  String get facebookUrl => _activeProfileData['socialMedia']?['facebook'] ?? '';

  // Service specific getters (Rates & Services)
  String get dailyRate => _activeProfileData['rates']?['daily'] ?? 'N/A';
  String get weeklyRate => _activeProfileData['rates']?['weekly']?['price']?.toString() ?? 'N/A';
  String get weeklyDays => _activeProfileData['rates']?['weekly']?['days']?.toString() ?? '5';
  String get monthlyRate => _activeProfileData['rates']?['monthly']?['price']?.toString() ?? 'N/A';
  String get monthlyDays => _activeProfileData['rates']?['monthly']?['days']?.toString() ?? '5';

  List<dynamic> get coreServices => List<dynamic>.from(_activeProfileData['services'] ?? []);
  List<String> get supportOptions => List<String>.from(_activeProfileData['capabilities']?['support'] ?? []);
  List<String> get handlingOptions => List<String>.from(_activeProfileData['capabilities']?['handling'] ?? []);
  List<String> get disciplinesSelected => List<String>.from(_activeApplicationData['disciplines'] ?? []);
  List<String> get horseLevels => List<String>.from(_activeApplicationData['horseLevels'] ?? []);
  List<String> get operatingRegions => List<String>.from(_activeApplicationData['regions'] ?? []);
  List<String> get travelPreferences {
    final raw = _activeProfileData['travelPreferences'] ?? [];
    if (raw is! List) return [];
    return raw.map((item) {
      if (item is Map) return item['region']?.toString() ?? item['name']?.toString() ?? '';
      return item.toString();
    }).where((s) => s.isNotEmpty).toList();
  }

  List get additionalServices => _activeProfileData['additionalServices'] ?? [];

  List<String> get photos {
    return {
      ..._safeList(_activeProfileData['media']),
      ..._safeList(_activeApplicationData['media']),
    }.toList();
  }
  List<String> _safeList(dynamic data) {
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }
  dynamic get cancellationPolicy {
    final data = _activeProfileData['cancellationPolicy'];

    if (data is String) {
      return data;
    } else if (data is Map) {
      return data['policy'] ?? 'Flexible (24+ hrs)';
    }
    return 'Flexible (24+ hrs)';
  }
  bool get isAcceptingRequests => vendorData['compliance']?['acceptingRequests'] ?? true;


}
