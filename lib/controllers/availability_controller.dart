import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'profile_controller.dart';
import 'horse_controller.dart';
import 'explore_controller.dart';

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
            final start = DateUtil.parse(a.startDate);
            if (start != null) {
              entry.startDateController.text = formatter.format(start);
            } else {
              entry.startDateController.text = a.startDate;
            }
          }
          
          if (a.endDate.isNotEmpty) {
            final end = DateUtil.parse(a.endDate);
            if (end != null) {
              entry.endDateController.text = formatter.format(end);
            } else {
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
        // Refresh screens
        try {
          if (Get.isRegistered<HorseController>()) {
            final profile = Get.find<ProfileController>();
            String tId = profile.trainerId;
            if (tId.isEmpty) {
              tId = profile.user.value?.linkedTrainer?.id ?? '';
            }
            final uId = profile.id;

            if (tId.isNotEmpty) {
              Get.find<HorseController>().fetchHorses(
                refresh: true,
                trainerId: tId,
              );
            } else if (uId.isNotEmpty) {
              Get.find<HorseController>().fetchHorses(
                refresh: true,
                ownerId: uId,
              );
            }
          }
          if (Get.isRegistered<ExploreController>()) {
            final explore = Get.find<ExploreController>();
            explore.fetchHorses();
           // explore.fetchVendors();
          }
        } catch (e) {
          print('Could not refresh data in availability: $e');
        }
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

  String? _formatDateForBackend(String dateStr) {
    if (dateStr.isEmpty) return null;
    final date = DateUtil.parse(dateStr);
    if (date != null) {
      return DateFormat('yyyy-MM-dd').format(date);
    }
    return dateStr;
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
