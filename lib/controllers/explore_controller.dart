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

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
    fetchHorses();
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
        queryParams['startDate'] = DateFormat('yyyy-MM-dd').format(startDate.value!);
      }

      if (endDate.value != null) {
        queryParams['endDate'] = DateFormat('yyyy-MM-dd').format(endDate.value!);
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

      final response = await _apiService.getRequest(AppUrls.vendors, query: queryParams);

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<VendorModel> newVendors = data.map((e) => VendorModel.fromJson(e)).toList();
        
        if (newVendors.isEmpty) {
          // Add static data for demonstration if no data from API
          vendors.assignAll([
            VendorModel(
              id: '1',
              firstName: 'Thomas',
              lastName: 'Martin',
              email: 'thomas@example.com',
              businessName: 'Martin Grooming',
              serviceType: 'Groom',
              location: 'Wellington, FL',
              status: 'active',
              profilePhoto: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1374&auto=format&fit=crop',
              serviceAvailability: [
                VendorAvailability(startDate: '10 Jan', endDate: '18 Jan 2026')
              ],
            ),
            VendorModel(
              id: '2',
              firstName: 'Thomas',
              lastName: 'Martin',
              email: 'thomas2@example.com',
              businessName: 'Martin Grooming',
              serviceType: 'Groom',
              location: 'Wellington, FL',
              status: 'active',
              profilePhoto: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1374&auto=format&fit=crop',
              serviceAvailability: [
                VendorAvailability(startDate: '10 Jan', endDate: '18 Jan 2026')
              ],
            ),
            VendorModel(
              id: '3',
              firstName: 'Thomas',
              lastName: 'Martin',
              email: 'thomas3@example.com',
              businessName: 'Martin Grooming',
              serviceType: 'Groom',
              location: 'Wellington, FL',
              status: 'active',
              profilePhoto: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=1470&auto=format&fit=crop',
              serviceAvailability: [
                VendorAvailability(startDate: '10 Jan', endDate: '18 Jan 2026')
              ],
            ),
            VendorModel(
              id: '4',
              firstName: 'Thomas',
              lastName: 'Martin',
              email: 'thomas4@example.com',
              businessName: 'Martin Grooming',
              serviceType: 'Groom',
              location: 'Wellington, FL',
              status: 'active',
              profilePhoto: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1376&auto=format&fit=crop',
              serviceAvailability: [
                VendorAvailability(startDate: '10 Jan', endDate: '18 Jan 2026')
              ],
            ),
          ]);
        } else {
          vendors.assignAll(newVendors);
        }
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
}
