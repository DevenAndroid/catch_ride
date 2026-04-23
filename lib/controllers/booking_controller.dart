import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

class BookingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final Logger _logger = Logger();

  final RxList<BookingModel> receivedBookings = <BookingModel>[].obs;
  final RxList<BookingModel> sentBookings = <BookingModel>[].obs;

  // Keep this for backward compatibility and reactive triggers in other views (like Explore/Detail)
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> fetchBookings({
    String type = 'received',
    String? status,
    String? time,
  }) async {
    try {
      isLoading.value = true;
      final Map<String, String> query = {'type': type};
      if (status != null) query['status'] = status;
      if (time != null) query['time'] = time;

      final response = await _apiService.getRequest(
        AppUrls.myBookings,
        query: query,
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<BookingModel> newBookings = data
            .map((e) => BookingModel.fromJson(e))
            .toList();

        if (type == 'received') {
          receivedBookings.assignAll(newBookings);
        } else {
          sentBookings.assignAll(newBookings);
        }

        // Always update the master list for things like isRequested checks
        bookings.assignAll(type == 'sent' ? sentBookings : receivedBookings);

        _logger.i(
          'Fetched ${newBookings.length} $type bookings (time: $time, status: $status)',
        );
      } else {
        _logger.e('Failed to fetch bookings: ${response.statusText}');
      }
    } catch (e) {
      _logger.e('Error fetching bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createBooking(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await _apiService.postRequest(AppUrls.bookings, data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.i('Booking created successfully');
        // Refresh the 'Sent' bookings list in global state
        fetchBookings(type: 'sent');
        return true;
      } else {
        _logger.e('Failed to create booking: ${response.statusText}');
        String msg =
            response.body?['message'] ?? 'Failed to send booking request';
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          barBlur: 0,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      _logger.e('Error creating booking: $e');
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        barBlur: 0,
        margin: const EdgeInsets.all(16),
      );
      return false;
      } finally {
        isLoading.value = false;
      }
    }

    Future<dynamic> updateBookingStatus(String bookingId, String status) async {
      try {
        isLoading.value = true;
        final response = await _apiService.putRequest(
          '${AppUrls.bookings}/$bookingId',
          {'status': status},
        );

        if (response.statusCode == 200) {
          _logger.i('Booking status updated to $status');
          String successMsg = 'Booking status updated successfully';
          if (status == 'confirmed') successMsg = 'Booking accepted successfully';
          if (status == 'cancelled') successMsg = 'Booking cancelled successfully';
          if (status == 'rejected') successMsg = 'Booking declined successfully';

          Get.snackbar(
            'Success',
            successMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF17B26A),
            colorText: Colors.white,
          );
          // Refresh both lists to move the booking to the correct section
          fetchBookings(type: 'received');
          fetchBookings(type: 'sent');
          return response.body['data']; // Returns the updated booking object including conversationId
        } else {
          _logger.e('Failed to update booking status: ${response.statusText}');
          return null;
        }
      } catch (e) {
        _logger.e('Error updating booking status: $e');
        return null;
      } finally {
        isLoading.value = false;
      }
    }
}
