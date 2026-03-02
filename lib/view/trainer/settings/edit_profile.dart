import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/view/trainer/settings/edit_basic_info_view.dart';
import 'package:catch_ride/view/trainer/settings/edit_barn_info_view.dart';
import 'package:catch_ride/view/trainer/settings/edit_experience_view.dart';
import 'package:catch_ride/view/trainer/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:catch_ride/controllers/profile_controller.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Obx(() {
        if (profileController.isLoading.value && profileController.userData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => profileController.fetchProfile(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, profileController),
                const SizedBox(height: 25),
                _buildAboutSection(profileController),
                _buildBarnInfoSection(profileController),
                _buildExperienceSection(profileController),
                _buildAvailableHorsesSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileController controller) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner Image
        CommonImageView(
          url: controller.coverImage.isNotEmpty ? controller.coverImage : AppConstants.dummyImageUrl,
          height: MediaQuery.of(context).size.height * 0.28,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        // Overlay Controls
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white60,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => const SettingsView()),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white60,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Profile Info Card
        Positioned(
          top: MediaQuery.of(context).size.height * 0.22,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image with Verification Badge
                    Stack(
                      children: [
                        CommonImageView(
                          url: controller.avatar.isNotEmpty ? controller.avatar : AppConstants.dummyImageUrl,
                          height: 80,
                          width: 80,
                          shape: BoxShape.circle,
                        ),
                        if (controller.userData['verificationStatus'] == 'verified')
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.check_circle,
                                color: Color(0xFF13CA8B),
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Name and Contact
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            controller.fullName.isNotEmpty ? controller.fullName : 'No Name',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 4),
                          CommonText(
                            controller.phone.isNotEmpty ? controller.phone : 'No Phone',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          CommonText(
                            controller.email,
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const EditBasicInfoView()),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Colors.blue.shade600,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Dummy height to allow the column to flow correctly after the positioned card
        SizedBox(height: MediaQuery.of(context).size.height * 0.35),
      ],
    );
  }

  Widget _buildAboutSection(ProfileController controller) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CommonText('About', fontSize: 16, fontWeight: FontWeight.bold),
              GestureDetector(
                onTap: () => Get.to(() => const EditBasicInfoView()),
                child: Icon(
                  Icons.edit_outlined,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CommonText(
            controller.bio.isNotEmpty ? controller.bio : "No bio available.",
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildBarnInfoSection(ProfileController controller) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CommonText(
                'Barn Information',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              GestureDetector(
                onTap: () => Get.to(() => const EditBarnInfoView()),
                child: Icon(
                  Icons.edit_outlined,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CommonText('Barn Name', fontSize: 12, color: Colors.grey.shade500),
          const SizedBox(height: 4),
          CommonText(
            controller.userData['barnName'] ?? 'Not Specified',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              CommonText(
                controller.location.isNotEmpty ? controller.location : 'Location Not Provided',
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ],
          ),
          // Additional locations if available (mocked for now or extracted from location string)
          if (controller.location.contains(','))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  CommonText(
                    controller.location.split(',').last.trim(),
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection(ProfileController controller) {
    // Determine years from back-end
    String experience = controller.userData['yearsExperience']?.toString() ?? 
                       controller.userData['experience']?.toString() ?? 'N/A';
    
    // Extract program tags
    List<dynamic> programTags = controller.userData['programTags'] ?? [];
    List<dynamic> showCircuits = controller.userData['showCircuits'] ?? [];

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CommonText(
                'Experience',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              GestureDetector(
                onTap: () => Get.to(() => const EditExperienceView()),
                child: Icon(
                  Icons.edit_outlined,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CommonText(
            'Years in industry',
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 4),
          CommonText(
            experience.contains('year') ? experience : '$experience years',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 16),
          CommonText('Program Tags', fontSize: 12, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          if (programTags.isEmpty)
            CommonText('No tags added', fontSize: 13, color: Colors.grey.shade400)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: programTags.map((tag) => _buildTag(tag.toString())).toList(),
            ),
          const SizedBox(height: 16),
          CommonText(
            'Show Circuits',
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 8),
          if (showCircuits.isEmpty)
            CommonText('No circuits added', fontSize: 13, color: Colors.grey.shade400)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: showCircuits.map((circuit) => _buildTag(circuit.toString())).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAvailableHorsesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Available Horses',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          _buildHorseCard(
            'Whirlwind',
            '8-year-old Warmblood Gelding',
            AppConstants.dummyImageUrl,
          ),
          _buildHorseCard(
            'Midnight Star',
            '10-year-old Warmblood Gelding',
            AppConstants.dummyImageUrl,
          ),
          _buildHorseCard(
            'Golden Dream',
            '12-year-old Warmblood Gelding',
            AppConstants.dummyImageUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildHorseCard(String name, String desc, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CommonImageView(
              url: imageUrl,
              height: 70,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(name, fontSize: 16, fontWeight: FontWeight.bold),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const CommonText(
                        'Lease',
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                CommonText(desc, fontSize: 12, color: Colors.grey.shade600),
                const SizedBox(height: 4),
                CommonText(
                  'An ideal small pony and great for a Child...',
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: child,
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CommonText(
        text,
        fontSize: 13,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
