import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorAvailabilityController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxList<VendorAvailabilityModel> availabilityBlocks = <VendorAvailabilityModel>[].obs;
  final RxBool isAcceptingRequests = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAvailability();
    _loadAcceptingRequestsStatus();
  }

  Future<void> fetchAvailability() async {
    isLoading.value = true;
    try {
      final String? userId = _authController.currentUser.value?.id;
      if (userId == null) return;

      final response = await _apiService.getRequest('/availability/vendors/$userId');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List data = response.body['data'] ?? [];
        availabilityBlocks.assignAll(data.map((e) => VendorAvailabilityModel.fromJson(e)).toList());
      }
    } catch (e) {
      debugPrint('Error fetching availability: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAcceptingRequestsStatus() async {
    // This status is part of the vendor profile
    final user = _authController.currentUser.value;
    if (user != null) {
      // In our model/backend, we might need a specific field for this.
      // For now, assume it's true or fetched via vendor/me
      try {
        final response = await _apiService.getRequest('/vendors/me');
        if (response.statusCode == 200) {
          isAcceptingRequests.value = response.body['data']['isAcceptingRequests'] ?? true;
        }
      } catch (e) {
        debugPrint('Error fetching accepting requests status: $e');
      }
    }
  }

  Future<void> toggleAcceptingRequests(bool value) async {
    isAcceptingRequests.value = value;
    try {
       // Sync with backend - updating vendor profile
       await _apiService.putRequest('/vendors/profile', {'isAcceptingRequests': value});
    } catch (e) {
      debugPrint('Error toggling accepting requests: $e');
      // Revert on error
      isAcceptingRequests.value = !value;
      Get.snackbar('Error', 'Failed to update status', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> deleteAvailabilityBlock(String id) async {
    try {
      final response = await _apiService.deleteRequest('/availability/vendors/$id');
      if (response.statusCode == 200) {
        availabilityBlocks.removeWhere((b) => b.id == id);
        Get.snackbar('Success', 'Availability block deleted', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to delete block', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Error deleting availability block: $e');
    }
  }

  Future<void> createAvailabilityBlock(Map<String, dynamic> payload) async {
    try {
      isLoading.value = true;
      final response = await _apiService.postRequest('/availability/vendors', payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Availability block added!', backgroundColor: Colors.green, colorText: Colors.white);
        await fetchAvailability(); // Refresh the list
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to add block', backgroundColor: Colors.red, colorText: Colors.white);
        throw Exception('Failed to create availability block');
      }
    } catch (e) {
      debugPrint('Error creating availability block: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}

