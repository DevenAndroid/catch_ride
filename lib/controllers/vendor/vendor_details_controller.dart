import 'package:catch_ride/services/api_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorDetailsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxString vendorId = ''.obs;
  final RxBool isLoading = true.obs;
  final RxMap vendorData = {}.obs;
  final RxList availabilityList = [].obs;
  final RxBool isAvailabilityLoading = false.obs;

  // Tabs management
  final RxInt selectedTabIndex = 0.obs;
  final RxList<String> availableServices = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final String? id = Get.parameters['id'] ?? Get.arguments?['id'];
    if (id != null) {
      vendorId.value = id;
      _setMockData(); // Use mock data for UI demo as requested by image
      fetchVendorDetails(id);
      fetchAvailability(id);
    } else {
      _setMockData(); // Ensure UI looks correct even without ID for now
      isLoading.value = false;
    }
  }

  void _setMockData() {
    vendorData.value = {
      'firstName': 'Charlotte',
      'lastName': 'Hayes',
      'businessName': 'Ring Ready Grooming',
      'bio': 'Experienced A/AA circuit groom with a strong background in the hunter/jumper industry. I\'ve worked with high-volume show barns across major circuits including Wellington, Ocala, Tryon, and the Northeast, managing daily care for multiple horses in a fast-paced, high-standard environment.',
      'profilePhoto': '',
      'coverImage': '',
      'paymentMethods': ['Venmo', 'Zelle', 'Cash'],
      'homeBase': {'city': 'Denver', 'state': 'Colorado', 'country': 'USA'},
      'socialMedia': {'instagram': 'https://instagram.com', 'facebook': 'https://facebook.com'},
      'assignedServices': [
        {
          'serviceType': 'Grooming',
          'profile': {
            'rates': {'dayRate': 250, 'weekRate': 1200, 'monthRate': 4500, 'weekDays': 6, 'monthDays': 24},
            'profileData': {
              'capabilities': {'support': ['Tacking & Untacking', 'Wrapping & Bandaging', 'Stall Upkeep & Daily Care']},
              'additionalServices': [
                {'name': 'Hunter Braiding Mane', 'price': 80},
                {'name': 'Jumper Braiding', 'price': 60}
              ],
              'media': ['', '', ''],
              'cancellationPolicy': {'policy': 'Cancellations must be made at least 24 hours in advance. Late cancellations may incur a fee or may not be eligible for a refund.'}
            }
          }
        },
        {'serviceType': 'Braiding'}
      ]
    };
    
    availabilityList.assignAll([
      {
        'startDate': '2026-03-10',
        'endDate': '2026-03-18',
        'location': {'city': 'Wellington', 'state': 'WEC Ocala'},
        'serviceTypes': ['Show Week Support', 'Fill In Daily Show Support'],
        'maxBookings': 6,
        'maxDays': 5,
        'notes': 'Prefer mornings. Experience with young horses.'
      },
      {
        'startDate': '2026-03-10',
        'endDate': '2026-03-18',
        'location': {'city': 'Wellington', 'state': 'WEC Ocala'},
        'serviceTypes': ['Show Week Support', 'Fill In Daily Show Support', 'Hunter Braiding Mane'],
        'maxBookings': 6,
        'maxDays': 5,
        'notes': 'Prefer mornings. Experience with young horses.'
      }
    ]);
    availableServices.assignAll(['Grooming', 'Braiding']);
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
      }
    } catch (e) {
      debugPrint('Error fetching vendor details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAvailability(String id) async {
    isAvailabilityLoading.value = true;
    try {
      final response = await _apiService.getRequest('/availability/vendor/$id');
      if (response.statusCode == 200 && response.body['success'] == true) {
        availabilityList.assignAll(response.body['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching availability: $e');
    } finally {
      isAvailabilityLoading.value = false;
    }
  }

  // Getters for display
  String get fullName => '${vendorData['firstName'] ?? ''} ${vendorData['lastName'] ?? ''}'.trim();
  String get businessName => vendorData['businessName'] ?? 'Independent';
  String get profilePhoto => vendorData['profilePhoto'] ?? '';
  String get coverImage => vendorData['coverImage'] ?? '';
  String get bio => vendorData['bio'] ?? '';
  String get location => vendorData['homeBase'] != null 
      ? '${vendorData['homeBase']['city'] ?? ''}, ${vendorData['homeBase']['state'] ?? ''}, ${vendorData['homeBase']['country'] ?? ''}'
      : 'N/A';
  
  List<String> get paymentMethods => List<String>.from(vendorData['paymentMethods'] ?? []);
  String get instagramUrl => vendorData['socialMedia']?['instagram'] ?? '';
  String get facebookUrl => vendorData['socialMedia']?['facebook'] ?? '';

  // Get current active service data
  Map get activeServiceData {
    if (availableServices.isEmpty) return {};
    final String serviceType = availableServices[selectedTabIndex.value];
    final List services = vendorData['assignedServices'] ?? [];
    return services.firstWhereOrNull((s) => s['serviceType'] == serviceType) ?? {};
  }

  // Service specific getters
  String get dailyRate => activeServiceData['profile']?['rates']?['dayRate']?.toString() ?? '0';
  String get weeklyRate => activeServiceData['profile']?['rates']?['weekRate']?.toString() ?? '0';
  String get monthlyRate => activeServiceData['profile']?['rates']?['monthRate']?.toString() ?? '0';
  int get weeklyDays => activeServiceData['profile']?['rates']?['weekDays'] ?? 6;
  int get monthlyDays => activeServiceData['profile']?['rates']?['monthDays'] ?? 24;

  List<String> get includedServices {
    final profile = activeServiceData['profile']?['profileData'] ?? {};
    final List<String> items = [];
    if (profile['capabilities']?['support'] != null) items.addAll(List<String>.from(profile['capabilities']['support']));
    if (profile['capabilities']?['handling'] != null) items.addAll(List<String>.from(profile['capabilities']['handling']));
    return items;
  }

  List get additionalServices {
    final profile = activeServiceData['profile']?['profileData'] ?? {};
    return profile['additionalServices'] ?? [];
  }

  List<String> get photos {
    final profile = activeServiceData['profile']?['profileData'] ?? {};
    return List<String>.from(profile['media'] ?? []);
  }

  String get cancellationPolicy {
    final profile = activeServiceData['profile']?['profileData'] ?? {};
    return profile['cancellationPolicy']?['policy'] ?? 'Standard 24-hour notice required.';
  }
}
