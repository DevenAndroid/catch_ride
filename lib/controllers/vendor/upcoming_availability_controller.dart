import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/models/trip_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpcomingAvailabilityController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxString vendorId = ''.obs;
  final RxList<VendorAvailabilityModel> availabilityList = <VendorAvailabilityModel>[].obs;
  final RxList<dynamic> combinedList = <dynamic>[].obs;
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
    if (vendorId.value.isEmpty) {
      isLoading.value = false;
      return;
    }
    
    _currentPage = 1;
    isLoading.value = true;
    hasMore.value = true;
    
    try {
      final List<dynamic> localList = [];
      
      // Parallel fetch
      final responses = await Future.wait([
        _apiService.getRequest('/availability/vendors/${vendorId.value}?page=$_currentPage&limit=$_limit'),
        _apiService.getRequest('/trips/vendor/${vendorId.value}'),
      ]);

      final availabilityResponse = responses[0];
      final tripsResponse = responses[1];
      
      if (availabilityResponse.statusCode == 200 && availabilityResponse.body['success'] == true) {
        final List data = availabilityResponse.body['data'] ?? [];
        localList.addAll(data.map((e) => VendorAvailabilityModel.fromJson(e)).toList());
        if (data.length < _limit) hasMore.value = false;
      }

      if (tripsResponse.statusCode == 200 && tripsResponse.body['success'] == true) {
        final List tripsData = tripsResponse.body['data'] ?? [];
        localList.addAll(tripsData.map((e) {
          final map = Map<String, dynamic>.from(e);
          map['isTrip'] = true;
          return TripModel.fromJson(map);
        }).toList());
      }

      // Sort by date
      localList.sort((a, b) {
        DateTime? dateA;
        DateTime? dateB;

        if (a is VendorAvailabilityModel) {
          dateA = a.startDate ?? a.specificDate;
        } else if (a is TripModel) {
          dateA = a.startDate;
        }

        if (b is VendorAvailabilityModel) {
          dateB = b.startDate ?? b.specificDate;
        } else if (b is TripModel) {
          dateB = b.startDate;
        }

        return (dateA ?? DateTime(2099)).compareTo(dateB ?? DateTime(2099));
      });

      combinedList.assignAll(localList);
      availabilityList.assignAll(localList.whereType<VendorAvailabilityModel>().toList());

    } catch (e) {
      debugPrint('Error in fetchAvailability: $e');
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
