import 'dart:io';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/vendor/groom/profile_create/grooming_details_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile_create/clipping_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../view/vendor/braiding/profile_create/braiding_application_view.dart';
import '../../../view/vendor/braiding/profile_create/braiding_details_view.dart';
import '../../../view/vendor/bodywork/create_profile/bodywork_details_view.dart';
import '../../../view/vendor/farrier/create_profile/farrier_details_view.dart';
import '../../../view/vendor/groom/groom_bottom_nav.dart';

class GroomCompleteProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Basic Details
  final fullNameController = TextEditingController(text: 'Thomas Martin');
  final countryCode = '+1'.obs;
  final phoneNumberController = TextEditingController();
  final businessNameController = TextEditingController();
  final aboutController = TextEditingController();

  // Images
  final profileImage = Rxn<File>();
  final bannerImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();
  
  final isLoading = false.obs;
  final ApiService apiService = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    fullNameController.text = Get.find<AuthController>().currentUser.value?.fullName ?? '';
    phoneNumberController.text = Get.find<AuthController>().currentUser.value?.phone ?? '';
    fetchPaymentMethods();
  }

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> pickBannerImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      bannerImage.value = File(image.path);
    }
  }

  // Payment Methods
  final selectedPaymentMethods = <String>{}.obs;
  final otherPaymentController = TextEditingController();
  final paymentOptions = <Map<String, dynamic>>[].obs;
  final isPaymentLoading = false.obs;
  
  Future<void> fetchPaymentMethods() async {
    isPaymentLoading.value = true;
    try {
      final response = await apiService.getRequest('/payment-methods?isActive=true');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List data = response.body['data'];
        paymentOptions.value = data.map((pm) => {
          'name': pm['title'],
          'icon': pm['icon'],
          'isUrl': true,
        }).toList();
        
        // Add "Other" anyway if not present
        if (!paymentOptions.any((pm) => pm['name'] == 'Other')) {
          paymentOptions.add({'name': 'Other', 'icon': Icons.add, 'isUrl': false});
        }
      }
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
    } finally {
      isPaymentLoading.value = false;
    }
  }

  void togglePaymentMethod(String method) {
    if (selectedPaymentMethods.contains(method)) {
      selectedPaymentMethods.remove(method);
    } else {
      selectedPaymentMethods.add(method);
    }
  }

  // Experience Highlights
  final highlightInputController = TextEditingController();
  final highlights = <String>[].obs;

  void addHighlight() {
    if (highlightInputController.text.isNotEmpty) {
      highlights.add(highlightInputController.text);
      highlightInputController.clear();
    }
  }

  void removeHighlight(int index) {
    highlights.removeAt(index);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    businessNameController.dispose();
    aboutController.dispose();
    otherPaymentController.dispose();
    highlightInputController.dispose();
    super.onClose();
  }

  Future<String?> _uploadImage(File file, String type) async {
    try {
      final formData = FormData({
        'media': MultipartFile(file, filename: file.path.split('/').last),
        'type': type,
      });
      final response = await apiService.postRequest('/upload?type=$type', formData);
      if (response.statusCode == 200 && response.body['success'] == true) {
        return response.body['data']['filename'];
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
    return null;
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (profileImage.value == null) {
      Get.snackbar('Missing Info', 'Please upload a profile photo', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (bannerImage.value == null) {
      Get.snackbar('Missing Info', 'Please upload a banner photo', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      String? profilePhotoKey;
      String? bannerImageKey;

      if (profileImage.value != null) {
        profilePhotoKey = await _uploadImage(profileImage.value!, 'profile');
      }

      if (bannerImage.value != null) {
        bannerImageKey = await _uploadImage(bannerImage.value!, 'profile');
      }

      final profileData = {
        'firstName': fullNameController.text.split(' ').first,
        'lastName': fullNameController.text.contains(' ') ? fullNameController.text.split(' ').skip(1).join(' ') : '',
        'phone': phoneNumberController.text,
        'businessName': businessNameController.text,
        'bio': aboutController.text,
        'paymentMethods': selectedPaymentMethods.toList(),
        'otherPaymentDetails': otherPaymentController.text,
        'highlights': highlights.toList(),
      };

      if (profilePhotoKey != null) profileData['profilePhoto'] = profilePhotoKey;
      if (bannerImageKey != null) profileData['coverImage'] = bannerImageKey;

      final response = await apiService.putRequest('/vendors/profile', profileData);

      if (response.statusCode == 200 && response.body['success'] == true) {
        Get.snackbar('Success', 'Profile updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
        
        final authController = Get.find<AuthController>();
        await authController.updateUserMetadata();

        final services = authController.currentUser.value?.vendorServices ?? [];
        if (services.contains('Grooming')) {
          Get.off(() => const GroomingDetailsView());
        } else if (services.contains('Braiding')) {
          Get.off(() => const BraidingDetailsView());
        } else if (services.contains('Clipping')) {
          Get.off(() => const ClippingDetailView());
        }
        else if (services.contains('Farrier')) {
          Get.off(() => const FarrierDetailsView());
        }
        else if (services.contains('Bodywork')) {
          Get.off(() => const BodyworkDetailsView());
        }
        else {
          Get.offAll(() => const GroomBottomNav());
        }
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to update profile', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Error in submit: $e');
      Get.snackbar('Error', 'An unexpected error occurred', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
