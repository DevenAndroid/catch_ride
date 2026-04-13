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
  final RxBool isGridView = true.obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoadMoreLoading = false.obs;
  final int limit = 15;
  final RxnInt ageMin = RxnInt();
  final RxnInt ageMax = RxnInt();
  final RxString breedFilter = ''.obs;
  final RxString genderFilter = ''.obs;
  final RxnDouble priceMin = RxnDouble();
  final RxnDouble priceMax = RxnDouble();
  final RxList<String> selectedTags = <String>[].obs;

  // Suggested search items
  final RxList<Map<String, String>> defaultLocations =
      <Map<String, String>>[].obs;
  final RxList<Map<String, String>> defaultVenues = <Map<String, String>>[].obs;

  void clearAllFilters() {
    searchQuery.value = '';
    location.value = '';
    showVenue.value = '';
    selectedDiscipline.value = 'All';
    startDate.value = null;
    endDate.value = null;
    ageMin.value = null;
    ageMax.value = null;
    breedFilter.value = '';
    genderFilter.value = '';
    priceMin.value = null;
    priceMax.value = null;
    selectedTags.clear();
  }

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

  Future<void> fetchHorses({bool isLoadMore = false}) async {
    if (selectedDiscipline.value == 'Services') {
      await fetchVendors(isLoadMore: isLoadMore);
      return;
    }

    if (isLoadMore) {
      if (!hasMore.value || isLoadMoreLoading.value) return;
      isLoadMoreLoading.value = true;
      currentPage.value++;
    } else {
      // Only show full-screen loader if we have no data yet
      if (horses.isEmpty && vendors.isEmpty) {
        isLoading.value = true;
      }
      currentPage.value = 1;
      hasMore.value = true;
      // Clear vendors when switching to/refreshing horses
      // vendors.clear(); // Removing this to prevent flicker when refreshing horses
    }

    try {
      final Map<String, String> queryParams = {};

      final currentUserId = _profileController.id;
      final trainerId = _profileController.trainerId;

      // Filter for active and approved horses only in Explore
      queryParams['isActive'] = 'true';
      queryParams['status'] = 'approved,available';
      queryParams['onlyApprovedTrainers'] = 'true';
      queryParams['page'] = currentPage.value.toString();
      queryParams['limit'] = limit.toString();

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

      // Add advanced filters
      if (ageMin.value != null) queryParams['ageMin'] = ageMin.value.toString();
      if (ageMax.value != null) queryParams['ageMax'] = ageMax.value.toString();
      if (breedFilter.value.isNotEmpty) queryParams['breed'] = breedFilter.value;
      if (genderFilter.value.isNotEmpty) queryParams['gender'] = genderFilter.value;
      if (priceMin.value != null) queryParams['priceMin'] = priceMin.value.toString();
      if (priceMax.value != null) queryParams['priceMax'] = priceMax.value.toString();
      if (selectedTags.isNotEmpty) queryParams['tags'] = selectedTags.join(',');

      final response = await _apiService.getRequest(
        AppUrls.horses,
        query: queryParams,
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<HorseModel> newHorses = data
            .map((e) => HorseModel.fromJson(e))
            .toList();

        if (isLoadMore) {
          horses.addAll(newHorses);
        } else {
          horses.assignAll(newHorses);
        }

        final pagination = response.body['pagination'];
        if (pagination != null) {
           hasMore.value = currentPage.value < (pagination['totalPages'] ?? 0);
        } else {
           hasMore.value = newHorses.length == limit;
        }

        _logger.i('Fetched ${newHorses.length} horses (Page ${currentPage.value})');
      } else {
        _logger.e('Failed to fetch horses: ${response.statusText}');
      }
    } catch (e) {
      _logger.e('Error fetching horses: $e');
    } finally {
      isLoading.value = false;
      isLoadMoreLoading.value = false;
    }
  }

  Future<void> fetchVendors({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (!hasMore.value || isLoadMoreLoading.value) return;
      isLoadMoreLoading.value = true;
      currentPage.value++;
    } else {
      isLoading.value = true;
      currentPage.value = 1;
      hasMore.value = true;
      // Clear horses when switching to/refreshing vendors
      horses.clear();
    }

    try {
      final Map<String, String> queryParams = {};
      queryParams['page'] = currentPage.value.toString();
      queryParams['limit'] = limit.toString();

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

        if (isLoadMore) {
          vendors.addAll(newVendors);
        } else {
          vendors.assignAll(newVendors);
        }

        final pagination = response.body['pagination'];
        if (pagination != null) {
           hasMore.value = currentPage.value < (pagination['totalPages'] ?? 0);
        } else {
           hasMore.value = newVendors.length == limit;
        }

        _logger.i('Fetched ${newVendors.length} vendors (Page ${currentPage.value})');
      } else {
        _logger.e('Failed to fetch vendors: ${response.statusText}');
      }
    } catch (e) {
      _logger.e('Error fetching vendors: $e');
    } finally {
      isLoading.value = false;
      isLoadMoreLoading.value = false;
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
