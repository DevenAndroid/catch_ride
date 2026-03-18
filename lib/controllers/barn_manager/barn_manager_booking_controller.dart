import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BarnManagerBookingController extends BookingController {
  Future<bool> createVendorBooking(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await Get.find<ApiService>().postRequest(
        AppUrls.createVendorBooking,
        data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Booking request sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF17B26A),
          colorText: Colors.white,
        );
        fetchBookings(type: 'sent');
        return true;
      } else {
        String msg =
            response.body?['message'] ?? 'Failed to send booking request';
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
