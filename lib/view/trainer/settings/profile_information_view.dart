import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileInformationView extends StatefulWidget {
  const ProfileInformationView({super.key});

  @override
  State<ProfileInformationView> createState() => _ProfileInformationViewState();
}

class _ProfileInformationViewState extends State<ProfileInformationView> {
  String _selectedFederation = 'USEF (United States)';
  final ProfileController _profileController = Get.find<ProfileController>();
  
  late TextEditingController _federationIdController;
  late TextEditingController _facebookController;
  late TextEditingController _websiteController;
  late TextEditingController _instagramController;

  @override
  void initState() {
    super.initState();
    _selectedFederation = _profileController.userData['federationName'] ?? 'USEF (United States)';
    _federationIdController = TextEditingController(text: _profileController.userData['federationId']);
    _facebookController = TextEditingController(text: _profileController.userData['facebook']);
    _websiteController = TextEditingController(text: _profileController.userData['website']);
    _instagramController = TextEditingController(text: _profileController.userData['instagram']);
  }

  @override
  void dispose() {
    _federationIdController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _saveInformation() async {
    final Map<String, dynamic> updateData = {
      'federationName': _selectedFederation,
      'federationId': _federationIdController.text.trim(),
      'facebook': _facebookController.text.trim(),
      'website': _websiteController.text.trim(),
      'instagram': _instagramController.text.trim(),
    };

    final success = await _profileController.updateProfile(updateData);
    if (success) {
      await _profileController.fetchProfile();
      Get.back();
      
      Get.snackbar('Success', 'Profile information updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } else {
      Get.snackbar('Error', 'Failed to update profile information',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Profile Information',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFederationCard(),
            const SizedBox(height: 16),
            _buildSocialCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const CommonText(
                      'Cancel',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => CommonButton(
                  text: 'Save', 
                  isLoading: _profileController.isLoading.value,
                  onPressed: () => _saveInformation(),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFederationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Federation Information',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 16),
          // Dropdown Mock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  _selectedFederation,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _federationIdController,
            label: 'Federation ID Number',
            hintText: 'ID Number',
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Social Media & Website',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _facebookController,
            label: 'Facebook',
            hintText: 'facebook.com/yourpage',
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _websiteController,
            label: 'Website URL',
            hintText: 'https://yourwebsite.com',
            prefixIcon: const Icon(
              Icons.link,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _instagramController,
            label: 'Instagram', 
            hintText: '@yourusername'
          ),
        ],
      ),
    );
  }
}
