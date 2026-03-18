import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/models/vendor_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final Logger _logger = Logger();

  final RxList<HorseModel> horses = <HorseModel>[].obs;
  final RxList<VendorModel> vendors = <VendorModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedDiscipline = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxString location = ''.obs;
  final RxString showVenue = ''.obs;
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final RxList<String> recentSearches = <String>[].obs;
  final RxBool isGridView = false.obs;

  // Suggested search items
  final RxList<Map<String, String>> defaultLocations =
      <Map<String, String>>[].obs;
  final RxList<Map<String, String>> defaultVenues = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
    fetchDefaultSearchMetadata();
    // fetchHorses(); // Removed to prevent fetching without profile exclusion filters
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? history = prefs.getStringList('recent_searches');
    if (history != null) {
      recentSearches.assignAll(history);
    }
  }

  Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    // Remove if already exists to move to top
    recentSearches.remove(query);
    recentSearches.insert(0, query);

    // Keep only last 5
    if (recentSearches.length > 5) {
      recentSearches.removeLast();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', recentSearches);
  }

  Future<void> fetchHorses() async {
    if (selectedDiscipline.value == 'Services') {
      await fetchVendors();
      return;
    }

    try {
      isLoading.value = true;
      // Clear vendors when switching to horses
      vendors.clear();

      final Map<String, String> queryParams = {};

      final currentUserId = _profileController.id;
      final trainerId = _profileController.trainerId;

      // Filter for active and approved horses only in Explore
      queryParams['isActive'] = 'true';
      queryParams['status'] = 'approved,available';
      queryParams['onlyApprovedTrainers'] = 'true';

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

      if (location.value.isNotEmpty) {
        queryParams['location'] = location.value;
      }

      if (showVenue.value.isNotEmpty) {
        queryParams['showVenue'] = showVenue.value;
      }

      if (startDate.value != null) {
        queryParams['startDate'] = DateFormat(
          'yyyy-MM-dd',
        ).format(startDate.value!);
      }

      if (endDate.value != null) {
        queryParams['endDate'] = DateFormat(
          'yyyy-MM-dd',
        ).format(endDate.value!);
      }

      final response = await _apiService.getRequest(
        AppUrls.horses,
        query: queryParams,
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<HorseModel> newHorses = data
            .map((e) => HorseModel.fromJson(e))
            .toList();
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

  Future<void> fetchVendors() async {
    try {
      isLoading.value = true;
      // Clear horses when switching to vendors
      horses.clear();

      final Map<String, String> queryParams = {};
      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }
      if (location.value.isNotEmpty) {
        queryParams['location'] = location.value;
      }

      final response = await _apiService.getRequest(
        AppUrls.vendors,
        query: queryParams,
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<VendorModel> newVendors = data
            .map((e) => VendorModel.fromJson(e))
            .toList();
        vendors.assignAll(newVendors);
        _logger.i('Fetched ${vendors.length} vendors');
      } else {
        _logger.e('Failed to fetch vendors: ${response.statusText}');
      }
    } catch (e) {
      _logger.e('Error fetching vendors: $e');
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

  Future<void> fetchDefaultSearchMetadata() async {
    try {
      final response = await _apiService.getRequest(
        AppUrls.horseShows,
        query: {'limit': '3'},
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];

        // Extract 3 unique locations (City, State)
        final List<Map<String, String>> locations = [];
        final List<Map<String, String>> venues = [];

        for (var show in data) {
          final city = show['city'] ?? '';
          final state = show['state'] ?? '';
          final venue = show['showVenue'] ?? '';

          if (city.isNotEmpty && state.isNotEmpty) {
            final locName = "$city, $state";
            if (!locations.any((l) => l['name'] == locName)) {
              locations.add({'name': locName});
            }
          }

          if (venue.isNotEmpty) {
            if (!venues.any((v) => v['name'] == venue)) {
              venues.add({'name': venue, 'subtitle': "$city, $state"});
            }
          }
        }

        defaultLocations.assignAll(locations);
        defaultVenues.assignAll(venues);
      }
    } catch (e) {
      _logger.e('Error fetching default search metadata: $e');
    }
  }
}
