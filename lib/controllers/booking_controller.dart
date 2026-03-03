import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BookingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final Logger _logger = Logger();

  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;


  Future<void> fetchBookings({String? trainerId, String? clientId, String? status}) async {
    try {
      isLoading.value = true;
      final Map<String, String> query = {};
      if (trainerId != null) query['trainerId'] = trainerId;
      if (clientId != null) query['clientId'] = clientId;
      if (status != null) query['status'] = status;

      final response = await _apiService.getRequest(AppUrls.bookings, query: query);

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<BookingModel> newBookings = 
            data.map((e) => BookingModel.fromJson(e)).toList();
        bookings.assignAll(newBookings);
        _logger.i('Fetched ${bookings.length} bookings');
      } else {
        _logger.e('Failed to fetch bookings: ${response.statusText}');
      }
    } catch (e) {
      _logger.e('Error fetching bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBookingStatus(String id, String status) async {
    try {
      final response = await _apiService.putRequest('${AppUrls.bookings}/$id', {
        'status': status,
      });

      if (response.statusCode == 200) {
        // Refresh local bookings or update the specific one
        final index = bookings.indexWhere((b) => b.id == id);
        if (index != -1) {
          // Since it's immutable, fetching all again is safer or replace with new object
          fetchBookings(); // Simplified update
        }
        Get.snackbar('Success', 'Booking updated to $status');
      } else {
        _logger.e('Failed to update booking: ${response.statusText}');
        Get.snackbar('Error', 'Failed to update booking');
      }
    } catch (e) {
      _logger.e('Error updating booking: $e');
      Get.snackbar('Error', 'Something went wrong');
    }
  }
}
