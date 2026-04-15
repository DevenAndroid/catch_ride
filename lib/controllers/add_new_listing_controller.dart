import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/controllers/horse_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../constant/app_colors.dart';
import '../models/horse_model.dart';
import '../widgets/common_text.dart';
import 'explore_controller.dart';

class AddNewListingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    fetchTags();
    ageController.addListener(_onAgeChanged);
  }

  final List<String> breeds = [
    'Dutch Warmblood',
    'Oldenburg',
    'Hanoverian',
    'Holsteiner',
    'Selle Français',
    'Westphalian',
    'Trakehner',
    'Belgian Warmblood',
    'Danish Warmblood',
    'Swedish Warmblood',
    'Irish Sport Horse',
    'German Sport Horse (DSP)',
    'Zangersheide',
    'Warmblood Cross',
    'Thoroughbred',
    'Thoroughbred Cross',
    'Anglo European Sport Horse',
    'American Warmblood',
    'Welsh Pony',
    'Welsh Cob',
    'Connemara',
    'German Riding Pony',
    'Pony of the Americas',
    'Crossbred Pony',
    'Other',
  ];

  final List<String> colors = [
    'Bay',
    'Dark Bay',
    'Chestnut',
    'Black',
    'Gray',
    'Roan',
    'Palomino',
    'Buckskin',
    'Paint / Pinto',
    'Other',
  ];

  // Loading state
  var isTagsLoading = false.obs;
  var isPublishing = false.obs;

  final ImagePicker picker = ImagePicker();
  var localImages = <File>[].obs;
  var localVideos = <File>[].obs;
  var gender = 'Gelding'.obs;
  var editingHorseId = RxnString();
  bool get isEditMode => editingHorseId.value != null;
  var selectedColor = ''.obs;
  // Step 1
  final videoLinkController = TextEditingController();
  var uploadedImages = <String>[].obs;
  var uploadedVideos = <String>[].obs;

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
  var selectedDisciplines = <String>{}.obs;
  var calculatedAge = 0.obs;

  void _onAgeChanged() {
    final year = int.tryParse(ageController.text);
    if (year != null && year > 1900 && year <= DateTime.now().year) {
      calculatedAge.value = DateTime.now().year - year;
    } else {
      calculatedAge.value = 0;
    }
  }

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
    // Back-calculate Year Foaled from Age
    if (horse.age > 0 && horse.age < 100) {
      ageController.text = (DateTime.now().year - horse.age).toString();
    } else {
      ageController.text = horse.age.toString();
    }
    calculatedAge.value = horse.age;
    heightController.text = horse.height ?? '';
    breedController.text = horse.breed;
    colorController.text = horse.color ?? '';
    selectedColor.value = horse.color ?? '';
    descriptionController.text = horse.description ?? '';
    usefNumberController.text = horse.usefNumber ?? '';
    videoLinkController.text = horse.videoLink ?? '';
    locationController.text = horse.location ?? '';
    gender.value = horse.gender;
    selectedDisciplines.assignAll(horse.disciplines);
    disciplineController.text = horse.disciplines.join(', ');
    activeStatus.value = horse.isActive;

    selectedListingTypes.assignAll(horse.listingTypes);

    // Remote images and videos (separate them)
    uploadedImages.clear();
    uploadedVideos.clear();

    bool isVideo(String url) {
      final String lower = url.toLowerCase();
      return lower.contains('horsevideos') ||
          lower.endsWith('.mp4') ||
          lower.endsWith('.mov') ||
          lower.endsWith('.avi') ||
          lower.endsWith('.wmv') ||
          lower.endsWith('.webm') ||
          lower.endsWith('.mkv');
    }

    final Set<String> processedUrls = {};

    // 1. Handle primary photo
    if (horse.photo != null && horse.photo!.isNotEmpty) {
      if (isVideo(horse.photo!)) {
        uploadedVideos.add(horse.photo!);
      } else {
        uploadedImages.add(horse.photo!);
      }
      processedUrls.add(horse.photo!);
    }

    // 2. Handle videoLink if it's a direct video URL
    if (horse.videoLink != null && horse.videoLink!.isNotEmpty && horse.videoLink != 'N/A') {
      if (isVideo(horse.videoLink!)) {
        if (!processedUrls.contains(horse.videoLink!)) {
          uploadedVideos.add(horse.videoLink!);
          processedUrls.add(horse.videoLink!);
        }
      }
    }

    // 3. Handle images array
    for (var url in horse.images) {
      if (processedUrls.contains(url)) continue;

      if (isVideo(url)) {
        uploadedVideos.add(url);
      } else {
        uploadedImages.add(url);
      }
      processedUrls.add(url);
    }

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

      // 1. Upload Media
      List<String> finalImages = [
        ...uploadedImages,
        ...uploadedVideos,
      ];
      
      for (var imageFile in localImages) {
        final url = await _uploadFile(imageFile);
        if (url != null) {
          finalImages.add(url);
        } else {
          Get.back();
          Get.snackbar('Error', 'Failed to upload image',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
          isPublishing.value = false;
          return;
        }
      }
      
      for (var videoFile in localVideos) {
        final url = await _uploadFile(videoFile);
        if (url != null) {
          finalImages.add(url);
        } else {
          Get.back();
          Get.snackbar('Error', 'Failed to upload video',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
          isPublishing.value = false;
          return;
        }
      }
 
      final horseData = {
        'listingTitle': listingTitleController.text,
        'name': horseNameController.text,
        'age': calculatedAge.value,
        'height': heightController.text,
        'breed': breedController.text,
        'color': colorController.text,
        'gender': gender.value,
        'discipline': selectedDisciplines.toList(),
        'description': descriptionController.text,
        'usefNumber': usefNumberController.text,
        'videoLink': videoLinkController.text,
        'images': finalImages.whereType<String>().toList(),
        'photo': uploadedImages.isNotEmpty ? uploadedImages.first : (finalImages.isNotEmpty ? finalImages.first : null),
        'listingTypes': selectedListingTypes.toList(),
        'tags': selectedTags.toList(),
        'isActive': activeStatus.value,
        'location': locationController.text,
        'prices': {
          for (var type in selectedListingTypes)
            type: {
              'inquire': inquireForPrice[type] ?? false,
              'min': minPriceControllers[type]?.text.replaceAll(',', ''),
              'max': maxPriceControllers[type]?.text.replaceAll(',', ''),
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
          'Horse Listed successfully',
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
      final String extension = path.extension(file.path).toLowerCase();
      String contentType = 'image/jpeg';
      
      if (extension == '.mp4' || extension == '.mov' || extension == '.avi') {
        contentType = 'video/mp4';
      } else if (extension == '.png') {
        contentType = 'image/png';
      }

      final FormData formData = FormData({
        'media': MultipartFile(
          file.path,
          filename: fileName,
          contentType: contentType,
        ),
      });

      final String type = (extension == '.mp4' || extension == '.mov' || extension == '.avi') ? 'video' : 'horse';
      
      final response = await _apiService.postRequest(
        "${AppUrls.upload}?type=$type",
        formData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body['data']['url'];
      } else {
        print('Upload failed with status: ${response.statusCode}');
        print('Response body: ${response.bodyString}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> pickImage() async {
    try {
      if (localImages.isEmpty) {
        final List<XFile> images = await picker.pickMultiImage(imageQuality: 80, maxWidth:  1600, // Profile is smaller, banner can be wider
          maxHeight:  1600,);
        if (images.isNotEmpty) {
          localImages.addAll(images.map((x) => File(x.path)));
        }
      } else {
        // Subsequent selection: choice of image or video
        _showMediaPicker();
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

  void _showMediaPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CommonText(
              'Select Media Type',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.image, color: AppColors.primary),
              title: const Text('Add Images'),
              onTap: () async {
                Get.back();
                final List<XFile> images = await picker.pickMultiImage(imageQuality:80,  maxWidth:  1600, // Profile is smaller, banner can be wider
                  maxHeight:  1600,);
                if (images.isNotEmpty) {
                  localImages.addAll(images.map((x) => File(x.path)));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: AppColors.primary),
              title: const Text('Add Video'),
              onTap: () async {
                Get.back();
                final XFile? video = await picker.pickVideo(source: ImageSource.gallery,);
                if (video != null) {
                  final file = File(video.path);
                  if (file.lengthSync() > 200 * 1024 * 1024) {
                    Get.snackbar(
                      'Error',
                      'Video size exceeds 200 MB limit',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  } else {
                    localVideos.add(file);
                  }
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void removeVideo(int index) {
    if (localVideos.length > index) {
      localVideos.removeAt(index);
    }
  }

  void removeUploadedVideo(int index) {
    if (uploadedVideos.length > index) {
      final String removedUrl = uploadedVideos[index];
      uploadedVideos.removeAt(index);
      if (videoLinkController.text.trim() == removedUrl.trim()) {
        videoLinkController.clear();
      }
    }
  }

  void removeLocalImage(int index) {
    if (localImages.length > index) {
      localImages.removeAt(index);
    }
  }

  void removeUploadedImage(int index) {
    if (uploadedImages.length > index) {
      uploadedImages.removeAt(index);
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
