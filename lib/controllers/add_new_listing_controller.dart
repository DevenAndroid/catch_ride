import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/constant/app_urls.dart';

class AddNewListingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    fetchTags();
  }

  // Loading state
  var isTagsLoading = false.obs;
  var isPublishing = false.obs;
  // Step 1
  final videoLinkController = TextEditingController();
  var uploadedImages = <String>[].obs;

  // Step 2
  final listingTitleController = TextEditingController();
  final horseNameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final breedController = TextEditingController();
  final colorController = TextEditingController();
  final disciplineController = TextEditingController();
  final descriptionController = TextEditingController();
  final usefNumberController = TextEditingController();

  // Step 3
  var selectedListingTypes = <String>{'Sale', 'Annual Lease'}.obs;

  // Step 4
  var selectedProgramTags = <String>{}.obs;
  var selectedOpportunityTags = <String>{}.obs;
  var selectedExperienceTags = <String>{}.obs;
  var selectedPersonalityTags = <String>{}.obs;

  var programTags = <String>[].obs;
  var opportunityTags = <String>[].obs;
  var experienceTags = <String>[].obs;
  var personalityTags = <String>[].obs;

  Future<void> fetchTags() async {
    try {
      isTagsLoading.value = true;
      
      // Fetch all tags in parallel
      final results = await Future.wait([
        _apiService.getRequest(AppUrls.programTags),
        _apiService.getRequest(AppUrls.opportunityTags),
        _apiService.getRequest(AppUrls.experienceLevels),
        _apiService.getRequest(AppUrls.personalityTags),
      ]);

      if (results[0].statusCode == 200) {
        programTags.assignAll((results[0].body['data'] as List).map((e) => e['name'] as String).toList());
      }
      if (results[1].statusCode == 200) {
        opportunityTags.assignAll((results[1].body['data'] as List).map((e) => e['name'] as String).toList());
      }
      if (results[2].statusCode == 200) {
        experienceTags.assignAll((results[2].body['data'] as List).map((e) => e['name'] as String).toList());
      }
      if (results[3].statusCode == 200) {
        personalityTags.assignAll((results[3].body['data'] as List).map((e) => e['name'] as String).toList());
      }
    } catch (e) {
      print('Error fetching tags: $e');
    } finally {
      isTagsLoading.value = false;
    }
  }

  Future<void> publishListing() async {
    try {
      isPublishing.value = true;
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final horseData = {
        'listingTitle': listingTitleController.text,
        'name': horseNameController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'height': heightController.text,
        'breed': breedController.text,
        'color': colorController.text,
        'discipline': disciplineController.text,
        'description': descriptionController.text,
        'usefNumber': usefNumberController.text,
        'videoLink': videoLinkController.text,
        'listingTypes': selectedListingTypes.toList(),
        'programTags': selectedProgramTags.toList(),
        'opportunityTags': selectedOpportunityTags.toList(),
        'experienceLevel': selectedExperienceTags.toList().isNotEmpty ? selectedExperienceTags.toList().first : null,
        'personalityTags': selectedPersonalityTags.toList(),
        'isActive': activeStatus.value,
        'showAvailability': availabilityEntries.map((e) => {
          'cityState': e.cityStateController.text,
          'showVenue': e.showVenueController.text,
          'startDate': e.startDateController.text,
          'endDate': e.endDateController.text,
        }).toList(),
      };

      final response = await _apiService.postRequest(AppUrls.horses, horseData);

      Get.back(); // Remove loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh profile to show new horse
        try {
          if (Get.isRegistered<ProfileController>()) {
            Get.find<ProfileController>().fetchProfile();
          }
        } catch (e) {
          print('Could not refresh profile: $e');
        }

        Get.back(); // Return to previous screen
        Get.snackbar('Success', 'Listing published successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to publish listing',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.back(); // Remove loading dialog
      Get.snackbar('Error', 'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isPublishing.value = false;
    }
  }

  // Step 5
  var activeStatus = true.obs;
  var availabilityEntries = <AvailabilityEntry>[
    AvailabilityEntry(id: 1),
    AvailabilityEntry(id: 2),
  ].obs;

  void addEntry() {
    int nextId = availabilityEntries.isEmpty
        ? 1
        : availabilityEntries.last.id + 1;
    availabilityEntries.add(AvailabilityEntry(id: nextId));
  }

  void removeEntry(int index) {
    if (availabilityEntries.length > index) {
      availabilityEntries[index].dispose();
      availabilityEntries.removeAt(index);
    }
  }

  void toggleListingType(String type) {
    if (selectedListingTypes.contains(type)) {
      selectedListingTypes.remove(type);
    } else {
      selectedListingTypes.add(type);
    }
    selectedListingTypes.refresh();
  }

  void toggleTag(RxSet<String> selectedTags, String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    selectedTags.refresh();
  }

  @override
  void onClose() {
    videoLinkController.dispose();
    listingTitleController.dispose();
    horseNameController.dispose();
    ageController.dispose();
    heightController.dispose();
    breedController.dispose();
    colorController.dispose();
    disciplineController.dispose();
    descriptionController.dispose();
    usefNumberController.dispose();
    for (var entry in availabilityEntries) {
      entry.dispose();
    }
    super.onClose();
  }
}

class AvailabilityEntry {
  final int id;
  final cityStateController = TextEditingController();
  final showVenueController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  AvailabilityEntry({required this.id});

  void dispose() {
    cityStateController.dispose();
    showVenueController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}
