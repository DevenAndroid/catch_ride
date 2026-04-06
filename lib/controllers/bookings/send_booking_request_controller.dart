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

  // Form fields
  final RxnString selectedRateType = RxnString();
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final RxnString selectedNumHorses = RxnString();
  final RxnString selectedLocation = RxnString('WEF, Wellington');
  final notesController = TextEditingController();

  final RxList<Map<String, dynamic>> additionalServicesList = <Map<String, dynamic>>[].obs;
  final RxList<String> selectedAdditionalIds = <String>[].obs;
  
  final RxList<Map<String, dynamic>> coreServicesList = <Map<String, dynamic>>[].obs;
  final RxList<String> selectedCoreServiceIds = <String>[].obs;
  
  final RxBool isSummaryVisible = false.obs;
  final RxDouble totalPrice = 0.0.obs;
  final RxDouble basePrice = 0.0.obs;
  final RxDouble additionalTotal = 0.0.obs;
  final RxList<Map<String, dynamic>> bookedServices = <Map<String, dynamic>>[].obs;

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
        final List additional = activeService['profile']?['profileData']?['additionalServices'] ?? [];
        additionalServicesList.assignAll(additional.map((s) => {
          'id': s['id'] ?? s['name'],
          'name': s['name'],
          'price': double.tryParse(s['price']?.toString() ?? '0') ?? 0.0,
        }).toList());

        final List core = activeService['profile']?['profileData']?['services'] ?? [];
        coreServicesList.assignAll(core.whereType<Map<dynamic, dynamic>>().map((s) => {
          'id': s['id'] ?? s['name'],
          'name': s['name'],
          'price': double.tryParse(s['price']?.toString() ?? '0') ?? 0.0,
        }).toList());
      }
      
      // Auto-recalculate price when fields change
      everAll([selectedRateType, startDate, endDate, selectedNumHorses, selectedAdditionalIds, selectedCoreServiceIds], (_) => calculatePrice());
    }
  }

  bool get isBraiding => selectedService.value.toLowerCase().contains('braid');

  void toggleCoreService(String id) {
    if (selectedCoreServiceIds.contains(id)) {
      selectedCoreServiceIds.remove(id);
    } else {
      selectedCoreServiceIds.add(id);
    }
  }

  void calculatePrice() {
    if ((!isBraiding && selectedRateType.value == null) || 
        (isBraiding && selectedCoreServiceIds.isEmpty) || 
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

    if (isBraiding) {
      double coreTotal = 0.0;
      for (var id in selectedCoreServiceIds) {
        final service = coreServicesList.firstWhere((s) => s['id'] == id);
        coreTotal += (service['price'] as double) * numHorses;
      }
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
    
    if (totalPrice.value > 0) {
      isSummaryVisible.value = true;
    }
  }

  void toggleAdditionalService(String id) {
    if (selectedAdditionalIds.contains(id)) {
      selectedAdditionalIds.remove(id);
    } else {
      selectedAdditionalIds.add(id);
    }
  }

  void clearFormFields() {
    selectedRateType.value = null;
    startDate.value = null;
    endDate.value = null;
    selectedNumHorses.value = null;
    selectedLocation.value = 'WEF, Wellington';
    notesController.clear();
    selectedAdditionalIds.clear();
    selectedCoreServiceIds.clear();
    totalPrice.value = 0.0;
    basePrice.value = 0.0;
    additionalTotal.value = 0.0;
    isSummaryVisible.value = bookedServices.isNotEmpty;
  }

  void addServiceToSummary() {
    if ((!isBraiding && selectedRateType.value == null) || 
        (isBraiding && selectedCoreServiceIds.isEmpty) || 
        startDate.value == null || endDate.value == null || selectedNumHorses.value == null) {
      Get.snackbar('Alert', 'Please complete the current service fields first', backgroundColor: Colors.orangeAccent);
      return;
    }

    bookedServices.add({
      'serviceType': selectedService.value,
      'rateType': selectedRateType.value ?? (isBraiding ? 'Braiding Service' : ''),
      'startDate': startDate.value,
      'endDate': endDate.value,
      'horses': selectedNumHorses.value,
      'location': selectedLocation.value,
      'notes': notesController.text,
      'additionalIds': List<String>.from(selectedAdditionalIds),
      'coreIds': List<String>.from(selectedCoreServiceIds),
      'basePrice': basePrice.value,
      'totalPrice': totalPrice.value,
    });

    clearFormFields();
  }

  Future<void> sendRequest() async {
    // If there's something in the form but not yet 'added', we might want to include it or alert
    if (bookedServices.isEmpty && (!isBraiding ? selectedRateType.value == null : selectedCoreServiceIds.isEmpty)) {
      Get.snackbar('Error', 'Please select at least one service', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Combine bookedServices + current form (if not empty)
    final allBookings = List<Map<String, dynamic>>.from(bookedServices);
    if ((!isBraiding && selectedRateType.value != null) || (isBraiding && selectedCoreServiceIds.isNotEmpty)) {
      allBookings.add({
        'serviceType': selectedService.value,
        'rateType': selectedRateType.value ?? (isBraiding ? 'Braiding Service' : ''),
        'startDate': startDate.value,
        'endDate': endDate.value,
        'horses': selectedNumHorses.value,
        'location': selectedLocation.value,
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
  String get locationStr => vendorData['homeBase'] != null 
      ? '${vendorData['homeBase']['city'] ?? ''}, ${vendorData['homeBase']['state'] ?? ''}, ${vendorData['homeBase']['country'] ?? ''}'
      : 'N/A';
  
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
