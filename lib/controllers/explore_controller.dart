import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ExploreController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final Logger _logger = Logger();

  final RxList<dynamic> horses = <dynamic>[].obs;
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
      
      final Map<String, String> queryParams = {
        'status': 'available', // Only show available horses
      };

      if (selectedDiscipline.value != 'All') {
        queryParams['discipline'] = selectedDiscipline.value;
      }

      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }

      final response = await _apiService.getRequest(AppUrls.horses, query: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['data'];
        horses.assignAll(data);
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
