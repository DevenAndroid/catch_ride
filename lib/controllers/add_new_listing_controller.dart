import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/controllers/horse_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:catch_ride/models/tag_model.dart';
import 'package:path/path.dart' as path;

import 'explore_controller.dart';

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
  
  final ImagePicker _picker = ImagePicker();
  var localImages = <File>[].obs;
  var gender = 'Gelding'.obs;
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
  final locationController = TextEditingController();
  
  // Price and Inquire state for Step 2
  final Map<String, TextEditingController> minPriceControllers = {
    'Sale': TextEditingController(),
    'Annual Lease': TextEditingController(),
    'Short Term or Circuit Lease': TextEditingController(),
    'Weekly Lease': TextEditingController(),
  };
  final Map<String, TextEditingController> maxPriceControllers = {
    'Sale': TextEditingController(),
    'Annual Lease': TextEditingController(),
    'Short Term or Circuit Lease': TextEditingController(),
    'Weekly Lease': TextEditingController(),
  };
  final RxMap<String, bool> inquireForPrice = <String, bool>{
    'Sale': false,
    'Annual Lease': false,
    'Short Term or Circuit Lease': false,
    'Weekly Lease': false,
  }.obs;

  // Step 3
  var selectedListingTypes = <String>{'Sale', 'Annual Lease'}.obs;

  // Step 4
  var selectedProgramTags = <String>{}.obs;
  var selectedOpportunityTags = <String>{}.obs;
  var selectedExperienceTags = <String>{}.obs;
  var selectedPersonalityTags = <String>{}.obs;

  var programTags = <TagModel>[].obs;
  var opportunityTags = <TagModel>[].obs;
  var experienceTags = <TagModel>[].obs;
  var personalityTags = <TagModel>[].obs;

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
        final List data = results[0].body['data'] ?? [];
        programTags.assignAll(data.map((e) => TagModel.fromJson(e)).toList());
      }
      if (results[1].statusCode == 200) {
        final List data = results[1].body['data'] ?? [];
        opportunityTags.assignAll(data.map((e) => TagModel.fromJson(e)).toList());
      }
      if (results[2].statusCode == 200) {
        final List data = results[2].body['data'] ?? [];
        experienceTags.assignAll(data.map((e) => TagModel.fromJson(e)).toList());
      }
      if (results[3].statusCode == 200) {
        final List data = results[3].body['data'] ?? [];
        personalityTags.assignAll(data.map((e) => TagModel.fromJson(e)).toList());
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

      // 1. Upload Images
      List<String> imageUrls = [];
      for (var imageFile in localImages) {
        final url = await _uploadFile(imageFile);
        if (url != null) imageUrls.add(url);
      }

      // 2. Map name selections to IDs
      final programTagIds = selectedProgramTags.map((name) =>
        programTags.firstWhere((t) => t.name == name).id as String).toList();
      
      final opportunityTagIds = selectedOpportunityTags.map((name) =>
        opportunityTags.firstWhere((t) => t.name == name).id as String).toList();
        
      final personalityTagIds = selectedPersonalityTags.map((name) =>
        personalityTags.firstWhere((t) => t.name == name).id as String).toList();
        
      String? experienceLevelId;
      if (selectedExperienceTags.isNotEmpty) {
        experienceLevelId = experienceTags.firstWhere((t) => t.name == selectedExperienceTags.first).id as String;
      }

      final horseData = {
        'listingTitle': listingTitleController.text,
        'name': horseNameController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'height': heightController.text,
        'breed': breedController.text,
        'color': colorController.text,
        'gender': gender.value,
        'discipline': disciplineController.text,
        'description': descriptionController.text,
        'usefNumber': usefNumberController.text,
        'videoLink': videoLinkController.text,
        'images': imageUrls,
        'photo': imageUrls.isNotEmpty ? imageUrls.first : null,
        'listingTypes': selectedListingTypes.toList(),
        'programTags': programTagIds,
        'opportunityTags': opportunityTagIds,
        'experienceLevel': experienceLevelId,
        'personalityTags': personalityTagIds,
        'isActive': activeStatus.value,
        'location': locationController.text,
        'prices': {
          for (var type in selectedListingTypes)
            type: {
              'inquire': inquireForPrice[type] ?? false,
              'min': minPriceControllers[type]?.text,
              'max': maxPriceControllers[type]?.text,
            }
        },
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
        // Refresh profile and horse list to show new horse
        try {
          if (Get.isRegistered<ProfileController>()) {
            Get.find<ProfileController>().fetchProfile();
          }
          if (Get.isRegistered<HorseController>()) {
            final profile = Get.find<ProfileController>();
            final userId = profile.user.value?.id;
            if (userId != null) {
               Get.find<HorseController>().fetchHorses(refresh: true, trainerId: userId);
            }
          }
          if (Get.isRegistered<ExploreController>()) {
            Get.find<ExploreController>().fetchHorses();
          }
        } catch (e) {
          print('Could not refresh data: $e');
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
      Get.snackbar('Error', 'An unexpected error occurred: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isPublishing.value = false;
    }
  }
  Future<String?> _uploadFile(File file) async {
    try {
      final String fileName = path.basename(file.path);
      final FormData formData = FormData({
        'media': MultipartFile(
          file.path,
          filename: fileName,
          contentType: 'image/jpeg',
        ),
      });

      final response = await _apiService.postRequest(AppUrls.upload, formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body['data']['url'];
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> pickImage() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        localImages.addAll(images.map((x) => File(x.path)));
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  void removeLocalImage(int index) {
    if (localImages.length > index) {
      localImages.removeAt(index);
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

  bool validateStep1() {
    if (listingTitleController.text.trim().isEmpty) {
      _showError('Please enter the listing title');
      return false;
    }
    if (horseNameController.text.trim().isEmpty) {
      _showError('Please enter the horse name');
      return false;
    }
    if (locationController.text.trim().isEmpty) {
      _showError('Please enter the location');
      return false;
    }
    if (breedController.text.trim().isEmpty) {
      _showError('Please enter the breed');
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      _showError('Please enter a description');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    Get.snackbar(
      'Required',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
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
    minPriceControllers.forEach((_, c) => c.dispose());
    maxPriceControllers.forEach((_, c) => c.dispose());
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
