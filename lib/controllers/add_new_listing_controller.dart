import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/controllers/horse_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../models/horse_model.dart';
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
  var editingHorseId = RxnString();
  bool get isEditMode => editingHorseId.value != null;
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
  var selectedDiscipline = ''.obs;

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
  // Step 3 (Dynamic Tags)
  var tagTypes = <dynamic>[].obs;
  var selectedTags = <String>{}.obs;

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
      print('Error fetching tags: $e');
    } finally {
      isTagsLoading.value = false;
    }
  }

  void setInitialData(HorseModel horse) {
    editingHorseId.value = horse.id;
    listingTitleController.text = horse.listingTitle ?? '';
    horseNameController.text = horse.name;
    ageController.text = horse.age.toString();
    heightController.text = horse.height ?? '';
    breedController.text = horse.breed;
    colorController.text = horse.color ?? '';
    descriptionController.text = horse.description ?? '';
    usefNumberController.text = horse.usefNumber ?? '';
    videoLinkController.text = horse.videoLink ?? '';
    locationController.text = horse.location ?? '';
    gender.value = horse.gender;
    selectedDiscipline.value = horse.discipline ?? '';
    disciplineController.text = horse.discipline ?? '';
    activeStatus.value = horse.isActive;

    selectedListingTypes.assignAll(horse.listingTypes);

    // Remote images (keep them as strings, might need a separate list for UI)
    uploadedImages.assignAll(horse.images);

    // Availability
    availabilityEntries.clear();
    if (horse.showAvailability.isEmpty) {
      availabilityEntries.add(AvailabilityEntry(id: 1));
    } else {
      for (var i = 0; i < horse.showAvailability.length; i++) {
        final avail = horse.showAvailability[i];
        final entry = AvailabilityEntry(id: i + 1);
        entry.cityStateController.text = avail.cityState ?? '';
        entry.showVenueController.text = avail.showVenue ?? '';
        entry.showIdController.text = avail.showId ?? '';
        entry.startDateController.text = avail.startDate ?? '';
        entry.endDateController.text = avail.endDate ?? '';
        availabilityEntries.add(entry);
      }
    }

    // Tags
    final allTagIds = <String>{};
    for (var tag in horse.programTags) {
      if (tag.id != null) allTagIds.add(tag.id!);
    }
    for (var tag in horse.opportunityTags) {
      if (tag.id != null) allTagIds.add(tag.id!);
    }
    for (var tag in horse.personalityTags) {
      if (tag.id != null) allTagIds.add(tag.id!);
    }
    for (var tag in horse.tags) {
      if (tag.id != null) allTagIds.add(tag.id!);
    }
    if (horse.experienceLevel?.id != null)
      allTagIds.add(horse.experienceLevel!.id!);
    selectedTags.assignAll(allTagIds);

    // Prices
    if (horse.prices != null) {
      horse.prices!.forEach((type, data) {
        if (data is Map) {
          inquireForPrice[type] = data['inquire'] ?? false;
          minPriceControllers[type]?.text = data['min']?.toString() ?? '';
          maxPriceControllers[type]?.text = data['max']?.toString() ?? '';
        }
      });
    }
  }

  Future<void> publishListing() async {
    try {
      if (!validateStep5()) return;
      isPublishing.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 1. Upload Images (New ones from local)
      List<String> imageUrls = [
        ...uploadedImages,
      ]; // Start with existing images
      for (var imageFile in localImages) {
        final url = await _uploadFile(imageFile);
        if (url != null) imageUrls.add(url);
      }

      final horseData = {
        'listingTitle': listingTitleController.text,
        'name': horseNameController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'height': heightController.text,
        'breed': breedController.text,
        'color': colorController.text,
        'gender': gender.value,
        'discipline': selectedDiscipline.value,
        'description': descriptionController.text,
        'usefNumber': usefNumberController.text,
        'videoLink': videoLinkController.text,
        'images': imageUrls,
        'photo': imageUrls.isNotEmpty ? imageUrls.first : null,
        'listingTypes': selectedListingTypes.toList(),
        'tags': selectedTags.toList(),
        'isActive': activeStatus.value,
        'location': locationController.text,
        'prices': {
          for (var type in selectedListingTypes)
            type: {
              'inquire': inquireForPrice[type] ?? false,
              'min': minPriceControllers[type]?.text,
              'max': maxPriceControllers[type]?.text,
            },
        },
        'showAvailability': availabilityEntries
            .map(
              (e) => {
                'showId': e.showIdController.text.isEmpty
                    ? null
                    : e.showIdController.text,
                'cityState': e.cityStateController.text,
                'showVenue': e.showVenueController.text,
                'startDate': e.startDateController.text,
                'endDate': e.endDateController.text,
              },
            )
            .toList(),
      };

      final response = isEditMode
          ? await _apiService.putRequest(
              '${AppUrls.horses}/${editingHorseId.value}',
              horseData,
            )
          : await _apiService.postRequest(AppUrls.horses, horseData);

      Get.back(); // Remove loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh profile and horse list to show new horse
        try {
          if (Get.isRegistered<ProfileController>()) {
            Get.find<ProfileController>().fetchProfile();
          }
          if (Get.isRegistered<HorseController>()) {
            final profile = Get.find<ProfileController>();
            final tId = profile.trainerId;
            final uId = profile.id;

            if (tId.isNotEmpty) {
              Get.find<HorseController>().fetchHorses(
                refresh: true,
                trainerId: tId,
              );
            } else if (uId.isNotEmpty) {
              Get.find<HorseController>().fetchHorses(
                refresh: true,
                ownerId: uId,
              );
            }
          }
          if (Get.isRegistered<ExploreController>()) {
            Get.find<ExploreController>().fetchHorses();
          }
        } catch (e) {
          print('Could not refresh data: $e');
        }

        Get.back(); // Return to previous screen
        Get.snackbar(
          'Success',
          'Listing published successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response.body['message'] ?? 'Failed to publish listing',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Remove loading dialog
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
  var availabilityEntries = <AvailabilityEntry>[AvailabilityEntry(id: 1)].obs;

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

  bool validateStep2() {
    if (selectedListingTypes.isEmpty) {
      _showError('Please select at least one listing type');
      return false;
    }

    for (var type in selectedListingTypes) {
      final isInquire = inquireForPrice[type] ?? false;
      if (!isInquire) {
        final minPrice = minPriceControllers[type]?.text.trim() ?? '';
        final maxPrice = maxPriceControllers[type]?.text.trim() ?? '';

        if (minPrice.isEmpty) {
          _showError('Please enter the min price for $type');
          return false;
        }
        if (maxPrice.isEmpty) {
          _showError('Please enter the max price for $type');
          return false;
        }
      }
    }
    return true;
  }

  bool validateStep3() {
    for (var type in tagTypes) {
      if (type['isRequired'] == true) {
        final typeName = type['name'] ?? 'Tag';
        final List values = type['values'] ?? [];
        final allTypeIds = values.map((v) => v['_id'].toString()).toList();

        final hasSelection = selectedTags.any((id) => allTypeIds.contains(id));
        if (!hasSelection) {
          _showError('Please select at least one $typeName');
          return false;
        }
      }
    }
    return true;
  }

  bool validateStep5() {
    if (activeStatus.value) {
      if (availabilityEntries.isEmpty) {
        _showError('Please add at least one availability entry');
        return false;
      }

      bool anyFilled = false;
      for (var entry in availabilityEntries) {
        if (entry.showVenueController.text.trim().isNotEmpty ||
            entry.cityStateController.text.trim().isNotEmpty ||
            entry.startDateController.text.trim().isNotEmpty) {
          anyFilled = true;
          break;
        }
      }

      if (!anyFilled) {
        _showError('Please fill in at least one availability entry detail');
        return false;
      }
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
  final showIdController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  AvailabilityEntry({required this.id});

  void dispose() {
    cityStateController.dispose();
    showVenueController.dispose();
    showIdController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}
