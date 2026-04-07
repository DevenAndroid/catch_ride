import 'dart:io';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditVendorProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxList assignedServices = [].obs;
  final RxInt selectedServiceIndex = 0.obs; // 0 for Details, 1+ for services

  // Basic Details Section
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final businessNameController = TextEditingController();
  final aboutController = TextEditingController();
  final RxString profilePhotoUrl = ''.obs;
  final RxString coverImageUrl = ''.obs;
  final Rxn<File> newProfileImage = Rxn<File>();
  final Rxn<File> newCoverImage = Rxn<File>();

  // Payment Methods
  final RxList<String> paymentOptions = <String>['Venmo', 'Zelle', 'Cash', 'Credit Card', 'ACH/Bank Transfer', 'Other'].obs;
  final RxList<String> selectedPayments = <String>[].obs;
  final otherPaymentController = TextEditingController();

  // Experience Highlights
  final RxList<TextEditingController> highlightControllers = <TextEditingController>[].obs;

  // Grooming Tab - Home Base
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController(text: 'USA');

  // Grooming Tab - Experience & Choices
  final RxnString experience = RxnString();
  final List<String> experienceOptions = List.generate(51, (index) => index.toString());
  
  final RxList<String> disciplineOptions = <String>['Eventing', 'Hunter/Jumper', 'Dressage', 'Other'].obs;
  final RxList<String> selectedDisciplines = <String>[].obs;
  final otherDisciplineController = TextEditingController();

  final RxList<String> horseLevelOptions = <String>['AAAA Circuit', 'FEI', 'Grand Prix', 'Young horses'].obs;
  final RxList<String> selectedHorseLevels = <String>[].obs;

  final RxList<String> regionOptions = <String>[].obs;
  final RxList<String> selectedRegions = <String>[].obs;

  // Social Media
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();

  // Additional Grooming Sections
  final RxList<String> supportOptions = <String>['Show Grooming', 'Monthly Jobs', 'Fill in Daily Grooming Support', 'Weekly Jobs', 'Seasonal Jobs', 'Travel Jobs'].obs;
  final RxList<String> selectedSupport = <String>[].obs;

  final RxList<String> handlingOptions = <String>['Lunging', 'Flat Riding (exercise only)'].obs;
  final RxList<String> selectedHandling = <String>[].obs;

  final RxList<String> additionalSkillsOptions = <String>['Braiding', 'Clipping'].obs;
  final RxList<String> selectedAdditionalSkills = <String>[].obs;

  final RxList<String> travelOptions = <String>['Local Only', 'Regional', 'Nationwide', 'International'].obs;
  final RxList<String> selectedTravel = <String>[].obs;

  // Braiding Tab Specifics
  final RxList braidingServices = [].obs;
  final braidingServiceInputController = TextEditingController();

  // Cancellation
  final RxnString cancellationPolicy = RxnString();
  final RxBool isCustomCancellation = false.obs;
  final customCancellationController = TextEditingController();

  // Photos
  final RxList<String> existingPhotos = <String>[].obs;
  final RxList<File> newPhotos = <File>[].obs;

  // Farrier Tab Specifics
  final RxList farrierServices = [].obs;
  final RxList farrierAddOns = [].obs;
  final RxList<String> certificationOptions = <String>['AFA Certified Journeyman Farrier (CJF)', 'AFA Certified Farrier (CF)', 'AFA Certified Tradesman Farrier (CTF)', 'BWFA Masters', 'DipWCF (Worshipful Company ...)', 'Other'].obs;
  final RxList<String> selectedCertifications = <String>[].obs;
  final otherCertificationController = TextEditingController();

  final RxList<String> farrierScopeOptions = <String>['Routine trimming/shoeing', 'Glue-on / specialty shoes', 'Barefoot / Natural Balance', 'Corrective/Therapeutic shoeing', 'Draft horses', 'Donkeys/Mules', 'Upper-level performance horses', 'Other'].obs;
  final RxList<String> selectedFarrierScope = <String>[].obs;
  final otherFarrierScopeController = TextEditingController();

  // Farrier Travel & Fees
  final RxList<Map<String, dynamic>> farrierTravelFees = <Map<String, dynamic>>[].obs;
  
  // Farrier Client Intake
  final RxnString farrierNewClientPolicy = RxnString();
  final farrierMinHorsesController = TextEditingController(text: '1');
  final RxBool farrierEmergencySupport = false.obs;
  final RxnString farrierInsuranceStatus = RxnString();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
    fetchDynamicTags();
  }

  Future<void> fetchProfileData() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getRequest('/vendors/me');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final data = response.body['data'];
        
        // Basic Details
        fullNameController.text = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
        phoneController.text = data['phone'] ?? '';
        businessNameController.text = data['businessName'] ?? '';
        aboutController.text = data['bio'] ?? '';
        profilePhotoUrl.value = data['profilePhoto'] ?? '';
        coverImageUrl.value = data['coverImage'] ?? '';
        
        selectedPayments.assignAll(List<String>.from(data['paymentMethods'] ?? []));
        
        final List<String> loadedHighlights = List<String>.from(data['highlights'] ?? []);
        if (loadedHighlights.isEmpty) {
          highlightControllers.assignAll([TextEditingController()]);
        } else {
          highlightControllers.assignAll(loadedHighlights.map((h) => TextEditingController(text: h)).toList());
        }

        // Service level data
        final List services = data['assignedServices'] ?? [];
        assignedServices.assignAll(services);
        
        populateServiceData();
      }
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void populateServiceData() {
    final services = assignedServices;
    
    // Find the active service based on selected index or default to Grooming/first
    var activeService;
    if (selectedServiceIndex.value > 0 && selectedServiceIndex.value <= services.length) {
      activeService = services[selectedServiceIndex.value - 1];
    } else {
      activeService = services.firstWhereOrNull((s) => s['serviceType'] == 'Grooming') ?? (services.isNotEmpty ? services.first : null);
    }

    if (activeService != null) {
      final profileData = activeService['profile']?['profileData'] ?? {};
      final appData = activeService['application']?['applicationData'] ?? {};

      // Home Base
      cityController.text = appData['homeBase']?['city'] ?? '';
      stateController.text = appData['homeBase']?['state'] ?? '';
      countryController.text = appData['homeBase']?['country'] ?? 'USA';

      experience.value = appData['experience']?.toString();
      selectedDisciplines.assignAll(List<String>.from(appData['disciplines'] ?? []));
      otherDisciplineController.text = appData['otherDiscipline'] ?? '';
      selectedHorseLevels.assignAll(List<String>.from(appData['horseLevels'] ?? []));
      selectedRegions.assignAll(List<String>.from(appData['regions'] ?? []));
      
      facebookController.text = profileData['socialMedia']?['facebook'] ?? '';
      // Capabilities based on service type
      if (activeService['serviceType'] == 'Grooming') {
        selectedSupport.assignAll(List<String>.from(profileData['capabilities']?['support'] ?? []));
        selectedHandling.assignAll(List<String>.from(profileData['capabilities']?['handling'] ?? []));
        selectedAdditionalSkills.assignAll(List<String>.from(profileData['additionalSkills'] ?? []));
      } else if (activeService['serviceType'] == 'Braiding' || activeService['serviceType'] == 'Clipping') {
          final List bServices = profileData['services'] ?? [];
          braidingServices.assignAll(bServices.map((s) => {
            'name': s['name'] ?? '',
            'price': TextEditingController(text: s['price']?.toString() ?? ''),
            'isSelected': RxBool(s['isSelected'] == null || s['isSelected'] == true),
          }).toList());
        } else if (activeService['serviceType'] == 'Farrier') {
          final List fServices = profileData['services'] ?? [];
          farrierServices.assignAll(fServices.map((s) => {
            'name': s['name'] ?? '',
            'price': TextEditingController(text: s['price']?.toString() ?? ''),
            'isSelected': RxBool(s['isSelected'] == null || s['isSelected'] == true),
          }).toList());

          final List aServices = profileData['addOns'] ?? [];
          farrierAddOns.assignAll(aServices.map((s) => {
            'name': s['name'] ?? '',
            'price': TextEditingController(text: s['price']?.toString() ?? ''),
            'isSelected': RxBool(s['isSelected'] == null || s['isSelected'] == true),
          }).toList());

          selectedCertifications.assignAll(List<String>.from(appData['certifications'] ?? []));
          otherCertificationController.text = appData['otherCertification'] ?? '';
          selectedFarrierScope.assignAll(List<String>.from(appData['scopeOfWork'] ?? []));
          otherFarrierScopeController.text = appData['otherScope'] ?? '';

          final List travelFees = profileData['travelPreferences'] ?? [];
          farrierTravelFees.assignAll(travelFees.map((t) => Map<String, dynamic>.from(t)).toList());

          farrierNewClientPolicy.value = appData['clientIntake']?['policy'];
          farrierMinHorsesController.text = appData['clientIntake']?['minHorses']?.toString() ?? '1';
          farrierEmergencySupport.value = appData['clientIntake']?['emergencySupport'] ?? false;
          farrierInsuranceStatus.value = appData['insuranceStatus'];
        }

      final travelPrefRaw = profileData['travelPreferences'] ?? [];
      if (travelPrefRaw is List) {
        selectedTravel.assignAll(travelPrefRaw.map((e) => (e is Map) ? (e['type']?.toString() ?? '') : e.toString()).where((s) => s.isNotEmpty).toList());
      }
      
      cancellationPolicy.value = profileData['cancellationPolicy']?['policy'];
      isCustomCancellation.value = profileData['cancellationPolicy']?['isCustom'] ?? false;
      if (isCustomCancellation.value) {
        customCancellationController.text = cancellationPolicy.value ?? '';
      }
      
      existingPhotos.assignAll(List<String>.from(profileData['media'] ?? []));
    }
  }


  Future<void> fetchDynamicTags() async {
    try {
      final response = await _apiService.getRequest('/system-config/tag-types/with-values?category=Grooming');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List types = response.body['data'];
        
        final disciplineType = types.firstWhereOrNull((t) => t['name'] == 'Disciplines');
        if (disciplineType != null) {
          disciplineOptions.assignAll(List<String>.from(disciplineType['values'].map((v) => v['name'])));
          if (!disciplineOptions.contains('Other')) disciplineOptions.add('Other');
        }

        final horseLevelType = types.firstWhereOrNull((t) => t['name'] == 'Typical Level of Horses');
        if (horseLevelType != null) {
          horseLevelOptions.assignAll(List<String>.from(horseLevelType['values'].map((v) => v['name'])));
        }

        final regionType = types.firstWhereOrNull((t) => t['name'] == 'Regions Covered');
        if (regionType != null) {
          regionOptions.assignAll(List<String>.from(regionType['values'].map((v) => v['name'])));
        }
      }
    } catch (e) {
      debugPrint('Error fetching tags: $e');
    }
  }

  // Actions
  void togglePayment(String method) {
    if (selectedPayments.contains(method)) {
      selectedPayments.remove(method);
    } else {
      selectedPayments.add(method);
    }
  }

  void addHighlight() => highlightControllers.add(TextEditingController());
  void removeHighlight(int index) => highlightControllers.removeAt(index);

  void toggleDiscipline(String disc) {
    if (selectedDisciplines.contains(disc)) {
      selectedDisciplines.remove(disc);
    } else {
      selectedDisciplines.add(disc);
    }
  }

  void toggleHorseLevel(String level) {
    if (selectedHorseLevels.contains(level)) {
      selectedHorseLevels.remove(level);
    } else {
      selectedHorseLevels.add(level);
    }
  }

  void toggleRegion(String region) {
    if (selectedRegions.contains(region)) {
      selectedRegions.remove(region);
    } else {
      selectedRegions.add(region);
    }
  }

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) newProfileImage.value = File(image.path);
  }

  Future<void> pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) newCoverImage.value = File(image.path);
  }

  Future<void> addGroomingPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) newPhotos.add(File(image.path));
  }

  void removeExistingPhoto(int index) => existingPhotos.removeAt(index);
  void removeNewPhoto(int index) => newPhotos.removeAt(index);

  void addBraidingService(String name) {
    if (name.isNotEmpty) {
      braidingServices.add({
        'name': name,
        'price': TextEditingController(text: '0'),
        'isSelected': true.obs,
      });
      braidingServiceInputController.clear();
    }
  }

  void toggleBraidingService(int index) {
    final service = braidingServices[index];
    service['isSelected'].value = !service['isSelected'].value;
  }

  Future<String?> _uploadFile(File file, String type) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': type,
      });
      final response = await _apiService.postRequest('/upload?type=$type', formData);
      if (response.statusCode == 200 && response.body['success'] == true) {
        return response.body['data']['filename'];
      }
    } catch (e) {
      debugPrint('Error uploading $type: $e');
    }
    return null;
  }

  Future<void> saveProfile() async {
    isSaving.value = true;
    try {
      // 1. Upload new images if any
      String? profilePhoto = profilePhotoUrl.value;
      if (newProfileImage.value != null) {
        profilePhoto = await _uploadFile(newProfileImage.value!, 'profile');
      }

      String? coverImage = coverImageUrl.value;
      if (newCoverImage.value != null) {
        coverImage = await _uploadFile(newCoverImage.value!, 'profile');
      }

      final List<String> groomingMedia = [...existingPhotos];
      for (var f in newPhotos) {
        final key = await _uploadFile(f, 'grooming');
        if (key != null) groomingMedia.add(key);
      }

      // 2. Prepare Payload
      final vendorPayload = {
        'firstName': fullNameController.text.split(' ').first,
        'lastName': fullNameController.text.contains(' ') ? fullNameController.text.split(' ').skip(1).join(' ') : '',
        'phone': phoneController.text,
        'businessName': businessNameController.text,
        'bio': aboutController.text,
        'profilePhoto': profilePhoto,
        'coverImage': coverImage,
        'paymentMethods': selectedPayments.toList(),
        'highlights': highlightControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
      };

      // 1.5 Helper for Braiding Services payload
      final braidingServicesPayload = braidingServices.map((s) => {
        'name': s['name'],
        'price': s['price'].text,
        'isSelected': s['isSelected'].value,
      }).toList();

      final servicesData = <String, dynamic>{};

      // Construct grooming payload if assigned
      if (assignedServices.any((s) => s['serviceType'] == 'Grooming')) {
        servicesData['grooming'] = {
          'applicationData': {
            'homeBase': {
              'city': cityController.text,
              'state': stateController.text,
              'country': countryController.text,
            },
            'experience': experience.value,
            'disciplines': selectedDisciplines.toList(),
            'otherDiscipline': otherDisciplineController.text,
            'horseLevels': selectedHorseLevels.toList(),
            'regions': selectedRegions.toList(),
            'media': groomingMedia,
          },
          'profileData': {
            'socialMedia': {
              'facebook': facebookController.text,
              'instagram': instagramController.text,
            },
            'capabilities': {
              'support': selectedSupport.toList(),
              'handling': selectedHandling.toList(),
            },
            'additionalSkills': selectedAdditionalSkills.toList(),
            'travelPreferences': selectedTravel.toList(),
            'cancellationPolicy': {
              'policy': isCustomCancellation.value ? customCancellationController.text : cancellationPolicy.value,
              'isCustom': isCustomCancellation.value,
            },
            'media': groomingMedia,
          }
        };
      }

      // Construct braiding payload if assigned
      if (assignedServices.any((s) => s['serviceType'] == 'Braiding')) {
        servicesData['braiding'] = {
          'applicationData': {
            'homeBase': {
              'city': cityController.text,
              'state': stateController.text,
              'country': countryController.text,
            },
            'experience': experience.value,
            'disciplines': selectedDisciplines.toList(),
            'otherDiscipline': otherDisciplineController.text,
            'horseLevels': selectedHorseLevels.toList(),
            'regions': selectedRegions.toList(),
            'media': groomingMedia,
          },
          'profileData': {
            'socialMedia': {
              'facebook': facebookController.text,
              'instagram': instagramController.text,
            },
            'services': braidingServicesPayload,
            'additionalSkills': selectedAdditionalSkills.toList(),
            'travelPreferences': selectedTravel.toList(),
            'cancellationPolicy': {
              'policy': isCustomCancellation.value ? customCancellationController.text : cancellationPolicy.value,
              'isCustom': isCustomCancellation.value,
            },
            'media': groomingMedia,
          }
        };
      }

      // Construct clipping payload if assigned
      if (assignedServices.any((s) => s['serviceType'] == 'Clipping')) {
        servicesData['clipping'] = {
          'applicationData': {
            'homeBase': {
              'city': cityController.text,
              'state': stateController.text,
              'country': countryController.text,
            },
            'experience': experience.value,
            'disciplines': selectedDisciplines.toList(),
            'otherDiscipline': otherDisciplineController.text,
            'horseLevels': selectedHorseLevels.toList(),
            'regions': selectedRegions.toList(),
            'media': groomingMedia,
          },
          'profileData': {
            'socialMedia': {
              'facebook': facebookController.text,
              'instagram': instagramController.text,
            },
            'services': braidingServicesPayload, // Reuse services logic as they share same structure
            'additionalSkills': selectedAdditionalSkills.toList(),
            'travelPreferences': selectedTravel.toList(),
            'cancellationPolicy': {
              'policy': isCustomCancellation.value ? customCancellationController.text : cancellationPolicy.value,
              'isCustom': isCustomCancellation.value,
            },
            'media': groomingMedia,
          }
        };
      }

      // Construct farrier payload if assigned
      if (assignedServices.any((s) => s['serviceType'] == 'Farrier')) {
        servicesData['farrier'] = {
          'applicationData': {
            'homeBase': {
              'city': cityController.text,
              'state': stateController.text,
              'country': countryController.text,
            },
            'experience': experience.value,
            'disciplines': selectedDisciplines.toList(),
            'otherDiscipline': otherDisciplineController.text,
            'horseLevels': selectedHorseLevels.toList(),
            'regions': selectedRegions.toList(),
            'certifications': selectedCertifications.toList(),
            'otherCertification': otherCertificationController.text,
            'scopeOfWork': selectedFarrierScope.toList(),
            'otherScope': otherFarrierScopeController.text,
            'clientIntake': {
              'policy': farrierNewClientPolicy.value,
              'minHorses': int.tryParse(farrierMinHorsesController.text) ?? 1,
              'emergencySupport': farrierEmergencySupport.value,
            },
            'insuranceStatus': farrierInsuranceStatus.value,
            'media': groomingMedia,
          },
          'profileData': {
            'socialMedia': {
              'facebook': facebookController.text,
              'instagram': instagramController.text,
            },
            'services': farrierServices.map((s) => {
              'name': s['name'],
              'price': s['price'].text,
              'isSelected': s['isSelected'].value,
            }).toList(),
            'addOns': farrierAddOns.map((s) => {
              'name': s['name'],
              'price': s['price'].text,
              'isSelected': s['isSelected'].value,
            }).toList(),
            'travelPreferences': farrierTravelFees.toList(),
            'cancellationPolicy': {
              'policy': isCustomCancellation.value ? customCancellationController.text : cancellationPolicy.value,
              'isCustom': isCustomCancellation.value,
            },
            'media': groomingMedia,
          }
        };
      }

      final servicesPayload = {
        'servicesData': servicesData,
      };

      // 3. Update Vendor Profile
      final vendorResponse = await _apiService.putRequest('/vendors/profile', vendorPayload);
      if (vendorResponse.statusCode != 200) throw 'Failed to update vendor basic profile';

      // 4. Update Grooming Service Profile
      final vendorId = _authController.currentUser.value?.id; // Assuming ID is accessible
      // If vendorId is null, we fetch again or use /vendors/me logic
      final meResponse = await _apiService.getRequest('/vendors/me');
      final realVendorId = meResponse.body['data']['_id'];

      final serviceResponse = await _apiService.putRequest('/vendors/$realVendorId', servicesPayload);
      
      if (serviceResponse.statusCode == 200) {
        // Update local AuthController state for immediate UI reflection in Menu/Personal Info
        if (_authController.currentUser.value != null) {
          final updatedUser = _authController.currentUser.value!.copyWith(
            firstName: fullNameController.text.split(' ').first,
            lastName: fullNameController.text.contains(' ') ? fullNameController.text.split(' ').skip(1).join(' ') : '',
            phone: phoneController.text,
            bio: aboutController.text,
            avatar: profilePhoto,
            photo: profilePhoto,
            coverImage: coverImage,
          );
          _authController.currentUser.value = updatedUser;
          _authController.currentUser.refresh();
        }

        _authController.currentUser.refresh();
        
        // Refresh the view profile controller if it's active
        if (Get.isRegistered<GroomViewProfileController>()) {
          Get.find<GroomViewProfileController>().fetchProfile();
        }

        Get.back();
        Get.snackbar('Success', 'Profile updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        throw serviceResponse.body['message'] ?? 'Failed to update grooming details';
      }

    } catch (e) {
      debugPrint('Save error: $e');
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }
}
