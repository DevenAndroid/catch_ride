import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';

class HorseController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());

  // State variables
  var horses = <HorseModel>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasNextPage = true.obs;

  @override
  void onInit() {
    super.onInit();
    // fetchHorses(); // Removed to prevent fetching all horses on init
  }

  Future<void> fetchHorses({
    bool refresh = true,
    String? trainerId,
    String? ownerId,
    int limit = 10,
  }) async {
    if (refresh) {
      currentPage.value = 1;
      if (horses.isEmpty) {
        isLoading.value = true;
      }
    } else {
      if (currentPage.value >= totalPages.value) return;
      isMoreLoading.value = true;
      currentPage.value++;
    }

    try {
      final Map<String, dynamic> query = {
        'page': currentPage.value.toString(),
        'limit': limit.toString(),
      };

      if (trainerId != null) {
        query['trainerId'] = trainerId;
      }
      if (ownerId != null) {
        query['ownerId'] = ownerId;
      }

      final response = await _apiService.getRequest(
        AppUrls.horses,
        query: query,
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        List<HorseModel> newHorses = data
            .map((e) => HorseModel.fromJson(e))
            .toList();
        final pagination = response.body['pagination'] ?? {};

        if (refresh) {
          horses.assignAll(newHorses);
        } else {
          horses.addAll(newHorses);
        }

        totalPages.value = pagination['totalPages'] ?? 1;
        hasNextPage.value = currentPage.value < totalPages.value;
      }
    } catch (e) {
      print('Error fetching horses: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }
  
  Future<bool> deleteHorse(String id) async {
    try {
      final response = await _apiService.deleteRequest("${AppUrls.horses}/$id");
      if (response.statusCode == 200 || response.statusCode == 204) {
        horses.removeWhere((h) => h.id == id);
        horses.refresh();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting horse: $e');
      return false;
    }
  }

  Future<bool> toggleHorseActive(String id, bool isActive) async {
    try {
      final response = await _apiService.putRequest(
        "${AppUrls.horses}/$id",
        {"isActive": isActive},
      );
      if (response.statusCode == 200) {
        final index = horses.indexWhere((h) => h.id == id);
        if (index != -1) {
          horses[index] = HorseModel.fromJson(response.body['data']);
          horses.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling horse status: $e');
      return false;
    }
  }
}
