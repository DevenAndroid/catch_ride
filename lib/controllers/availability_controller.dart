import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AvailabilityController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final HorseModel horse;

  AvailabilityController({required this.horse});

  var entries = <AvailabilityEntry>[].obs;
  var isLoading = false.obs;
  var activeStatus = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialAvailability();
  }

  void _loadInitialAvailability() {
    activeStatus.value = horse.isActive;
    if (horse.showAvailability.isNotEmpty) {
      final DateFormat formatter = DateFormat('dd MMM yyyy');
      entries.assignAll(
        horse.showAvailability.map((a) {
          final entry = AvailabilityEntry(
            id: DateTime.now().millisecondsSinceEpoch + a.hashCode,
          );
          entry.cityStateController.text = a.cityState;
          entry.showVenueController.text = a.showVenue;
          entry.showIdController.text = a.showId ?? '';
          
          if (a.startDate.isNotEmpty) {
            try {
              final start = DateTime.parse(a.startDate);
              entry.startDateController.text = formatter.format(start);
            } catch (_) {
              entry.startDateController.text = a.startDate;
            }
          }
          
          if (a.endDate.isNotEmpty) {
            try {
              final end = DateTime.parse(a.endDate);
              entry.endDateController.text = formatter.format(end);
            } catch (_) {
              entry.endDateController.text = a.endDate;
            }
          }

          entry.isActive.value = a.isActive;
          return entry;
        }).toList(),
      );
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

      final availabilityData = entries
          .map(
            (e) => {
              'cityState': e.cityStateController.text,
              'showVenue': e.showVenueController.text,
              'showId': e.showIdController.text.isEmpty ? null : e.showIdController.text,
              'startDate': _formatDateForBackend(e.startDateController.text),
              'endDate': _formatDateForBackend(e.endDateController.text),
              'isActive': e.isActive.value,
            },
          )
          .toList();

      final response = await _apiService.putRequest(
        '${AppUrls.horses}/${horse.id}',
        {
          'showAvailability': availabilityData,
          'isActive': activeStatus.value,
        },
      );

      if (response.isOk) {
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.body?['message'] ?? 'Failed to update availability',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDateForBackend(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      // 1. Check if already ISO
      DateTime.parse(dateStr);
      return dateStr;
    } catch (_) {
      try {
        // 2. Parse human readable format
        final date = DateFormat('dd MMM yyyy').parse(dateStr);
        return date.toIso8601String();
      } catch (_) {
        return dateStr;
      }
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
  final showIdController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  var isActive = true.obs;

  AvailabilityEntry({required this.id});

  void dispose() {
    cityStateController.dispose();
    showVenueController.dispose();
    showIdController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}
