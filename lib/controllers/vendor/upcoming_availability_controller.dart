import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpcomingAvailabilityController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxString vendorId = ''.obs;
  final RxList<VendorAvailabilityModel> availabilityList = <VendorAvailabilityModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasMore = true.obs;
  
  int _currentPage = 1;
  final int _limit = 10;
  
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      vendorId.value = args['vendorId'] ?? '';
    }
    
    if (vendorId.isNotEmpty) {
      fetchAvailability();
    } else {
      isLoading.value = false;
    }
    
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
          !isMoreLoading.value &&
          hasMore.value) {
        fetchMoreAvailability();
      }
    });
  }

  Future<void> fetchAvailability() async {
    _currentPage = 1;
    isLoading.value = true;
    hasMore.value = true;
    
    try {
      final response = await _apiService.getRequest(
        '/availability/vendors/${vendorId.value}?page=$_currentPage&limit=$_limit'
      );
      
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List data = response.body['data'] ?? [];
        final list = data.map((e) => VendorAvailabilityModel.fromJson(e)).toList();
        availabilityList.assignAll(list);
        
        if (list.length < _limit) {
          hasMore.value = false;
        }
      }
    } catch (e) {
      debugPrint('Error fetching availability: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreAvailability() async {
    isMoreLoading.value = true;
    _currentPage++;
    
    try {
      final response = await _apiService.getRequest(
        '/availability/vendors/${vendorId.value}?page=$_currentPage&limit=$_limit'
      );
      
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List data = response.body['data'] ?? [];
        final list = data.map((e) => VendorAvailabilityModel.fromJson(e)).toList();
        
        if (list.isEmpty) {
          hasMore.value = false;
        } else {
          availabilityList.addAll(list);
          if (list.length < _limit) {
            hasMore.value = false;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching more availability: $e');
      _currentPage--;
    } finally {
      isMoreLoading.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
