import 'package:catch_ride/models/trip_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShippingTripController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<TripModel> trips = <TripModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getRequest('/trips/me');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        if (body != null && body['success'] == true) {
          final List data = body['data'] ?? [];
          trips.assignAll(data.map((json) => TripModel.fromJson(json)).toList());
        }
      } else {
        debugPrint('Failed to fetch trips: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      debugPrint('Error fetching trips: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFF13CA8B);
      case 'limited':
        return const Color(0xFFF79009);
      case 'full':
        return const Color(0xFFF04438);
      default:
        return Colors.grey;
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      final response = await _apiService.deleteRequest('/trips/$tripId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        if (body != null && body['success'] == true) {
          trips.removeWhere((t) => t.id == tripId);
          Get.snackbar('Success', 'Trip deleted successfully', backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar('Error', body?['message'] ?? 'Failed to delete trip');
        }
      } else {
        Get.snackbar('Error', 'Failed to delete trip');
      }
    } catch (e) {
      debugPrint('Error deleting trip: $e');
    }
  }
}
