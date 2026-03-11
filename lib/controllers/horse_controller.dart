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

  Future<void> fetchHorses({bool refresh = true, String? trainerId, String? ownerId, int limit = 10}) async {
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
      if (ownerId != null) {
        query['ownerId'] = ownerId;
      }

      final response = await _apiService.getRequest(AppUrls.horses, query: query);

      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        List<HorseModel> newHorses = data.map((e) => HorseModel.fromJson(e)).toList();
        final pagination = response.body['pagination'] ?? {};

        // Add dummy data for development if list is empty
        if (newHorses.isEmpty && refresh) {
          newHorses = _getDummyHorses();
        }

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
      // Fallback to dummy data on error too
      if (refresh) {
        horses.assignAll(_getDummyHorses());
      }
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  List<HorseModel> _getDummyHorses() {
    return [
      HorseModel(
        id: '1',
        name: 'Golden Hour',
        breed: 'Warmblood',
        age: 8,
        gender: 'Gelding',
        listingTitle: 'Golden Hour - Top Children\'s Hunter',
        description: 'Lovely Children\'s Hunter with a great brain and an easy lead change. Brave, consistent, and forgiving...',
        location: 'Aiken, SC, USA',
        images: ['https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?q=80&w=800&auto=format&fit=crop'],
        listingTypes: ['For Sale', 'Weekly Lease'],
        trainerName: 'John Snow',
        trainerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
      ),
      HorseModel(
        id: '2',
        name: 'Moonshadow',
        breed: 'Thoroughbred',
        age: 6,
        gender: 'Mare',
        listingTitle: 'Moonshadow - Athletic Jumper Prospect',
        description: 'Scopey and careful jumper with plenty of heart. Ready to move up through the divisions with a dedicated rider.',
        location: 'Ocala, FL, USA',
        images: ['https://images.unsplash.com/photo-1598974357851-98166a9d9b45?q=80&w=800&auto=format&fit=crop'],
        listingTypes: ['Annual Lease'],
        trainerName: 'John Snow',
        trainerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
      ),
      HorseModel(
        id: '3',
        name: 'Zantura',
        breed: 'Dutch Warmblood',
        age: 10,
        gender: 'Mare',
        listingTitle: 'Zantura - Experienced Equitation Partner',
        description: 'Reliable and elegant mare with numerous wins in the equitation ring. Perfect for a rider looking to move up.',
        location: 'Wellington, FL, USA',
        images: ['https://images.unsplash.com/photo-1534067783941-51c9c23ecefd?q=80&w=800&auto=format&fit=crop'],
        listingTypes: ['For Sale'],
        trainerName: 'John Snow',
        trainerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
      ),
    ];
  }
}
