import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ExploreController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final Logger _logger = Logger();

  final RxList<HorseModel> horses = <HorseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedDiscipline = 'All'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHorses();
  }

  Future<void> fetchHorses() async {
    try {
      isLoading.value = true;
      
      final Map<String, String> queryParams = {};

      final currentUserId = _profileController.id;
      final trainerId = _profileController.trainerId;
      
      if (trainerId.isNotEmpty) {
        queryParams['excludeTrainerId'] = trainerId;
      }
      if (currentUserId.isNotEmpty) {
        queryParams['excludeOwnerId'] = currentUserId;
      }

      if (selectedDiscipline.value != 'All') {
        queryParams['discipline'] = selectedDiscipline.value;
      }

      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }

      final response = await _apiService.getRequest(AppUrls.horses, query: queryParams);

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<HorseModel> newHorses = data.map((e) => HorseModel.fromJson(e)).toList();
        horses.assignAll(newHorses);
        _logger.i('Fetched ${horses.length} horses');
      } else {
        _logger.e('Failed to fetch horses: ${response.statusText}');
      }
    } catch (e) {
      _logger.e('Error fetching horses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateDiscipline(String discipline) {
    selectedDiscipline.value = discipline;
    fetchHorses();
  }

  void onSearch(String query) {
    searchQuery.value = query;
    fetchHorses();
  }
}
