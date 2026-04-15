import 'dart:io';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

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
  final notesForTrainerController = TextEditingController();
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

  // Location Details
  final states = <Map<String, dynamic>>[].obs;
  final cities = <Map<String, dynamic>>[].obs;
  final isLoadingStates = false.obs;
  final isLoadingCities = false.obs;
  final selectedStateNode = Rxn<Map<String, dynamic>>();
  final selectedCityNode = Rxn<Map<String, dynamic>>();

  // Grooming Tab - Experience & Choices
  final RxnString experience = RxnString();
  final List<String> experienceOptions = ['0-1', '2-4', '5-9', '10+'];
  
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

  // Service-specific photo lists to prevent overwriting
  final Map<String, RxList<String>> serviceExistingPhotos = {
    'Grooming': <String>[].obs,
    'Braiding': <String>[].obs,
    'Clipping': <String>[].obs,
    'Farrier': <String>[].obs,
    'Bodywork': <String>[].obs,
  };
  final Map<String, RxList<File>> serviceNewPhotos = {
    'Grooming': <File>[].obs,
    'Braiding': <File>[].obs,
    'Clipping': <File>[].obs,
    'Farrier': <File>[].obs,
    'Bodywork': <File>[].obs,
  };

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
  final RxInt farrierMinHorses = 1.obs;
  final RxBool farrierEmergencySupport = false.obs;
  final RxnString farrierInsuranceStatus = RxnString();
  
  // Bodywork Tab Specifics
  final RxList bodyworkServices = [].obs;
  final RxList<String> bodyworkProfessionalStandards = <String>[
    'I provide supportive bodywork and do not replace veterinary care',
    'I refer cases requiring diagnosis or medical treatment to a licensed veterinarian',
    'I understand certain services or situations may require prior veterinary approval',
    'I operate within the scope of my certifications and local regulations.'
  ].obs;
  final RxList<String> selectedBodyworkStandards = <String>[].obs;
  final RxList<File> bodyworkCertFiles = <File>[].obs;
  final RxList<String> bodyworkExistingCertUrls = <String>[].obs;
  final RxList<String> bodyworkModalityOptions = <String>[].obs;
  final otherModalityController = TextEditingController();
  final selectedTravelData = <String, Map<String, dynamic>>{}.obs;
  final RxString tempSelectedFeeType = 'No travel fee'.obs;
  final travelFeePriceController = TextEditingController();
  final travelFeeDisclaimerController = TextEditingController();

  void saveFarrierTravelConfig(String category) {
    selectedTravelData[category] = {
      'type': tempSelectedFeeType.value,
      'price': travelFeePriceController.text,
      'disclaimer': travelFeeDisclaimerController.text,
    };
    
    // Sync to farrierTravelFees for payload
    final index = farrierTravelFees.indexWhere((t) => t['category'] == category);
    final newData = {
      'category': category,
      'type': tempSelectedFeeType.value,
      'price': travelFeePriceController.text,
      'disclaimer': travelFeeDisclaimerController.text,
    };
    if (index != -1) {
      farrierTravelFees[index] = newData;
    } else {
      farrierTravelFees.add(newData);
    }
  }

  // Shipping Tab Specifics
  final dotNumberController = TextEditingController();
  final RxnString shippingOperationType = RxnString();
  final RxList<String> shippingTravelScope = <String>[].obs;
  final RxList<String> shippingRigTypes = <String>[].obs;
  final RxList<String> shippingServicesOffered = <String>[].obs;
  final RxBool shippingHasCDL = false.obs;
  final Rxn<File> shippingCDLFile = Rxn<File>();
  final RxInt shippingRigCapacity = 1.obs;
  final shippingNotesController = TextEditingController();
  final RxList<String> shippingRigPhotos = <String>[].obs;
  final RxList<File> newShippingRigPhotos = <File>[].obs;
  final RxnString shippingExistingCDLUrl = RxnString();

  // Shipping Dynamic Options
  final RxList<String> shippingOperationOptions = <String>[].obs;
  final RxList<String> shippingTravelScopeOptions = <String>[].obs;
  final RxList<String> shippingRigTypeOptions = <String>[].obs;
  final RxList<String> shippingServicesOptions = <String>[].obs;
  final RxList<String> shippingStallOptions = <String>[].obs;
  final RxList<String> shippingStallTypes = <String>[].obs;

  // Combined Services Cache
  final RxMap rawServicesData = {}.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
    fetchDynamicTags();
    fetchStates();
  }

  Future<void> fetchStates() async {
    isLoadingStates.value = true;
    try {
      final response = await _apiService.getRequest('/locations/states');
      if (response.statusCode == 200 && response.body['success'] == true) {
        states.assignAll(List<Map<String, dynamic>>.from(response.body['data']));
        _syncLocationNodes();
      }
    } catch (e) {
      debugPrint('Error fetching states: $e');
    } finally {
      isLoadingStates.value = false;
    }
  }

  Future<void> fetchCities(String stateCode) async {
    isLoadingCities.value = true;
    cities.clear();
    try {
      final response = await _apiService.getRequest('/locations/states/$stateCode/cities');
      if (response.statusCode == 200 && response.body['success'] == true) {
        cities.assignAll(List<Map<String, dynamic>>.from(response.body['data']));
        
        if (cityController.text.isNotEmpty) {
          final node = cities.firstWhereOrNull((c) => c['name'] == cityController.text);
          if (node != null) {
            selectedCityNode.value = node;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching cities: $e');
    } finally {
      isLoadingCities.value = false;
    }
  }

  void onStateSelected(Map<String, dynamic> stateNode) {
    selectedStateNode.value = stateNode;
    stateController.text = stateNode['name'] ?? '';
    cityController.text = '';
    selectedCityNode.value = null;
    fetchCities(stateNode['isoCode']);
  }

  void onCitySelected(Map<String, dynamic> cityNode) {
    selectedCityNode.value = cityNode;
    cityController.text = cityNode['name'] ?? '';
  }

  void _syncLocationNodes() {
    if (states.isNotEmpty && stateController.text.isNotEmpty) {
      final sNode = states.firstWhereOrNull((s) => s['name'] == stateController.text);
      if (sNode != null) {
        selectedStateNode.value = sNode;
        // If cities are already loaded, try to find the city node
        if (cities.isNotEmpty && cityController.text.isNotEmpty) {
           final cNode = cities.firstWhereOrNull((c) => c['name'] == cityController.text);
           if (cNode != null) {
             selectedCityNode.value = cNode;
           }
        } else if (cityController.text.isNotEmpty) {
           // Fetch cities if they aren't loaded yet
           fetchCities(sNode['isoCode']);
        }
      }
    }
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
        notesForTrainerController.text = data['notesForTrainer'] ?? '';
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
        
        // Cache raw services data to preserve unmanaged fields (like rates)
        final Map<String, dynamic> sData = data['servicesData'] ?? {};
        rawServicesData.assignAll(sData);
        
        // Populate ALL service data into our reactive fields to prevent overwriting with blanks
        _initializeAllServicesFields();

        populateServiceData();
      }
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeAllServicesFields() {
    for (var service in assignedServices) {
      final type = service['serviceType'];
      final profileData = service['profile']?['profileData'] ?? {};
      final application = service['application'] ?? {};
      final appData = application['applicationData'] ?? application ?? {};
      
      if (type == 'Grooming') {
        selectedSupport.assignAll(List<String>.from(profileData['capabilities']?['support'] ?? []));
        selectedHandling.assignAll(List<String>.from(profileData['capabilities']?['handling'] ?? []));
        selectedAdditionalSkills.assignAll(List<String>.from(profileData['additionalSkills'] ?? []));
      } else if (type == 'Braiding' || type == 'Clipping') {
        final List bServices = profileData['services'] ?? [];
        final targetList = braidingServices;
        targetList.assignAll(bServices.map((s) {
          if (s is Map) {
            return {
              'name': s['name'] ?? '',
              'price': TextEditingController(text: s['price']?.toString() ?? ''),
              'isSelected': RxBool(s['isSelected'] == null || s['isSelected'] == true),
            };
          }
          return {
            'name': s.toString(),
            'price': TextEditingController(text: '0'),
            'isSelected': RxBool(true),
          };
        }).toList());
      } else if (type == 'Farrier') {
        final List fServices = profileData['services'] ?? [];
        farrierServices.assignAll(fServices.map((s) {
          if (s is Map) {
            return {
              'name': s['name'] ?? '',
              'price': TextEditingController(text: s['price']?.toString() ?? ''),
              'isSelected': RxBool(s['isSelected'] == null || s['isSelected'] == true),
            };
          }
          return {'name': s.toString(), 'price': TextEditingController(text: '0'), 'isSelected': RxBool(true)};
        }).toList());

        final List aServices = profileData['addOns'] ?? [];
        farrierAddOns.assignAll(aServices.map((s) {
          if (s is Map) {
            return {
              'name': s['name'] ?? '',
              'price': TextEditingController(text: s['price']?.toString() ?? ''),
              'isSelected': RxBool(s['isSelected'] == null || s['isSelected'] == true),
            };
          }
          return {'name': s.toString(), 'price': TextEditingController(text: '0'), 'isSelected': RxBool(true)};
        }).toList());
        
        selectedCertifications.assignAll(List<String>.from(appData['certifications'] ?? []));
        otherCertificationController.text = appData['otherCertification'] ?? '';
        selectedFarrierScope.assignAll(List<String>.from(appData['scopeOfWork'] ?? []));
        otherFarrierScopeController.text = appData['otherScope'] ?? '';
        
        final List travelFees = profileData['travelPreferences'] ?? [];
        farrierTravelFees.assignAll(travelFees.map((t) => Map<String, dynamic>.from(t)).toList());
        for (var t in farrierTravelFees) {
          if (t['category'] != null) selectedTravelData[t['category']] = Map<String, dynamic>.from(t);
        }
        
        farrierNewClientPolicy.value = appData['clientIntake']?['policy'] ?? profileData['clientIntake']?['policy'];
        farrierMinHorses.value = int.tryParse(appData['clientIntake']?['minHorses']?.toString() ?? profileData['clientIntake']?['minHorses']?.toString() ?? '1') ?? 1;
        farrierEmergencySupport.value = appData['clientIntake']?['emergencySupport'] ?? profileData['clientIntake']?['emergencySupport'] ?? false;
        farrierInsuranceStatus.value = appData['insuranceStatus'] ?? profileData['insuranceStatus'];
      } else if (type == 'Bodywork') {
        _mergeBodyworkModalities();
        otherModalityController.text = appData['otherModality'] ?? profileData['otherModality'] ?? '';
        final certs = List<String>.from(profileData['certifications'] ?? appData['certifications'] ?? []);
        bodyworkExistingCertUrls.assignAll(certs);
        
        final List travelFees = profileData['travelPreferences'] ?? [];
        final Map<String, Map<String, dynamic>> travelMap = {};
        for (var item in travelFees) {
          if (item is Map) {
            travelMap[item['type'] ?? ''] = Map<String, dynamic>.from(item);
          }
        }
        selectedTravelData.assignAll(travelMap);
        
        final List<String> standards = List<String>.from(profileData['professionalStandards'] ?? []);
        selectedBodyworkStandards.assignAll(standards);
      } else if (type == 'Shipping') {
        dotNumberController.text = appData['businessInfo']?['dotNumber'] ?? '';
        shippingOperationType.value = appData['operationType'];
        shippingTravelScope.assignAll(List<String>.from(appData['travelScope'] ?? profileData['travelScope'] ?? []));
        shippingRigTypes.assignAll(List<String>.from(appData['rigTypes'] ?? profileData['rigTypes'] ?? []));
        shippingStallTypes.assignAll(List<String>.from(appData['stallType'] ?? profileData['stallType'] ?? []));
        shippingServicesOffered.assignAll(List<String>.from(profileData['servicesOffered'] ?? []));
        shippingRigCapacity.value = appData['rigCapacity'] ?? profileData['rigCapacity'] ?? 1;
        shippingNotesController.text = profileData['notes'] ?? '';
        shippingRigPhotos.assignAll(List<String>.from(profileData['media']?['rigPhotos'] ?? appData['media']?['rigPhotos'] ?? []));
        shippingExistingCDLUrl.value = appData['media']?['cdlPhoto'] ?? profileData['media']?['cdlPhoto'];
      }
      
      // Photos for each service
      if (serviceExistingPhotos.containsKey(type)) {
        final List media = (profileData['media'] is List && (profileData['media'] as List).isNotEmpty) 
            ? profileData['media'] 
            : (appData['media'] ?? []);
        serviceExistingPhotos[type]!.assignAll(List<String>.from(media));
      }
    }
  }

  void populateServiceData() {
    final services = assignedServices;
    
    // Find the active service based on selected index or default to Grooming/first
    Map<String, dynamic>? activeService;
    if (selectedServiceIndex.value > 0 && selectedServiceIndex.value <= services.length) {
      activeService = services[selectedServiceIndex.value - 1];
    } else {
      activeService = services.firstWhereOrNull((s) => s['serviceType'] == 'Grooming') ?? (services.isNotEmpty ? services.first : null);
    }

    if (activeService != null) {
      final profileData = activeService['profile']?['profileData'] ?? {};
      final application = activeService['application'] ?? {};
      final appData = application['applicationData'] ?? application ?? {};

      final vendorData = assignedServices.isEmpty ? {} : (assignedServices[0]['vendorId'] is Map ? assignedServices[0]['vendorId'] : {});

      // Home Base Fallbacks
      String? city = appData['homeBase']?['city'] ?? appData['city'];
      String? state = appData['homeBase']?['state'] ?? appData['state'];
      String? country = appData['homeBase']?['country'] ?? appData['country'];

      if (city == null || city.isEmpty) city = vendorData['city']?.toString();
      if (state == null || state.isEmpty) state = vendorData['state']?.toString();
      if (country == null || country.isEmpty) country = vendorData['country']?.toString();

      cityController.text = city ?? '';
      stateController.text = state ?? '';
      countryController.text = country ?? 'USA';

      // Experience Fallback
      dynamic exp = appData['experience'] ?? appData['yearsExperience'] ?? vendorData['yearsExperience'] ?? vendorData['experience'];
      experience.value = exp?.toString();

      selectedDisciplines.assignAll(List<String>.from(appData['disciplines'] ?? vendorData['disciplines'] ?? []));
      otherDisciplineController.text = appData['otherDiscipline'] ?? '';
      selectedHorseLevels.assignAll(List<String>.from(appData['horseLevels'] ?? vendorData['horseLevels'] ?? []));
      selectedRegions.assignAll(List<String>.from(appData['regions'] ?? vendorData['regions'] ?? []));

      instagramController.text = profileData['socialMedia']?['instagram'] ?? appData['socialMedia']?['instagram'] ?? '';
      facebookController.text = profileData['socialMedia']?['facebook'] ?? appData['socialMedia']?['facebook'] ?? '';
      
      _syncLocationNodes();
      // Capabilities based on service type
      if (activeService['serviceType'] == 'Grooming') {
        selectedSupport.assignAll(List<String>.from(profileData['capabilities']?['support'] ?? []));
        selectedHandling.assignAll(List<String>.from(profileData['capabilities']?['handling'] ?? []));
        selectedAdditionalSkills.assignAll(List<String>.from(profileData['additionalSkills'] ?? []));
      } else if (activeService['serviceType'] == 'Braiding' || activeService['serviceType'] == 'Clipping') {
        final List bServices = profileData['services'] ?? [];
        braidingServices.assignAll(bServices.map((s) {
          if (s is Map) {
            return {
              'name': s['name'] ?? '',
              'price': TextEditingController(text: s['price']?.toString() ?? ''),
              'isSelected': RxBool(s['isSelected'] == null || s['isSelected'] == true),
            };
          }
          return {
            'name': s.toString(),
            'price': TextEditingController(text: '0'),
            'isSelected': RxBool(true),
          };
        }).toList());
      } else if (activeService['serviceType'] == 'Farrier') {
        final List fServices = profileData['services'] ?? [];
        farrierServices.assignAll(fServices.map((s) {
          if (s is Map) {
            return {
              'name': s['name'] ?? '',
              'price': TextEditingController(text: s['price']?.toString() ?? ''),
              'isSelected': RxBool(s['isSelected'] == null || s['isSelected'] == true),
            };
          }
          return {
            'name': s.toString(),
            'price': TextEditingController(text: '0'),
            'isSelected': RxBool(true),
          };
        }).toList());

        final List aServices = profileData['addOns'] ?? [];
        farrierAddOns.assignAll(aServices.map((s) {
          if (s is Map) {
            return {
              'name': s['name'] ?? '',
              'price': TextEditingController(text: s['price']?.toString() ?? ''),
              'isSelected': RxBool(s['isSelected'] == null || s['isSelected'] == true),
            };
          }
          return {
            'name': s.toString(),
            'price': TextEditingController(text: '0'),
            'isSelected': RxBool(true),
          };
        }).toList());

        selectedCertifications.assignAll(List<String>.from(appData['certifications'] ?? []));
        otherCertificationController.text = appData['otherCertification'] ?? '';
        selectedFarrierScope.assignAll(List<String>.from(appData['scopeOfWork'] ?? []));
        otherFarrierScopeController.text = appData['otherScope'] ?? '';

        final List travelFees = profileData['travelPreferences'] ?? [];
        farrierTravelFees.assignAll(travelFees.map((t) => Map<String, dynamic>.from(t)).toList());
        
        // Populate selectedTravelData for UI lookup
        for (var t in farrierTravelFees) {
          if (t['category'] != null) {
            selectedTravelData[t['category']] = Map<String, dynamic>.from(t);
          }
        }

        farrierNewClientPolicy.value = appData['clientIntake']?['policy'];
        farrierMinHorses.value = int.tryParse(appData['clientIntake']?['minHorses']?.toString() ?? '1') ?? 1;
        farrierEmergencySupport.value = appData['clientIntake']?['emergencySupport'] ?? false;
        final rawInsuranceStatus = appData['insuranceStatus'];
        if (rawInsuranceStatus == 'I have professional liability insurance') {
          farrierInsuranceStatus.value = 'Carries Insurance';
        } else if (rawInsuranceStatus == 'I do not have professional liability insurance') {
          farrierInsuranceStatus.value = 'Not currently insured';
        } else if (rawInsuranceStatus == 'Not applicable') {
          farrierInsuranceStatus.value = 'Insurance available upon request';
        } else {
          farrierInsuranceStatus.value = rawInsuranceStatus;
        }
      } else if (activeService['serviceType'] == 'Bodywork') {
          _mergeBodyworkModalities();

          otherModalityController.text = appData['otherModality'] ?? profileData['otherModality'] ?? '';
          
          final List<String> standards = List<String>.from(profileData['professionalStandards'] ?? []);
          if (standards.isNotEmpty) {
            selectedBodyworkStandards.assignAll(standards);
          } else if (appData['standards'] != null) {
            final Map stdMap = appData['standards'] ?? {};
            if (stdMap['provideSupportiveBodywork'] == true) selectedBodyworkStandards.add(bodyworkProfessionalStandards[0]);
            if (stdMap['refertoVet'] == true) selectedBodyworkStandards.add(bodyworkProfessionalStandards[1]);
            if (stdMap['vetApprovalRequired'] == true) selectedBodyworkStandards.add(bodyworkProfessionalStandards[2]);
            if (stdMap['operateWithinScope'] == true) selectedBodyworkStandards.add(bodyworkProfessionalStandards[3]);
          }

          final certs = List<String>.from(profileData['certifications'] ?? appData['certifications'] ?? []);
          bodyworkExistingCertUrls.assignAll(certs);
        } else if (activeService['serviceType'] == 'Shipping') {
          dotNumberController.text = appData['businessInfo']?['dotNumber'] ?? '';
          shippingOperationType.value = appData['operationType'];
          shippingTravelScope.assignAll(List<String>.from(appData['travelScope'] ?? []));
          shippingRigTypes.assignAll(List<String>.from(appData['rigTypes'] ?? []));
          shippingStallTypes.assignAll(List<String>.from(appData['stallType'] ?? []));
          shippingServicesOffered.assignAll(List<String>.from(profileData['servicesOffered'] ?? []));
          shippingHasCDL.value = appData['hasCDL'] ?? false;
          shippingRigCapacity.value = appData['rigCapacity'] ?? 1;
          shippingNotesController.text = profileData['notes'] ?? '';
          shippingRigPhotos.assignAll(List<String>.from(profileData['media']?['rigPhotos'] ?? appData['media']?['rigPhotos'] ?? []));
          shippingExistingCDLUrl.value = appData['media']?['cdlPhoto'];
          
          experience.value = appData['experience']?.toString();
          selectedRegions.assignAll(List<String>.from(appData['regions'] ?? []));
        }

      final travelPrefRaw = profileData['travelPreferences'] ?? [];
      if (travelPrefRaw is List) {
        if (activeService['serviceType'] == 'Bodywork') {
          final Map<String, Map<String, dynamic>> travelMap = {};
          for (var item in travelPrefRaw) {
            if (item is Map) {
              travelMap[item['type'] ?? ''] = Map<String, dynamic>.from(item);
            } else {
              travelMap[item.toString()] = {'feeType': 'No travel fee', 'price': '', 'disclaimer': ''};
            }
          }
          selectedTravelData.assignAll(travelMap);
        } else {
          selectedTravel.assignAll(travelPrefRaw.map((e) => (e is Map) ? (e['type']?.toString() ?? '') : e.toString()).where((s) => s.isNotEmpty).toList());
        }
      }
      
      cancellationPolicy.value = profileData['cancellationPolicy']?['policy'];
      isCustomCancellation.value = profileData['cancellationPolicy']?['isCustom'] ?? false;
      if (isCustomCancellation.value) {
        customCancellationController.text = profileData['cancellationPolicy']?['customText'] ?? cancellationPolicy.value ?? '';
      }
      
      // Populate service-specific photos
      final serviceType = activeService?['serviceType'];
      if (serviceType != null && serviceExistingPhotos.containsKey(serviceType)) {
        final List media = (profileData['media'] is List && (profileData['media'] as List).isNotEmpty) 
            ? profileData['media'] 
            : (appData['media'] ?? []);
        serviceExistingPhotos[serviceType]!.assignAll(List<String>.from(media));
        existingPhotos.assignAll(serviceExistingPhotos[serviceType]!);
      }
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

      // Fetch Shipping specific tags
      final shippingResponse = await _apiService.getRequest('/system-config/tag-types/with-values?category=Shipping');
      if (shippingResponse.statusCode == 200 && shippingResponse.body['success'] == true) {
        final List types = shippingResponse.body['data'];
        
        for (var type in types) {
          final name = type['name'];
          final List<String> values = List<String>.from(type['values'].map((v) => v['name']));
          
          if (name == 'Hauling Experience') {
            // Re-use or separate if needed
          } else if (name == 'Operation Type') {
            shippingOperationOptions.assignAll(values);
          } else if (name == 'Travel Scope') {
            shippingTravelScopeOptions.assignAll(values);
          } else if (name == 'Rig Types') {
            shippingRigTypeOptions.assignAll(values);
          } else if (name == 'Regions Covered') {
            // Already handled by Grooming if shared, but let's ensure
            if (regionOptions.isEmpty) regionOptions.assignAll(values);
          } else if (name == 'Shipping Services') {
            shippingServicesOptions.assignAll(values);
          } else if (name == 'Stall Type') {
            shippingStallOptions.assignAll(values);
          }
        }
      }

      // Fetch Bodywork specific tags
      final bodyworkResponse = await _apiService.getRequest('/system-config/tag-types/with-values?category=Bodywork');
      if (bodyworkResponse.statusCode == 200 && bodyworkResponse.body['success'] == true) {
        final List types = bodyworkResponse.body['data'];
        for (var type in types) {
          final name = type['name'];
          final List<String> values = List<String>.from(type['values'].map((v) => v['name']));
          
          if (name == 'Modality Offered' || name == 'Modalities Offered') {
            bodyworkModalityOptions.assignAll(values);
            if (!bodyworkModalityOptions.contains('Other')) bodyworkModalityOptions.add('Other');
          } else if (name == 'Disciplines') {
             // Append or set if empty
             for(var v in values) { if(!disciplineOptions.contains(v)) disciplineOptions.add(v); }
          } else if (name == 'Typical Level of Horses') {
             for(var v in values) { if(!horseLevelOptions.contains(v)) horseLevelOptions.add(v); }
          } else if (name == 'Regions Covered') {
             for(var v in values) { if(!regionOptions.contains(v)) regionOptions.add(v); }
          }
        }
        // Trigger re-population of services if we already have profile data
        if (assignedServices.isNotEmpty) {
           _mergeBodyworkModalities();
        }
      }
    } catch (e) {
      debugPrint('Error fetching tags: $e');
    }
  }

  void _mergeBodyworkModalities() {
    final services = assignedServices;
    final activeService = services.firstWhereOrNull((s) => s['serviceType'] == 'Bodywork');
    if (activeService == null) return;

    final profileData = activeService['profile']?['profileData'] ?? {};
    final application = activeService['application'] ?? {};
    final appData = application['applicationData'] ?? application ?? {};

    final List existingServices = profileData['services'] ?? [];
    final List appModalities = List<String>.from(appData['modalities'] ?? []);

    // Use system tags if available, else fallback to user's selections
    List<String> baseModalities = bodyworkModalityOptions.isNotEmpty 
        ? bodyworkModalityOptions.toList() 
        : (existingServices.map((s) => s['name'].toString()).toList() + appModalities.map((m) => m.toString()).toList()).toSet().toList();

    if (baseModalities.isEmpty) {
       baseModalities = ['Sports Massage', 'Myofascial Release', 'PEMF', 'Chiropractic', 'Acupuncture', 'Other'];
    }
    if (!baseModalities.contains('Other')) baseModalities.add('Other');

    bodyworkServices.assignAll(baseModalities.map((name) {
      final existing = existingServices.firstWhereOrNull((s) => s is Map && s['name'] == name);
      final inApp = appModalities.contains(name);

      if (existing != null) {
        return {
          'name': name,
          'rates': existing['rates'] != null ? Map<String, dynamic>.from(existing['rates']) : {'30': '', '45': '', '60': '', '90': ''},
          'isSelected': RxBool(existing['isSelected'] == null || existing['isSelected'] == true),
          'note': existing['note'] ?? '',
          'trainerPresence': existing['trainerPresence'],
          'vetApproval': existing['vetApproval'],
        };
      }
      return {
        'name': name,
        'rates': {'30': '', '45': '', '60': '', '90': ''},
        'isSelected': RxBool(inApp),
      };
    }).toList());
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

  Future<void> addServicePhoto(String serviceType) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty && serviceNewPhotos.containsKey(serviceType)) {
      serviceNewPhotos[serviceType]!.addAll(images.map((image) => File(image.path)));
      // Also sync to legacy newPhotos if on that tab
      newPhotos.addAll(images.map((image) => File(image.path)));
    }
  }

  void removeServiceExistingPhoto(String serviceType, int index) {
    if (serviceExistingPhotos.containsKey(serviceType)) {
      serviceExistingPhotos[serviceType]!.removeAt(index);
      existingPhotos.assignAll(serviceExistingPhotos[serviceType]!);
    }
  }

  void removeServiceNewPhoto(String serviceType, int index) {
    if (serviceNewPhotos.containsKey(serviceType)) {
      serviceNewPhotos[serviceType]!.removeAt(index);
      // We don't easily sync back to legacy newPhotos because it's shared, 
      // but UI will use service-specific ones.
    }
  }

  Future<void> addShippingRigPhoto() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      newShippingRigPhotos.addAll(images.map((image) => File(image.path)));
    }
  }

  void removeExistingShippingRigPhoto(int index) => shippingRigPhotos.removeAt(index);
  void removeNewShippingRigPhoto(int index) => newShippingRigPhotos.removeAt(index);

  Future<void> pickShippingCDLFile() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) shippingCDLFile.value = File(image.path);
  }

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

  Future<void> pickBodyworkCertification() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      bodyworkCertFiles.add(File(result.files.single.path!));
    }
  }

  void removeBodyworkCertFile(int index) => bodyworkCertFiles.removeAt(index);
  void removeBodyworkExistingCert(int index) {
      bodyworkExistingCertUrls.removeAt(index);
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
      // 1. Upload All Files
      String? profilePhoto = profilePhotoUrl.value;
      if (newProfileImage.value != null) {
        profilePhoto = await _uploadFile(newProfileImage.value!, 'profile');
      }

      String? coverImage = coverImageUrl.value;
      if (newCoverImage.value != null) {
        coverImage = await _uploadFile(newCoverImage.value!, 'profile');
      }

      // Upload media for each service
      final Map<String, List<String>> serviceMediaKeys = {};
      for (var serviceType in serviceNewPhotos.keys) {
        final List<String> mediaKeys = [...(serviceExistingPhotos[serviceType] ?? [])];
        final List<File> newFiles = serviceNewPhotos[serviceType] ?? [];
        
        if (newFiles.isNotEmpty) {
          final uploads = await Future.wait(newFiles.map((f) => _uploadFile(f, serviceType.toLowerCase())));
          mediaKeys.addAll(uploads.whereType<String>());
        }
        serviceMediaKeys[serviceType] = mediaKeys;
      }

      // Handle Shipping specifically if needed (it uses shippingMedia currently)
      final List<String> shippingMedia = [...shippingRigPhotos];
      if (newShippingRigPhotos.isNotEmpty) {
        final uploads = await Future.wait(newShippingRigPhotos.map((f) => _uploadFile(f, 'shipping')));
        shippingMedia.addAll(uploads.whereType<String>());
      }

      // 2. Prepare Payload
      final vendorPayload = {
        'firstName': fullNameController.text
            .split(' ')
            .first,
        'lastName': fullNameController.text.contains(' ') ? fullNameController.text.split(' ').skip(1).join(' ') : '',
        'phone': phoneController.text,
        'businessName': businessNameController.text,
        'bio': aboutController.text,
        'notesForTrainer': notesForTrainerController.text,
        'profilePhoto': profilePhoto,
        'coverImage': coverImage,
        'paymentMethods': selectedPayments.toList(),
        'highlights': highlightControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
        'isProfileCompleted': true,
        'isProfileSetup': true,
      };

      // 1.5 Helper for Braiding Services payload
      final braidingServicesPayload = braidingServices.map((s) =>
      {
        'name': s['name'],
        'price': (s['price'] as TextEditingController).text,
        'isSelected': s['isSelected'].value,
      }).toList();

      // Start with cached data to preserve fields we don't manage (like rates)
      final servicesData = Map<String, dynamic>.from(rawServicesData);

      // Construct grooming payload if assigned
      if (assignedServices.any((s) => s['serviceType'] == 'Grooming')) {
        final newGroomingData = {
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
            'media': serviceMediaKeys['Grooming'] ?? [],
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
            'media': serviceMediaKeys['Grooming'] ?? [],
          }
        };

        // Merge to preserve unmanaged fields (rates, etc.)
        final existing = Map<String, dynamic>.from(servicesData['grooming'] ?? {});
        final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});
        final existingApp = Map<String, dynamic>.from(existing['applicationData'] ?? {});
        
        servicesData['grooming'] = {
          'applicationData': {
            ...existingApp,
            ...newGroomingData['applicationData']!,
          },
          'profileData': {
            ...existingProfile,
            ...newGroomingData['profileData']!,
          }
        };
      }

      // Construct braiding payload if assigned
      if (assignedServices.any((s) => s['serviceType'] == 'Braiding')) {
        final newBraidingData = {
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
            'media': serviceMediaKeys['Braiding'] ?? [],
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
            'media': serviceMediaKeys['Braiding'] ?? [],
          }
        };

        final existing = Map<String, dynamic>.from(servicesData['braiding'] ?? {});
        final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});
        final existingApp = Map<String, dynamic>.from(existing['applicationData'] ?? {});

        servicesData['braiding'] = {
          'applicationData': {
            ...existingApp,
            ...newBraidingData['applicationData']!,
          },
          'profileData': {
            ...existingProfile,
            ...newBraidingData['profileData']!,
          }
        };
      }

      // Construct clipping payload if assigned
      if (assignedServices.any((s) => s['serviceType'] == 'Clipping')) {
        final newClippingData = {
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
            'media': serviceMediaKeys['Clipping'] ?? [],
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
            'media': serviceMediaKeys['Clipping'] ?? [],
          }
        };

        final existing = Map<String, dynamic>.from(servicesData['clipping'] ?? {});
        final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});
        final existingApp = Map<String, dynamic>.from(existing['applicationData'] ?? {});

        servicesData['clipping'] = {
          'applicationData': {
            ...existingApp,
            ...newClippingData['applicationData']!,
          },
          'profileData': {
            ...existingProfile,
            ...newClippingData['profileData']!,
          }
        };
      }

      // Construct farrier payload if assigned
      if (assignedServices.any((s) => s['serviceType'] == 'Farrier')) {
        final newFarrierData = {
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
              'minHorses': farrierMinHorses.value,
              'emergencySupport': farrierEmergencySupport.value,
            },
            'insuranceStatus': farrierInsuranceStatus.value,
            'media': serviceMediaKeys['Farrier'] ?? [],
          },
          'profileData': {
            'socialMedia': {
              'facebook': facebookController.text,
              'instagram': instagramController.text,
            },
            'services': farrierServices.map((s) => {
              'name': s['name'],
              'price': (s['price'] as TextEditingController).text,
              'isSelected': s['isSelected'].value,
            }).toList(),
            'addOns': farrierAddOns.map((s) => {
              'name': s['name'],
              'price': (s['price'] as TextEditingController).text,
              'isSelected': s['isSelected'].value,
            }).toList(),
            'travelPreferences': farrierTravelFees,
            'cancellationPolicy': {
              'policy': isCustomCancellation.value ? customCancellationController.text : cancellationPolicy.value,
              'isCustom': isCustomCancellation.value,
            },
            'media': serviceMediaKeys['Farrier'] ?? [],
          }
        };

        final existing = Map<String, dynamic>.from(servicesData['farrier'] ?? {});
        final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});
        final existingApp = Map<String, dynamic>.from(existing['applicationData'] ?? {});

        servicesData['farrier'] = {
          'applicationData': {
            ...existingApp,
            ...newFarrierData['applicationData']!,
          },
          'profileData': {
            ...existingProfile,
            ...newFarrierData['profileData']!,
          }
        };
      }

      // Construct bodywork payload if assigned
      if (assignedServices.any((s) => s['serviceType'] == 'Bodywork')) {
        final newBodyworkData = {
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
            'otherModality': otherModalityController.text,
            'certifications': bodyworkExistingCertUrls.toList(),
            'media': serviceMediaKeys['Bodywork'] ?? [],
          },
          'profileData': {
            'socialMedia': {
              'facebook': facebookController.text,
              'instagram': instagramController.text,
            },
            'services': bodyworkServices.map((s) => {
              'name': s['name'],
              'price': (s['price'] as TextEditingController).text,
              'isSelected': s['isSelected'].value,
            }).toList(),
            'professionalStandards': selectedBodyworkStandards.toList(),
            'travelPreferences': selectedTravelData.values.toList(),
            'cancellationPolicy': {
              'policy': isCustomCancellation.value ? customCancellationController.text : cancellationPolicy.value,
              'isCustom': isCustomCancellation.value,
            },
            'media': serviceMediaKeys['Bodywork'] ?? [],
          }
        };

        final existing = Map<String, dynamic>.from(servicesData['bodywork'] ?? {});
        final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});
        final existingApp = Map<String, dynamic>.from(existing['applicationData'] ?? {});

        servicesData['bodywork'] = {
          'applicationData': {
            ...existingApp,
            ...newBodyworkData['applicationData']!,
          },
          'profileData': {
            ...existingProfile,
            ...newBodyworkData['profileData']!,
          }
        };
      }

      // Construct shipping payload if assigned
      if (assignedServices.any((s) => s['serviceType'] == 'Shipping')) {
        final List<String> shippingMedia = [...shippingRigPhotos];
        for (var f in newShippingRigPhotos) {
          final key = await _uploadFile(f, 'shipping_rigs');
          if (key != null) shippingMedia.add(key);
        }

        String? cdlUrl = shippingExistingCDLUrl.value;
        if (shippingCDLFile.value != null) {
          cdlUrl = await _uploadFile(shippingCDLFile.value!, 'shipping_docs');
        }

        servicesData['shipping'] = {
          'applicationData': {
            'homeBase': {
              'city': cityController.text,
              'state': stateController.text,
              'country': countryController.text,
            },
            'businessInfo': {
              'legalName': businessNameController.text,
              'dotNumber': dotNumberController.text,
            },
            'experience': experience.value,
            'operationType': shippingOperationType.value,
            'travelScope': shippingTravelScope.toList(),
            'regions': selectedRegions.toList(),
            'rigTypes': shippingRigTypes.toList(),
            'stallType': shippingStallTypes.toList(),
            'rigCapacity': shippingRigCapacity.value,
            'hasCDL': shippingHasCDL.value,
            'media': {
              'cdlPhoto': cdlUrl,
              'rigPhotos': shippingMedia,
            }
          },
          'profileData': {
            'socialMedia': {
              'facebook': facebookController.text,
              'instagram': instagramController.text,
            },
            'servicesOffered': shippingServicesOffered.toList(),
            'notes': shippingNotesController.text,
            'cancellationPolicy': {
              'policy': isCustomCancellation.value ? customCancellationController.text : cancellationPolicy.value,
              'isCustom': isCustomCancellation.value,
            },
            'media': {
              'rigPhotos': shippingMedia,
            }
          }
        };

        final existing = Map<String, dynamic>.from(servicesData['shipping'] ?? {});
        final existingProfile = Map<String, dynamic>.from(existing['profileData'] ?? {});
        final existingApp = Map<String, dynamic>.from(existing['applicationData'] ?? {});

        servicesData['shipping'] = {
          'applicationData': {
            ...existingApp,
            ...(servicesData['shipping']!['applicationData'] as Map<String, dynamic>),
          },
          'profileData': {
            ...existingProfile,
            ...(servicesData['shipping']!['profileData'] as Map<String, dynamic>),
          }
        };
      }

      final servicesPayload = {
        'servicesData': servicesData,
        'isProfileCompleted': true,
        'isProfileSetup': true,
      };

      // 3. Update Vendor Profile
      final vendorResponse = await _apiService.putRequest('/vendors/profile', vendorPayload);
      if (vendorResponse.statusCode != 200) throw 'Failed to update vendor basic profile';

      // 4. Update Grooming Service Profile
      // If vendorId is null, we fetch again or use /vendors/me logic
      final meResponse = await _apiService.getRequest('/vendors/me');
      final realVendorId = meResponse.body['data']['_id'];

      final serviceResponse = await _apiService.putRequest('/vendors/$realVendorId', servicesPayload);

      if (serviceResponse.statusCode == 200) {
        // Update local AuthController state for immediate UI reflection in Menu/Personal Info
        if (_authController.currentUser.value != null) {
          final updatedUser = _authController.currentUser.value!.copyWith(
            firstName: fullNameController.text
                .split(' ')
                .first,
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

        serviceNewPhotos.values.forEach((list) => list.clear());
        newShippingRigPhotos.clear();
        newProfileImage.value = null;
        newCoverImage.value = null;

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
