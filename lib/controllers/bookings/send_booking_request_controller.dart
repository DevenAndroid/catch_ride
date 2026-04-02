import 'package:catch_ride/controllers/booking_controller.dart';
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

  final RxList<Map<String, dynamic>> additionalServices = <Map<String, dynamic>>[].obs;
  final RxList<String> selectedAdditionalIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      vendorData.value = args['vendorData'] ?? {};
      selectedService.value = args['service'] ?? '';
      
      // Load additional services for the chosen main service
      final List services = vendorData['assignedServices'] ?? [];
      final activeService = services.firstWhere((s) => s['serviceType'] == selectedService.value, orElse: () => null);
      if (activeService != null) {
        final List additional = activeService['profile']?['profileData']?['additionalServices'] ?? [];
        additionalServices.assignAll(additional.map((s) => {
          'id': s['id'] ?? s['name'], // Fallback to name if ID is missing
          'name': s['name'],
          'price': s['price'],
        }).toList());
      }
    }
  }

  void toggleAdditionalService(String id) {
    if (selectedAdditionalIds.contains(id)) {
      selectedAdditionalIds.remove(id);
    } else {
      selectedAdditionalIds.add(id);
    }
  }

  Future<void> sendRequest() async {
    if (selectedRateType.value == null) {
      Get.snackbar('Error', 'Please select a rate type', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (startDate.value == null || endDate.value == null) {
      Get.snackbar('Error', 'Please select start and end dates', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (selectedNumHorses.value == null) {
      Get.snackbar('Error', 'Please select number of horses', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final bookingController = Get.find<BookingController>();
    
    final Map<String, dynamic> payload = {
      'vendorId': vendorData['_id'] ?? vendorData['id'],
      'serviceType': selectedService.value,
      'startDate': DateFormat('yyyy-MM-dd').format(startDate.value!),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate.value!),
      'rateType': selectedRateType.value,
      'numberOfHorses': selectedNumHorses.value,
      'location': selectedLocation.value,
      'notes': notesController.text,
      'additionalServices': selectedAdditionalIds.toList(),
    };

    final success = await bookingController.createBooking(payload);
    if (success) {
      Get.snackbar('Success', 'Booking request sent successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      Get.back(); // Go back to vendor details
    }
  }

  // Display Getters
  String get vendorFullName => '${vendorData['firstName'] ?? ''} ${vendorData['lastName'] ?? ''}'.trim();
  String get businessName => vendorData['businessName'] ?? 'Independent';
  String get profilePhoto => vendorData['profilePhoto'] ?? '';
  String get locationStr => vendorData['homeBase'] != null 
      ? '${vendorData['homeBase']['city'] ?? ''}, ${vendorData['homeBase']['state'] ?? ''}, ${vendorData['homeBase']['country'] ?? ''}'
      : 'N/A';
  
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
