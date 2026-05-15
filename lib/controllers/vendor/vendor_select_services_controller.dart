import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/system_config_controller.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/controllers/vendor/common_application_view.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorSelectServicesController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());
  final AuthController _authController = Get.put(AuthController());

  var isLoading = false.obs;
  var services = <String>[].obs;
  final selectedServices = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAvailableServices();
  }

  Future<void> fetchAvailableServices() async {
    isLoading.value = true;
    try {
      final Response response = await _apiService.getRequest(AppUrls.availableServices);
      if (response.statusCode == 200 && response.body['success'] == true) {
        services.value = List<String>.from(response.body['data']);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleService(String serviceName) {
    if (selectedServices.contains(serviceName)) {
      selectedServices.remove(serviceName);
    } else {
      if (selectedServices.length < 2) {
        selectedServices.add(serviceName);
      } else {
        Get.snackbar(
          'Limit Reached',
          'You can select a maximum of 2 services.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> submitServices() async {
    if (selectedServices.isEmpty) return;

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      var vendorId = prefs.getString('vendorId');

      final Response updateResponse = await _apiService.putRequest(
        '${AppUrls.vendors}/$vendorId',
        {
          'services': selectedServices.toList(),
        },
      );

      if (updateResponse.statusCode == 200 && updateResponse.body['success'] == true) {
        // Navigate to the Common Gateway Screen first
        Get.to(
          () => const CommonApplicationView(),
          arguments: {'remainingServices': selectedServices.toList()},
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save services: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
