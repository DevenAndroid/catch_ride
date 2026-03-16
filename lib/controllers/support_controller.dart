import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SupportController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final Logger _logger = Logger();

  final faqs = <Map<String, dynamic>>[].obs;
  final tickets = <Map<String, dynamic>>[].obs;
  final isLoadingFaqs = false.obs;
  final isLoadingTickets = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFaqs();
    fetchTickets();
  }

  Future<void> fetchFaqs({String? search}) async {
    try {
      isLoadingFaqs.value = true;
      
      // Building query params - GetConnect query values work best as strings
      final Map<String, dynamic> query = {
        'status': 'active',
        'limit': (search != null && search.isNotEmpty ? '10' : '3'),
      };
      
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }

      final response = await _apiService.getRequest(
        AppUrls.faqs,
        query: query,
      );

      if (response.statusCode == 200 && response.body != null) {
        final dynamic body = response.body;
        final dynamic data = body is Map ? body['data'] : null;

        if (data is List) {
          faqs.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
        } else {
          _logger.e('Unexpected data format (expected List): ${data.runtimeType}');
          faqs.clear();
        }
      } else {
        _logger.e('Failed to load FAQs: ${response.statusText} (${response.statusCode})');
        if (response.body != null) _logger.d('Response body: ${response.body}');
      }
    } catch (e) {
      _logger.e('Exception in fetchFaqs: $e');
    } finally {
      isLoadingFaqs.value = false;
    }
  }

  Future<void> fetchTickets() async {
    try {
      isLoadingTickets.value = true;
      final response = await _apiService.getRequest(AppUrls.supportTickets);

      if (response.statusCode == 200 && response.body != null) {
        final dynamic body = response.body;
        final dynamic data = body is Map ? body['data'] : null;

        if (data is List) {
          tickets.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
        }
      }
    } catch (e) {
      _logger.e('Error fetching tickets: $e');
    } finally {
      isLoadingTickets.value = false;
    }
  }

  Future<bool> submitTicket({
    required String subject,
    required String category,
    required String description,
  }) async {
    if (subject.isEmpty || category.isEmpty || description.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      final ticketData = {
        'subject': subject,
        'category': category,
        'description': description,
        'priority': 'medium', // Default
      };

      final response = await _apiService.postRequest(AppUrls.supportTickets, ticketData);

      _logger.i('📤 POST RESPONSE status: ${response.statusCode}');
      
      final bool isSuccess = response.isOk || 
                            (response.body != null && 
                             response.body is Map && 
                             response.body['success'] == true);

      if (isSuccess) {
        _logger.i('✅ Ticket submitted successfully');
        Get.snackbar(
          'Success',
          'Your message has been sent. We will get back to you soon!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF17B26A),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        // Use a slight delay to ensure the server has processed the write
        // even though MongoDB is generally fast enough.
        Future.delayed(const Duration(milliseconds: 500), () => fetchTickets());
        return true;
      } else {
        _logger.e('❌ Ticket submission failed logic block');
        String errorMsg = 'Failed to submit ticket';
        if (response.body != null && response.body is Map) {
          errorMsg = response.body['message'] ?? errorMsg;
        }
        
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e, stack) {
      _logger.e('💥 Exception submitting ticket: $e');
      _logger.e(stack);
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> submitFeedback({
    required String category,
    required String subject,
    required String message,
    int? rating,
  }) async {
    try {
      isSubmitting.value = true;
      final feedbackData = {
        'category': category,
        'subject': subject,
        'message': message,
        if (rating != null) 'rating': rating,
      };

      final response = await _apiService.postRequest(AppUrls.feedback, feedbackData);

      if (response.isOk) {
        Get.snackbar(
          'Success',
          'Thank you for your feedback!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF17B26A),
          colorText: Colors.white,
        );
        return true;
      } else {
        String errorMsg = 'Failed to submit feedback';
        if (response.body != null && response.body is Map) {
          errorMsg = response.body['message'] ?? errorMsg;
        }
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      _logger.e('Error submitting feedback: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
