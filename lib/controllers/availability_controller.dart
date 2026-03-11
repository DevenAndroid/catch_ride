import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvailabilityController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final HorseModel horse;

  AvailabilityController({required this.horse});

  var entries = <AvailabilityEntry>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialAvailability();
  }

  void _loadInitialAvailability() {
    if (horse.showAvailability.isNotEmpty) {
      entries.assignAll(horse.showAvailability.map((a) {
        final entry = AvailabilityEntry(id: DateTime.now().millisecondsSinceEpoch + a.hashCode);
        entry.cityStateController.text = a.cityState;
        entry.showVenueController.text = a.showVenue;
        entry.startDateController.text = a.startDate;
        entry.endDateController.text = a.endDate;
        entry.isActive.value = a.isActive;
        return entry;
      }).toList());
    } else {
      addEntry();
    }
  }

  void addEntry() {
    entries.add(AvailabilityEntry(id: entries.length + 1));
  }

  void removeEntry(int index) {
    if (entries.length > index) {
      entries[index].dispose();
      entries.removeAt(index);
    }
  }

  Future<bool> saveAvailability() async {
    try {
      isLoading.value = true;
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final availabilityData = entries.map((e) => {
        'cityState': e.cityStateController.text,
        'showVenue': e.showVenueController.text,
        'startDate': e.startDateController.text,
        'endDate': e.endDateController.text,
        'isActive': e.isActive.value,
      }).toList();

      final response = await _apiService.putRequest('${AppUrls.horses}/${horse.id}', {
        'showAvailability': availabilityData,
      });

      Get.back(); // Remove loading dialog

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Availability updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        return true;
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to update availability',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    for (var entry in entries) {
      entry.dispose();
    }
    super.onClose();
  }
}

class AvailabilityEntry {
  final int id;
  final cityStateController = TextEditingController();
  final showVenueController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  var isActive = true.obs;

  AvailabilityEntry({required this.id});

  void dispose() {
    cityStateController.dispose();
    showVenueController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}
