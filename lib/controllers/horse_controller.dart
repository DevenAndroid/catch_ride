import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';

class HorseController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

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
    fetchHorses();
  }

  Future<void> fetchHorses({bool refresh = true, String? trainerId, int limit = 10}) async {
    if (refresh) {
      currentPage.value = 1;
      horses.clear();
      isLoading.value = true;
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

      final response = await _apiService.getRequest(AppUrls.horses, query: query);

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<HorseModel> newHorses = data.map((e) => HorseModel.fromJson(e)).toList();
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
}
