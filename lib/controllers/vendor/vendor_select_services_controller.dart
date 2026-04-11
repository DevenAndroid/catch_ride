import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/setup_groom_application_view.dart';
import 'package:catch_ride/view/vendor/braiding/profile_create/braiding_application_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_application_view.dart';
import 'package:catch_ride/view/vendor/farrier/create_profile/farrier_application_view.dart';
import 'package:catch_ride/view/vendor/bodywork/create_profile/bodywork_application_view.dart';
import 'package:catch_ride/view/vendor/shipping/create_profile/shipping_application_view.dart';
import 'package:catch_ride/controllers/auth_controller.dart';

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
      // 1. Get vendor ID
      final Response myVendorResponse = await _apiService.getRequest(AppUrls.myVendorProfile);
      if (myVendorResponse.statusCode != 200 || myVendorResponse.body['success'] != true) {
        // Fallback or retry?
        throw Exception('Failed to fetch your vendor profile');
      }
      final vendorData = myVendorResponse.body['data'];
      final vendorId = vendorData['id'] ?? vendorData['_id'];

      // 2. Update services selection
      final Map<String, dynamic> existingServicesData = Map<String, dynamic>.from(vendorData['servicesData'] ?? {});
      
      final Response updateResponse = await _apiService.putRequest(
        '${AppUrls.vendors}/$vendorId',
        {
          'services': selectedServices.toList(),
          'servicesData': existingServicesData,
          'isProfileCompleted': vendorData['isProfileCompleted'] ?? false, // Maintain existing status
          'isProfileSetup': vendorData['isProfileSetup'] ?? false,
        },
      );

      if (updateResponse.statusCode == 200 && updateResponse.body['success'] == true) {
        // Navigation logic
        final selectedList = selectedServices.toList();
        final firstService = selectedList.first;
        final remaining = selectedList.skip(1).toList();

        if (firstService == 'Grooming') {
          Get.to(
            () => const SetupGroomApplicationView(),
            arguments: {'remainingServices': remaining},
          );
        } else if (firstService == 'Braiding') {
          Get.to(
            () => const BraidingApplicationView(),
            arguments: {'remainingServices': remaining},
          );
        } else if (firstService == 'Clipping') {
          Get.to(
            () => const ClippingApplicationView(),
            arguments: {'remainingServices': remaining},
          );
        } else if (firstService == 'Farrier') {
          Get.to(
            () => const FarrierApplicationView(),
            arguments: {'remainingServices': remaining},
          );
        } else if (firstService == 'Bodywork') {
          Get.to(
            () => const BodyworkApplicationView(),
            arguments: {'remainingServices': remaining},
          );
        } else if (firstService == 'Shipping') {
          Get.to(
            () => const ShippingApplicationView(),
            arguments: {'remainingServices': remaining},
          );
        } else {
          // If other services don't have views yet, navigate based on role status
          _authController.navigateAfterRoleSet();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save services: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
