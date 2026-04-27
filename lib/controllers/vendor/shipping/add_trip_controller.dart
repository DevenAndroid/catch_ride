import 'package:catch_ride/controllers/vendor/shipping/shipping_trip_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/models/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTripController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final formKey = GlobalKey<FormState>();

  // Route Details
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final originFocusNode = FocusNode();
  final destinationFocusNode = FocusNode();
  final intermediateStopFocusNode = FocusNode();
  final rxDestinationTags = <String>[].obs;
  TripModel? editingTrip;

  // Schedule
  final rxStartDate = Rxn<DateTime>();
  final rxEndDate = Rxn<DateTime>();

  // Available Slots
  final rxMaxHorses = 6.obs;

  // Equipment & Setup
  final equipmentController = TextEditingController();

  // Route Notes
  final notesController = TextEditingController();

  // Intermediate Stops
  final rxAllowIntermediateStops = false.obs;
  final intermediateStopController = TextEditingController();
  final rxIntermediateStops = <String>[].obs;

  final isLoading = false.obs;
  final rxHorseShows = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHorseShows();
    final args = Get.arguments;
    if (args is Map && args['trip'] is TripModel) {
      editingTrip = args['trip'];
      _preFillTrip();
    }
  }

  void _preFillTrip() {
    if (editingTrip == null) return;
    originController.text = editingTrip!.origin ?? '';
    destinationController.text = editingTrip!.destination ?? '';
    rxDestinationTags.assignAll(editingTrip!.destinationTags ?? []);
    rxStartDate.value = editingTrip!.startDate;
    rxEndDate.value = editingTrip!.endDate;
    rxMaxHorses.value = editingTrip!.maxHorses;
    equipmentController.text = editingTrip!.equipmentDescription ?? '';
    notesController.text = editingTrip!.routeNotes ?? '';
    rxAllowIntermediateStops.value = editingTrip!.allowIntermediateStops;
    rxIntermediateStops.assignAll(editingTrip!.intermediateStops ?? []);
  }

  Future<void> fetchHorseShows() async {
    try {
      final response = await _apiService.getRequest('/horse-shows?limit=10000');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        if (body != null && body['success'] == true) {
          final List data = body['data'] ?? [];
          rxHorseShows.assignAll(data.cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      debugPrint('Error fetching horse shows: $e');
    }
  }

  void addDestinationTag(String tag) {
    if (tag.isNotEmpty && !rxDestinationTags.contains(tag)) {
      rxDestinationTags.add(tag);
    }
  }

  void removeDestinationTag(String tag) {
    rxDestinationTags.remove(tag);
  }

  void addIntermediateStop(String stop) {
    if (stop.isNotEmpty && !rxIntermediateStops.contains(stop)) {
      rxIntermediateStops.add(stop);
      intermediateStopController.clear();
    }
  }

  void removeIntermediateStop(String stop) {
    rxIntermediateStops.remove(stop);
  }

  void incrementHorses() => rxMaxHorses.value++;
  void decrementHorses() {
    if (rxMaxHorses.value > 1) rxMaxHorses.value--;
  }

  Future<void> listTrip() async {
    if (formKey.currentState!.validate()) {
      if (rxStartDate.value == null || rxEndDate.value == null) {
        Get.snackbar('Error', 'Please select start and end dates');
        return;
      }

      isLoading.value = true;
      try {
        final Map<String, dynamic> tripData = {
          'origin': originController.text,
          'destination': destinationController.text,
          'destinationTags': rxDestinationTags.toList(),
          'startDate': rxStartDate.value!.toIso8601String(),
          'endDate': rxEndDate.value!.toIso8601String(),
          'maxHorses': rxMaxHorses.value,
          'equipmentDescription': equipmentController.text,
          'routeNotes': notesController.text,
          'allowIntermediateStops': rxAllowIntermediateStops.value,
          'intermediateStops': rxIntermediateStops.toList(),
          'status': editingTrip?.status ?? 'Open',
        };

        final response = editingTrip != null
            ? await _apiService.putRequest('/trips/${editingTrip!.id}', tripData)
            : await _apiService.postRequest('/trips', tripData);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final body = response.body;
          if (body != null && body['success'] == true) {
            // Update ShippingTripController list if it exists
            if (Get.isRegistered<ShippingTripController>()) {
              Get.find<ShippingTripController>().fetchTrips();
            }

            Get.back();
            Get.snackbar(
              'Success',
              'Trip listed successfully!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar('Error', body?['message'] ?? 'Failed to list trip');
          }
        } else {
          Get.snackbar('Error', response.body?['message'] ?? response.statusText ?? 'Failed to list trip');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to list trip: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }
}
