import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/models/vendor_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'google_api_controller.dart';

class ExploreController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final  googleApiController = Get.put(GoogleApiController());
  final Logger _logger = Logger();
  final RxString locationType = 'City, State, or Region'.obs;
  final RxList<HorseModel> horses = <HorseModel>[].obs;
  final RxList<VendorModel> vendors = <VendorModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedDiscipline = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxString location = ''.obs;
  final RxString showVenue = ''.obs;
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final Rxn<DateTime> availableBy = Rxn<DateTime>();
  final RxList<String> recentSearches = <String>[].obs;
  final RxBool isGridView = true.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoadMoreLoading = false.obs;
  final int limit = 15;
  final RxnInt ageMin = RxnInt();
  final RxnInt ageMax = RxnInt();
  final RxnDouble heightMin = RxnDouble();
  final RxnDouble heightMax = RxnDouble();
  final RxString listingType = ''.obs;
  final RxString breedFilter = ''.obs;
  final RxString genderFilter = ''.obs;
  final RxnDouble priceMin = RxnDouble();
  final RxnDouble priceMax = RxnDouble();
  final RxList<String> selectedTags = <String>[].obs;

  final RxList<dynamic> tagTypes = <dynamic>[].obs;
  final RxBool isTagsLoading = false.obs;
  
  final RxList<dynamic> serviceTagTypes = <dynamic>[].obs;
  final RxBool isServiceTagsLoading = false.obs;
  final RxBool isServiceFilterApplied = false.obs;

  // Service Filters (Generic & Service-Specific)
  final RxnInt minExperience = RxnInt();
  final RxList<String> groomingServices = <String>[].obs;
  final RxList<String> braidingServices = <String>[].obs;
  final RxList<String> clippingServices = <String>[].obs;
  final RxList<String> farrierServices = <String>[].obs;
  final RxList<String> bodyworkServices = <String>[].obs;
  
  final RxList<String> groomingDisciplines = <String>[].obs;
  final RxList<String> groomingHorseLevels = <String>[].obs;
  final RxnDouble minDailyRate = RxnDouble();
  final RxnDouble maxDailyRate = RxnDouble();
  
  final RxString selectedServiceTab = 'Groom'.obs;
  final RxList<String> groomingSupport = <String>[].obs;
  final RxList<String> horseHandling = <String>[].obs;
  final RxList<String> additionalServices = <String>[].obs; // Also used as Add-ons
  final RxList<String> travelPreferences = <String>[].obs;
  final RxList<String> regionsCovered = <String>[].obs;
  final RxnInt horseMinCapacity = RxnInt();
  final RxnInt horseMaxCapacity = RxnInt();

  // Farrier specific
  final RxList<String> farrierIntake = <String>[].obs;
  final RxList<String> farrierTimeframe = <String>[].obs;
  final RxString farrierAvailabilityMode = ''.obs;

  // Bodywork specific
  final RxList<String> bodyworkTimeframe = <String>[].obs;
  final RxString bodyworkLocationType = ''.obs;

  // Shipping specific
  final RxString shippingStartLocation = ''.obs;
  final RxString shippingEndLocation = ''.obs;
  final RxList<String> shippingTravelScope = <String>[].obs;
  final RxList<String> shippingStallTypes = <String>[].obs;

  bool get isSearchActive =>
      searchQuery.value.isNotEmpty ||
      location.value.isNotEmpty ||
      showVenue.value.isNotEmpty ||
      regionsCovered.isNotEmpty ||
      (startDate.value != null && endDate.value != null) ||
      shippingStartLocation.value.isNotEmpty ||
      shippingEndLocation.value.isNotEmpty ||
      isServiceFilterApplied.value;

  // Suggested search items
  final RxList<Map<String, String>> defaultLocations =
      <Map<String, String>>[].obs;
  final RxList<Map<String, dynamic>> defaultVenues = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, String>> locationsSuggestions =
      <Map<String, String>>[].obs;
  final RxList<Map<String, dynamic>> venuesSuggestions =
      <Map<String, dynamic>>[].obs;
  final RxBool isSuggestionsLoading = false.obs;


  void clearAllFilters() {
    searchQuery.value = '';
    location.value = '';
    showVenue.value = '';
    selectedDiscipline.value = 'All';
    startDate.value = null;
    endDate.value = null;
    availableBy.value = null;
    ageMin.value = null;
    ageMax.value = null;
    heightMin.value = null;
    heightMax.value = null;
    listingType.value = '';
    breedFilter.value = '';
    genderFilter.value = '';
    priceMin.value = null;
    priceMax.value = null;
    selectedTags.clear();
    
    // Clear Grooming & Service Filters
    minExperience.value = null;
    groomingServices.clear();
    braidingServices.clear();
    clippingServices.clear();
    farrierServices.clear();
    bodyworkServices.clear();
    groomingDisciplines.clear();
    groomingHorseLevels.clear();
    minDailyRate.value = null;
    maxDailyRate.value = null;
    
    selectedServiceTab.value = 'Groom';
    groomingSupport.clear();
    horseHandling.clear();
    additionalServices.clear();
    travelPreferences.clear();
    regionsCovered.clear();
    horseMinCapacity.value = null;
    horseMaxCapacity.value = null;

    farrierIntake.clear();
    farrierTimeframe.clear();
    farrierAvailabilityMode.value = '';
    
    bodyworkTimeframe.clear();
    bodyworkLocationType.value = '';

    shippingStartLocation.value = '';
    shippingEndLocation.value = '';
    shippingTravelScope.clear();
    shippingStallTypes.clear();

    isServiceFilterApplied.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    // Start fetching horses immediately to show data as soon as possible
    fetchHorses();
    
    // Other metadata can be fetched in parallel
    _loadRecentSearches();
    fetchDefaultSearchMetadata();
    fetchTags();
    fetchServiceTags('Grooming');
  }

  Future<void> fetchTags() async {
    try {
      isTagsLoading.value = true;
      final response = await _apiService.getRequest(
        '${AppUrls.tagTypesWithValues}?category=Horse',
      );
      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        tagTypes.assignAll(data);
      }
    } catch (e) {
      _logger.e('Error fetching tags: $e');
    } finally {
      isTagsLoading.value = false;
    }
  }

  Future<void> fetchServiceTags(String category) async {
    try {
      //isServiceTagsLoading.value = true;
      final response = await _apiService.getRequest(
        '/system-config/tag-types/with-values?category=$category',
      );
      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        serviceTagTypes.assignAll(data);
      }
    } catch (e) {
      _logger.e('Error fetching $category tags: $e');
    } finally {
      isServiceTagsLoading.value = false;
    }
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
    if (recentSearches.length > 4) {
      recentSearches.removeLast();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', recentSearches);
  }

  Future<void> fetchHorses({bool isLoadMore = false, bool showLoading = true}) async {
    if (selectedDiscipline.value == 'Services') {
      await fetchVendors(isLoadMore: isLoadMore, showLoading: showLoading);
      return;
    }

    if (isLoadMore) {
      if (!hasMore.value || isLoadMoreLoading.value || isLoading.value) return;
      isLoadMoreLoading.value = true;
      currentPage.value++;
    } else {
      currentPage.value = 1;
      hasMore.value = true;
      if (showLoading) isLoading.value = true;
    }

    try {
      // Check for profile data to load to ensure excludeTrainerId is populated
      // but don't wait too long if it's already there
      if (_profileController.user.value == null && _profileController.isLoading.value) {
        int retries = 0;
        // Wait up to 2 seconds for profile data
        while (_profileController.user.value == null && retries < 20) {
          await Future.delayed(const Duration(milliseconds: 100));
          retries++;
        }
      }

      final Map<String, String> queryParams = {};

      final currentUserId = _profileController.id;
      final trainerId = _profileController.trainerId;

      // Filter for active and approved horses only in Explore
      queryParams['isActive'] = 'true';
      queryParams['status'] = 'approved,available';
      // queryParams['onlyApprovedTrainers'] = 'true';
      queryParams['page'] = currentPage.value.toString();
      queryParams['limit'] = limit.toString();

      // if (trainerId.isNotEmpty) {
      //   queryParams['excludeTrainerId'] = trainerId;
      // }
      // if (currentUserId.isNotEmpty) {
      //   queryParams['excludeOwnerId'] = currentUserId;
      // }

      if (selectedDiscipline.value != 'All') {
        queryParams['discipline'] = selectedDiscipline.value;
      }
      //
      // if (searchQuery.value.isNotEmpty) {
      //   queryParams['search'] = searchQuery.value;
      // }

      if (regionsCovered.isNotEmpty) {
        queryParams['location'] = regionsCovered.first;
      } else if (location.value.isNotEmpty) {
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
      
      if (availableBy.value != null) {
        queryParams['availableBy'] = DateFormat(
          'yyyy-MM-dd',
        ).format(availableBy.value!);
      }

      // Add advanced filters
      if (ageMin.value != null) queryParams['minAge'] = ageMin.value.toString();
      if (ageMax.value != null) queryParams['maxAge'] = ageMax.value.toString();
      if (heightMin.value != null)
        queryParams['minHeight'] = heightMin.value.toString();
      if (heightMax.value != null)
        queryParams['maxHeight'] = heightMax.value.toString();
      if (listingType.value.isNotEmpty)
        queryParams['listingType'] = listingType.value;
      if (breedFilter.value.isNotEmpty)
        queryParams['breed'] = breedFilter.value;
      if (genderFilter.value.isNotEmpty)
        queryParams['gender'] = genderFilter.value;
      if (priceMin.value != null)
        queryParams['minPrice'] = priceMin.value.toString();
      if (priceMax.value != null)
        queryParams['maxPrice'] = priceMax.value.toString();
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

        _logger.i(
          'Fetched ${newHorses.length} horses (Page ${currentPage.value})',
        );
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

  Future<void> fetchVendors({bool isLoadMore = false, bool showLoading = true}) async {
    if (isLoadMore) {
      if (!hasMore.value || isLoadMoreLoading.value || isLoading.value) return;
      isLoadMoreLoading.value = true;
      currentPage.value++;
    } else {
      currentPage.value = 1;
      hasMore.value = true;
      if (showLoading) isLoading.value = true;
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

      if (startDate.value != null) {
        queryParams['startDate'] = DateFormat('yyyy-MM-dd').format(startDate.value!);
      }

      if (endDate.value != null) {
        queryParams['endDate'] = DateFormat('yyyy-MM-dd').format(endDate.value!);
      }

      // Add grooming filters
      if (selectedDiscipline.value == 'Services' && isServiceFilterApplied.value) {
        String serviceTypeVal = '';
        if (selectedServiceTab.value == 'Groom') serviceTypeVal = 'Grooming';
        else if (selectedServiceTab.value == 'Braider') serviceTypeVal = 'Braiding';
        else if (selectedServiceTab.value == 'Clipping') serviceTypeVal = 'Clipping';
        else if (selectedServiceTab.value == 'Farrier') serviceTypeVal = 'Farrier';
        else if (selectedServiceTab.value == 'Bodywork') serviceTypeVal = 'Bodywork';
        else if (selectedServiceTab.value == 'Shipping') serviceTypeVal = 'Shipping';
        
        // If we have a serviceType and we are NOT just searching by region from overlay
        // (If regionsCovered is the ONLY thing and we are in 'Services' discipline, we might want all services)
        bool hasOtherFilters = groomingServices.isNotEmpty || braidingServices.isNotEmpty || 
                             clippingServices.isNotEmpty || farrierServices.isNotEmpty || 
                             bodyworkServices.isNotEmpty || groomingDisciplines.isNotEmpty || 
                             groomingHorseLevels.isNotEmpty || minDailyRate.value != null || 
                             maxDailyRate.value != null || minExperience.value != null;

        if (serviceTypeVal.isNotEmpty && (hasOtherFilters || regionsCovered.isEmpty)) {
          queryParams['serviceType'] = serviceTypeVal;
        }
        
        if (minExperience.value != null) {
          queryParams['minExperience'] = minExperience.value.toString();
        }
        if (groomingServices.isNotEmpty) {
          queryParams['groomingServices'] = groomingServices.join(',');
        }
        if (braidingServices.isNotEmpty) {
          queryParams['braidingServices'] = braidingServices.join(',');
        }
        if (clippingServices.isNotEmpty) {
          queryParams['clippingServices'] = clippingServices.join(',');
        }
        if (farrierServices.isNotEmpty) {
          queryParams['farrierServices'] = farrierServices.join(',');
        }
        if (bodyworkServices.isNotEmpty) {
          queryParams['bodyworkServices'] = bodyworkServices.join(',');
        }
        if (groomingDisciplines.isNotEmpty) {
          queryParams['disciplines'] = groomingDisciplines.join(',');
        }
        if (groomingHorseLevels.isNotEmpty) {
          queryParams['horseLevels'] = groomingHorseLevels.join(',');
        }
        if (minDailyRate.value != null) {
          queryParams['minDailyRate'] = minDailyRate.value.toString();
        }
        if (maxDailyRate.value != null) {
          queryParams['maxDailyRate'] = maxDailyRate.value.toString();
        }
        
        if (groomingSupport.isNotEmpty) {
          queryParams['support'] = groomingSupport.join(',');
        }
        if (horseHandling.isNotEmpty) {
          queryParams['handling'] = horseHandling.join(',');
        }
        if (additionalServices.isNotEmpty) {
          queryParams['additionalServices'] = additionalServices.join(',');
        }
        if (travelPreferences.isNotEmpty) {
          queryParams['travelPreferences'] = travelPreferences.join(',');
        }
        if (regionsCovered.isNotEmpty) {
          queryParams['regions'] = regionsCovered.join(',');
        }
        if (horseMinCapacity.value != null) {
          queryParams['minCapacity'] = horseMinCapacity.value.toString();
        }
        if (horseMaxCapacity.value != null) {
          queryParams['maxCapacity'] = horseMaxCapacity.value.toString();
        }

        // Farrier / Bodywork / Shipping specific
        if (farrierIntake.isNotEmpty) queryParams['intake'] = farrierIntake.join(',');
        if (farrierTimeframe.isNotEmpty) queryParams['timeframe'] = farrierTimeframe.join(',');
        if (farrierAvailabilityMode.value.isNotEmpty) queryParams['availabilityMode'] = farrierAvailabilityMode.value;

        if (bodyworkTimeframe.isNotEmpty) queryParams['bodyworkTimeframe'] = bodyworkTimeframe.join(',');
        if (bodyworkLocationType.value.isNotEmpty) queryParams['locationType'] = bodyworkLocationType.value;

        if (shippingStartLocation.value.isNotEmpty) queryParams['startLocation'] = shippingStartLocation.value;
        if (shippingEndLocation.value.isNotEmpty) queryParams['endLocation'] = shippingEndLocation.value;
        if (shippingTravelScope.isNotEmpty) queryParams['travelScope'] = shippingTravelScope.join(',');
        if (shippingStallTypes.isNotEmpty) queryParams['stallTypes'] = shippingStallTypes.join(',');
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

        _logger.i(
          'Fetched ${newVendors.length} vendors (Page ${currentPage.value})',
        );
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

  /// Default show-venue list from GET /horse-shows (Show Venue tab).
  Future<void> fetchDefaultShowVenues({int limit = 10}) async {
    try {
      isSuggestionsLoading.value = true;
      final response = await _apiService.getRequest(
        AppUrls.horseShows,
        query: {'limit': limit.toString()},
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<Map<String, dynamic>> venues = [];

        for (var show in data) {
          final name = show['name']?.toString().trim() ?? '';
          if (name.isEmpty) continue;
          if (!venues.any((v) => v['name'] == name)) {
            venues.add(Map<String, dynamic>.from(show));
          }
        }
        defaultVenues.assignAll(venues);
      }
    } catch (e) {
      _logger.e('Error fetching default show venues: $e');
    } finally {
      isSuggestionsLoading.value = false;
    }
  }

  Future<void> fetchDefaultSearchMetadata() async {
    try {
      final response = await _apiService.getRequest(
        AppUrls.horseShows,
        query: {'limit': '3'},
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];

        // Extract unique city/state pairs for the City tab
        final List<Map<String, String>> locations = [];

        for (var show in data) {
          final city = show['city'] ?? '';
          final state = show['state'] ?? '';

          if (city.isNotEmpty && state.isNotEmpty) {
            final locName = "$city, $state";
            if (!locations.any((l) => l['name'] == locName)) {
              locations.add({'name': locName});
            }
          }
        }

        defaultLocations.assignAll(
          locations.map((l) => {'label': l['name']!}).toList(),
        );
      }
      await fetchDefaultShowVenues(limit: 10);
    } catch (e) {
      _logger.e('Error fetching default search metadata: $e');
    }
  }

  Future<void> searchLocations(String query) async {
    if (selectedDiscipline.value == 'Services') {
      return searchVendorLocations(query);
    }

    if (query.isEmpty) {
      locationsSuggestions.clear();
      googleApiController.googleSuggestions.clear();
      return;
    }


    try {
      final response = await _apiService.getRequest(
        AppUrls.locationsSuggest,
        query: {'q': query, 'limit': '10'},
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<Map<String, String>> suggestions = [];

        for (var item in data) {
          final name = item['label'] ?? '';
          if (name.isNotEmpty) {
            if (!suggestions.any((s) => s['label'] == name)) {
              suggestions.add({'label': name});
            }
          }
        }
        locationsSuggestions.assignAll(suggestions);
      }
    } catch (e) {
      _logger.e('Error searching locations: $e');
    }
  }

  List<Map<String, String>> _mapVendorLocationSuggestions(List data) {
    final List<Map<String, String>> suggestions = [];
    final seen = <String>{};
    for (var item in data) {
      final label = item['label']?.toString().trim() ?? '';
      if (label.isEmpty) continue;
      final dedupeKey = label.toLowerCase();
      if (seen.contains(dedupeKey)) continue;
      seen.add(dedupeKey);
      final source = item['source']?.toString() ?? '';
      suggestions.add({
        'label': label,
        if (source.isNotEmpty) 'source': source,
      });
    }
    return suggestions;
  }

  Future<void> fetchDefaultVendorSearchMetadata() async {
    try {
      isSuggestionsLoading.value = true;
      final response = await _apiService.getRequest(
        AppUrls.vendorLocationSuggestions,
        query: {'limit': '20'},
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final all = _mapVendorLocationSuggestions(data);
        defaultLocations.assignAll(
          all.where((s) => s['source'] != 'show_venue').toList(),
        );
      }
    } catch (e) {
      _logger.e('Error fetching vendor location suggestions: $e');
    } finally {
      isSuggestionsLoading.value = false;
    }
  }

  Future<void> searchVendorLocations(String query) async {
    if (query.isEmpty) {
      locationsSuggestions.clear();
      return;
    }

    try {
      isSuggestionsLoading.value = true;
      final response = await _apiService.getRequest(
        AppUrls.vendorLocationSuggestions,
        query: {'q': query, 'limit': '10'},
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        locationsSuggestions.assignAll(
          _mapVendorLocationSuggestions(data)
              .where((s) => s['source'] != 'show_venue')
              .toList(),
        );
      }
    } catch (e) {
      _logger.e('Error searching vendor locations: $e');
    } finally {
      isSuggestionsLoading.value = false;
    }
  }

  Future<void> searchVendorVenues(String query) async {
    if (query.isEmpty) {
      venuesSuggestions.clear();
      return;
    }

    try {
      isSuggestionsLoading.value = true;
      final response = await _apiService.getRequest(
        AppUrls.vendorLocationSuggestions,
        query: {'q': query, 'limit': '10'},
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<Map<String, dynamic>> suggestions = [];
        for (var item in data) {
          final source = item['source']?.toString() ?? '';
          if (source != 'show_venue') continue;
          final label = item['label']?.toString() ?? '';
          if (label.isEmpty) continue;
          if (!suggestions.any((s) => s['name'] == label)) {
            suggestions.add({'name': label, 'label': label});
          }
        }
        venuesSuggestions.assignAll(suggestions);
      }
    } catch (e) {
      _logger.e('Error searching vendor venues: $e');
    } finally {
      isSuggestionsLoading.value = false;
    }
  }

  /// Show Venue tab search — GET /horse-shows only (not vendor location-suggestions).
  Future<void> searchVenues(String query) async {
    if (query.isEmpty) {
      venuesSuggestions.clear();
      return;
    }

    try {
      isSuggestionsLoading.value = true;
      final response = await _apiService.getRequest(
        AppUrls.horseShows,
        query: {'search': query, 'limit': '10'},
      );

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<Map<String, dynamic>> suggestions = [];

        for (var item in data) {
          final name = item['name']?.toString().trim() ?? '';
          if (name.isEmpty) continue;
          if (!suggestions.any((s) => s['name'] == name)) {
            suggestions.add(Map<String, dynamic>.from(item));
          }
        }
        venuesSuggestions.assignAll(suggestions);
      }
    } catch (e) {
      _logger.e('Error searching show venues: $e');
    } finally {
      isSuggestionsLoading.value = false;
    }
  }


}
