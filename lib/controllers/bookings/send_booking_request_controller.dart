import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SendBookingRequestController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxMap vendorData = {}.obs;
  final RxString selectedService = ''.obs;
  final RxList availabilityList = [].obs;
  final RxBool isLoadingAvailability = false.obs;

  // Form fields
  final RxnString selectedRateType = RxnString();
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final RxnString selectedNumHorses = RxnString();
  final RxnString selectedLocation = RxnString();
  final RxnString selectedOrigin = RxnString();
  final RxnString selectedDestination = RxnString();
  final notesController = TextEditingController();
  final originController = TextEditingController();
  final destinationController = TextEditingController();

  final RxList<Map<String, dynamic>> additionalServicesList = <Map<String, dynamic>>[].obs;
  final RxList<String> selectedAdditionalIds = <String>[].obs;
  
  final RxList<Map<String, dynamic>> coreServicesList = <Map<String, dynamic>>[].obs;
  final RxList<String> selectedCoreServiceIds = <String>[].obs;
  
  final RxBool isSummaryVisible = false.obs;
  final RxDouble totalPrice = 0.0.obs;
  final RxDouble basePrice = 0.0.obs;
  final RxDouble additionalTotal = 0.0.obs;
  final RxList<Map<String, dynamic>> bookedServices = <Map<String, dynamic>>[].obs;

  double _parsePrice(dynamic v) {
    if (v == null) return 0.0;
    String s = v.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(s) ?? 0.0;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      vendorData.value = args['vendorData'] ?? {};
      selectedService.value = args['service'] ?? '';
      
      // Load additional services and rates
      final List services = vendorData['assignedServices'] ?? [];
      final activeService = services.firstWhere((s) => s['serviceType'] == selectedService.value, orElse: () => null);
      if (activeService != null) {
        final profileData = activeService['profile']?['profileData'] ?? {};
        final appData = activeService['application']?['applicationData'] ?? {};
        final servicesData = vendorData['servicesData'] ?? {};
        final flatData = servicesData['shipping'] ?? servicesData['transportation'] ?? {};

        final List additional = profileData['additionalServices'] ?? [];
        additionalServicesList.assignAll(additional.map((s) {
          final id = s['id'] ?? s['name'];
          return {
            'id': id,
            'name': s['name'],
            'price': _parsePrice(s['price']),
          };
        }).toList());

        final List core = profileData['services'] ?? [];
        final List<Map<String, dynamic>> mappedCore = core.whereType<Map<dynamic, dynamic>>().map((s) => {
          'id': s['id'] ?? s['name'],
          'name': s['name'],
          'price': _parsePrice(s['price']),
        }).toList();

        // For Shipping, if core services list is empty, try to pull from pricing/rates
        if (isShipping && mappedCore.isEmpty) {
          // Robust pricing resolution (mirrors VendorDetailsController)
          final pricing = profileData['pricing'] ?? flatData['pricing'] ?? appData['pricing'] ?? {};
          final rates = profileData['rates'] ?? flatData['rates'] ?? appData['rates'] ?? {};
          
          final basePrice = pricing['baseRate'] ?? rates['baseRate'] ?? rates['base'] ?? pricing['base'] ?? flatData['baseRate'] ?? appData['baseRate'];
          final loadedPrice = pricing['loadedRate'] ?? rates['loadedRate'] ?? rates['loaded'] ?? pricing['loaded'] ?? flatData['loadedRate'] ?? appData['loadedRate'];
          
          if (basePrice != null && basePrice.toString().toLowerCase() != 'n/a' && basePrice.toString() != '0') {
            mappedCore.add({
              'id': 'base_rate',
              'name': 'Base Rate',
              'price': _parsePrice(basePrice),
            });
          }
          if (loadedPrice != null && loadedPrice.toString().toLowerCase() != 'n/a' && loadedPrice.toString() != '0') {
            mappedCore.add({
              'id': 'loaded_rate',
              'name': 'Fully Loaded Rate',
              'price': _parsePrice(loadedPrice),
            });
          }
        }
        
        coreServicesList.assignAll(mappedCore);
      }
      
      // Auto-recalculate price when fields change
      everAll([selectedRateType, startDate, endDate, selectedNumHorses, selectedAdditionalIds, selectedCoreServiceIds], (_) => calculatePrice());
      
      // Fetch availability to populate locations
      fetchAvailability();
    }
  }

  Future<void> fetchAvailability() async {
    final id = vendorData['_id'] ?? vendorData['id'];
    if (id == null) return;

    isLoadingAvailability.value = true;
    try {
      final response = await _apiService.getRequest('/availability/vendors/$id');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List data = response.body['data'] ?? [];
        availabilityList.assignAll(data);
        
        // Initialize selection with first available after fetch
        final locations = availableLocations;
        if (locations.isNotEmpty) {
          if (selectedLocation.value == null) selectedLocation.value = locations.first;
          if (selectedOrigin.value == null) selectedOrigin.value = locations.first;
          if (selectedDestination.value == null && locations.length > 1) {
            selectedDestination.value = locations[1];
          } else if (selectedDestination.value == null) {
            selectedDestination.value = locations.first;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching availability: $e');
    } finally {
      isLoadingAvailability.value = false;
    }
  }

  String get homeLocation {
    final homeBase = vendorData['homeBase'] ?? _activeServiceData?['application']?['applicationData']?['homeBase'];
    if (homeBase == null) return '';
    
    final city = homeBase['city']?.toString() ?? '';
    final state = homeBase['state']?.toString() ?? '';
    
    if (city.isEmpty || state.isEmpty) return '';
    return '$city, $state';
  }

  List<String> get availableLocations {
    final List<String> locations = [];
    
    // 1. Add home location first
    final home = homeLocation;
    if (home.isNotEmpty) {
      locations.add('$home (Home)');
    }

    // 2. Add locations from availability
    for (var avail in availabilityList) {
      if (avail['showVenues'] != null && avail['showVenues'] is List) {
        locations.addAll(List<String>.from(avail['showVenues']));
      } else if (avail['showVenues'] != null && avail['showVenues'] is String && avail['showVenues'].toString().isNotEmpty) {
        locations.add(avail['showVenues'].toString());
      }
      
      if (avail['location'] != null && avail['location'] is Map) {
        final loc = avail['location'];
        final city = loc['city']?.toString() ?? '';
        final state = loc['state']?.toString() ?? '';
        if (city.isNotEmpty && state.isNotEmpty) {
          locations.add('$city, $state');
        }
      }
    }

    final uniqueLocations = locations.where((l) => l.isNotEmpty).toSet().toList();
    
    return uniqueLocations.isEmpty ? ['Other'] : uniqueLocations;
  }

  // Find availability dates for a specific location
  Map<String, DateTime?> getAllowedDatesForLocation(String? locationName) {
    if (locationName == null || locationName.contains('(Home)') || locationName == 'Other') {
      return {'start': null, 'end': null};
    }

    for (var avail in availabilityList) {
      bool match = false;
      if (avail['showVenues'] != null) {
        if (avail['showVenues'] is List && avail['showVenues'].contains(locationName)) match = true;
        else if (avail['showVenues'] == locationName) match = true;
      }
      
      if (!match && avail['location'] != null && avail['location'] is Map) {
        final loc = avail['location'];
        final city = loc['city']?.toString() ?? '';
        final state = loc['state']?.toString() ?? '';
        if ('$city, $state' == locationName) match = true;
      }

      if (match) {
        final sStr = avail['startDate'] ?? avail['specificDate'];
        final eStr = avail['endDate'] ?? avail['specificDate'];
        if (sStr != null && eStr != null) {
          return {
            'start': DateTime.tryParse(sStr),
            'end': DateTime.tryParse(eStr),
          };
        }
      }
    }
    return {'start': null, 'end': null};
  }

  bool get isBraiding => selectedService.value.toLowerCase().contains('braid');
  bool get isClipping => selectedService.value.toLowerCase().contains('clip');
  bool get isFarrier => selectedService.value.toLowerCase().contains('farrier');
  bool get isBodywork => selectedService.value.toLowerCase().contains('bodywork') || selectedService.value.toLowerCase().contains('massage');
  bool get isShipping => selectedService.value.toLowerCase().contains('ship') || selectedService.value.toLowerCase().contains('transport');

  void toggleCoreService(String id) {
    if (selectedCoreServiceIds.contains(id)) {
      selectedCoreServiceIds.remove(id);
    } else {
      selectedCoreServiceIds.add(id);
    }
  }

  void calculatePrice() {
    if ((!isBraiding && !isShipping && selectedRateType.value == null) || 
        ((isBraiding || isShipping) && selectedCoreServiceIds.isEmpty) || 
        startDate.value == null || endDate.value == null || selectedNumHorses.value == null) {
      totalPrice.value = 0.0;
      return;
    }

    final duration = endDate.value!.difference(startDate.value!).inDays + 1;
    final numHorses = int.tryParse(selectedNumHorses.value!) ?? 1;
    
    // Get rates from active search (mocking rates for now based on vendor data)
    final List services = vendorData['assignedServices'] ?? [];
    final activeService = services.firstWhere((s) => s['serviceType'] == selectedService.value, orElse: () => null);
    final rates = activeService?['profile']?['profileData']?['rates'] ?? {};

    if (isBraiding || isShipping) {
      double coreTotal = 0.0;
      for (var id in selectedCoreServiceIds) {
        final service = coreServicesList.firstWhereOrNull((s) => s['id'] == id);
        if (service != null) {
          coreTotal += (service['price'] as double) * numHorses;
        }
      }
      // Note: For shipping, this is technically a per-mile rate. 
      // Without a distance field, we treat this as the base cost or a simplified calculation.
      basePrice.value = coreTotal;
    } else {
      double rate = 0.0;
      if (selectedRateType.value!.startsWith('Day Rate')) {
        rate = double.tryParse(rates['daily']?.toString() ?? '250') ?? 250.0;
        basePrice.value = rate * duration * numHorses;
      } else if (selectedRateType.value!.startsWith('Week Rate')) {
        rate = double.tryParse(rates['weekly']?['price']?.toString() ?? '1200') ?? 1200.0;
        final weeks = (duration / 7).ceil();
        basePrice.value = rate * weeks * numHorses;
      } else if (selectedRateType.value!.startsWith('Month Rate')) {
         rate = double.tryParse(rates['monthly']?['price']?.toString() ?? '4500') ?? 4500.0;
         final months = (duration / 30).ceil();
         basePrice.value = rate * months * numHorses;
      }
    }

    double addOnTotal = 0.0;
    for (var id in selectedAdditionalIds) {
      final service = additionalServicesList.firstWhere((s) => s['id'] == id);
      addOnTotal += (service['price'] as double) * numHorses;
    }
    additionalTotal.value = addOnTotal;
    totalPrice.value = basePrice.value + additionalTotal.value;
    
    if (totalPrice.value > 0 && bookedServices.isNotEmpty) {
      isSummaryVisible.value = true;
    }
  }

  void editService(int index) {
    if (index < 0 || index >= bookedServices.length) return;
    
    final booking = bookedServices[index];
    
    selectedService.value = booking['serviceType'] ?? '';
    selectedRateType.value = booking['rateType']?.toString().isEmpty == true ? null : booking['rateType'];
    startDate.value = booking['startDate'];
    endDate.value = booking['endDate'];
    selectedNumHorses.value = booking['horses'];
    selectedLocation.value = booking['location'];
    notesController.text = booking['notes'] ?? '';
    selectedAdditionalIds.assignAll(List<String>.from(booking['additionalIds'] ?? []));
    selectedCoreServiceIds.assignAll(List<String>.from(booking['coreIds'] ?? []));
    
    bookedServices.removeAt(index);
    calculatePrice();
  }

  void toggleAdditionalService(String id) {
    if (selectedAdditionalIds.contains(id)) {
      selectedAdditionalIds.remove(id);
    } else {
      selectedAdditionalIds.add(id);
    }
  }

  bool validateForm() {
    if (startDate.value == null || endDate.value == null) {
      Get.snackbar('Validation Error', 'Please select start and end dates', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }
    if (selectedNumHorses.value == null) {
      Get.snackbar('Validation Error', 'Please select number of horses', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }

    if (isBraiding || isClipping || isFarrier || isBodywork || isShipping) {
      if (selectedCoreServiceIds.isEmpty) {
        Get.snackbar('Validation Error', 'Please select at least one service/rate', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }
      
      if (isShipping) {
        if (selectedOrigin.value == null || selectedDestination.value == null) {
          Get.snackbar('Validation Error', 'Please select origin and destination locations', backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
      } else {
        if (selectedLocation.value == null) {
          Get.snackbar('Validation Error', 'Please select a location', backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
      }
    } else {
      // General form (Grooming, etc)
      if (selectedRateType.value == null) {
        Get.snackbar('Validation Error', 'Please select a rate type', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }
      if (selectedLocation.value == null) {
        Get.snackbar('Validation Error', 'Please select a location', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }
    }
    return true;
  }

  void clearFormFields() {
    selectedRateType.value = null;
    startDate.value = null;
    endDate.value = null;
    selectedNumHorses.value = null;
    selectedLocation.value = null;
    selectedOrigin.value = null;
    selectedDestination.value = null;
    notesController.clear();
    originController.clear();
    destinationController.clear();
    selectedAdditionalIds.clear();
    selectedCoreServiceIds.clear();
    totalPrice.value = 0.0;
    basePrice.value = 0.0;
    additionalTotal.value = 0.0;
    isSummaryVisible.value = bookedServices.isNotEmpty;
  }

  void addServiceToSummary() {
    if (!validateForm()) return;

    bookedServices.add({
      'serviceType': selectedService.value,
      'rateType': selectedRateType.value ?? (isBraiding ? 'Braiding Service' : isShipping ? 'Shipping Service' : 'Service'),
      'startDate': startDate.value,
      'endDate': endDate.value,
      'horses': selectedNumHorses.value,
      'location': isShipping ? '${selectedOrigin.value} to ${selectedDestination.value}' : selectedLocation.value,
      'notes': notesController.text,
      'additionalIds': List<String>.from(selectedAdditionalIds),
      'coreIds': List<String>.from(selectedCoreServiceIds),
      'basePrice': basePrice.value,
      'totalPrice': totalPrice.value,
    });

    clearFormFields();
  }

  Future<void> sendRequest() async {
    // If there's something in the form but not yet 'added', we validate and include it
    final currentFormValid = (startDate.value != null || selectedNumHorses.value != null || selectedCoreServiceIds.isNotEmpty || selectedRateType.value != null);
    
    if (bookedServices.isEmpty && !currentFormValid) {
      Get.snackbar('Error', 'Please fill out the form or select a service', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Combine bookedServices + current form (if valid)
    final allBookings = List<Map<String, dynamic>>.from(bookedServices);
    if (currentFormValid) {
      if (!validateForm()) return;
      
      allBookings.add({
        'serviceType': selectedService.value,
        'rateType': selectedRateType.value ?? (isBraiding ? 'Braiding Service' : isShipping ? 'Shipping Service' : 'Service'),
        'startDate': startDate.value,
        'endDate': endDate.value,
        'horses': selectedNumHorses.value,
        'location': isShipping ? '${selectedOrigin.value} to ${selectedDestination.value}' : selectedLocation.value,
        'notes': notesController.text,
        'additionalIds': List<String>.from(selectedAdditionalIds),
        'coreIds': List<String>.from(selectedCoreServiceIds),
        'basePrice': basePrice.value,
        'totalPrice': totalPrice.value,
      });
    }

    final bookingController = Get.find<BookingController>();
    
    // We send them as an array or multiple requests
    bool allSuccess = true;
    for (var booking in allBookings) {
      final Map<String, dynamic> payload = {
        'vendorId': vendorData['_id'] ?? vendorData['id'],
        'serviceType': booking['serviceType'],
        'type': booking['serviceType'],
        'startDate': DateFormat('yyyy-MM-dd').format(booking['startDate']),
        'endDate': DateFormat('yyyy-MM-dd').format(booking['endDate']),
        'date': DateFormat('yyyy-MM-dd').format(booking['startDate']),
        'rateType': booking['rateType'],
        'numberOfHorses': booking['horses'],
        'location': booking['location'],
        'notes': booking['notes'],
        'additionalServices': booking['additionalIds'],
        'coreServices': booking['coreIds'],
        'price': booking['totalPrice'],
      };
      
      final success = await bookingController.createBooking(payload);
      if (!success) allSuccess = false;
    }

    if (allSuccess) {
      // Refresh chat requests/inbox just in case
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().fetchConversations();
      }
      
      Get.back();
      Get.snackbar('Success', 'Booking requests sent successfully!', backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  // Display Getters
  String get vendorFullName => '${vendorData['firstName'] ?? ''} ${vendorData['lastName'] ?? ''}'.trim();
  String get businessName => vendorData['businessName'] ?? 'Independent';
  String get profilePhoto => vendorData['profilePhoto'] ?? '';

  dynamic get _activeServiceData {
     final List services = vendorData['assignedServices'] ?? [];
     return services.firstWhere((s) => s['serviceType'] == selectedService.value, orElse: () => null);
  }

  String get locationStr {
    final homeBase = vendorData['homeBase'] ?? _activeServiceData?['application']?['applicationData']?['homeBase'];
    if (homeBase == null) return 'N/A';
    
    final city = homeBase['city'] ?? '';
    final state = homeBase['state'] ?? '';
    
    if (city.isEmpty || state.isEmpty) return 'N/A';
    return '$city, $state, ${homeBase['country'] ?? 'USA'}';
  }

  
  List<Map<String, dynamic>> get rateOptions {
    final List services = vendorData['assignedServices'] ?? [];
    final activeService = services.firstWhere((s) => s['serviceType'] == selectedService.value, orElse: () => null);
    final rates = activeService?['profile']?['profileData']?['rates'] ?? {};

    final List<Map<String, dynamic>> options = [];
    if (rates['daily'] != null) options.add({'label': 'Day Rate', 'price': '\$${rates['daily']}'});
    if (rates['weekly']?['price'] != null) options.add({'label': 'Week Rate (${rates['weekly']?['days'] ?? 6}d)', 'price': '\$${rates['weekly']['price']}'});
    if (rates['monthly']?['price'] != null) options.add({'label': 'Month Rate', 'price': '\$${rates['monthly']['price']}'});
    
    // Default if none set
    if (options.isEmpty) return [{'label': 'Day Rate', 'price': '\$250'}, {'label': 'Week Rate', 'price': '\$1200'}, {'label': 'Month Rate', 'price': '\$4500'}];
    return options;
  }
  
  List<String> get includedServices {
    final List services = vendorData['assignedServices'] ?? [];
    final activeService = services.firstWhere((s) => s['serviceType'] == selectedService.value, orElse: () => null);
    if (activeService == null) return [];
    
    final profile = activeService['profile']?['profileData'] ?? {};
    final List<String> items = [];
    if (profile['capabilities']?['support'] != null) items.addAll(List<String>.from(profile['capabilities']['support']));
    if (profile['capabilities']?['handling'] != null) items.addAll(List<String>.from(profile['capabilities']['handling']));
    return items;
  }
}
