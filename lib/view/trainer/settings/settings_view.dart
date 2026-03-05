import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/trainer/settings/privacy_policy_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/view/trainer/settings/profile_information_view.dart';
import 'package:catch_ride/view/trainer/settings/account_settings_view.dart';
import 'package:catch_ride/view/trainer/settings/notification_settings_view.dart';
import 'package:catch_ride/view/trainer/settings/invite_barn_manager_view.dart';
import 'package:catch_ride/view/trainer/settings/terms_and_conditions_view.dart';
import 'package:catch_ride/view/trainer/settings/edit_profile.dart';
import 'package:catch_ride/view/trainer/settings/horses_services_view.dart';
import 'package:catch_ride/view/trainer/settings/refer_new_member_view.dart';
import 'package:catch_ride/view/trainer/settings/get_help_view.dart';
import 'package:catch_ride/view/trainer/settings/feedback_view.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/profile_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: CommonText(
            'Profile',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Obx(() => _buildProfileCard(controller)),
            const SizedBox(height: 20),

            // Add a horse banner
            _buildAddHorseBanner(),
            const SizedBox(height: 24),

            _buildSectionHeader('Account Settings'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.edit_note_rounded,
                title: 'Edit Profile',
                onTap: () => Get.to(() => const EditProfileView()),
              ),
              _buildSettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Personal Information',
                onTap: () => Get.to(() => const ProfileInformationView()),
              ),
              _buildSettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'Login & Security',
                onTap: () => Get.to(() => const AccountSettingsView()),
              ),
              _buildSettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () => Get.to(() => const NotificationSettingsView()),
              ),
              _buildSettingsTile(
                icon: Icons.pest_control_rodent_outlined, // Closer to horse icon in standard icons or use SVG
                title: 'Horses & Services',
                onTap: () => Get.to(() => const HorsesServicesView()),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('Referrals'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.person_add_alt_1_outlined,
                title: 'Invite Barn Manager',
                onTap: () => Get.to(() => const InviteBarnManagerView()),
              ),
              _buildSettingsTile(
                icon: Icons.group_add_outlined,
                title: 'Refer a New Members',
                onTap: () => Get.to(() => const ReferNewMemberView()),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('Support'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Get Help',
                onTap: () => Get.to(() => const GetHelpView()),
              ),
              _buildSettingsTile(
                icon: Icons.mode_comment_outlined,
                title: 'Share your feedback',
                onTap: () => Get.to(() => const FeedbackView()),
              ),
              _buildSettingsTile(
                icon: Icons.assignment_outlined,
                title: 'Privacy policy',
                onTap: () => Get.to(() => const PrivacyPolicyView()),
              ),
              _buildSettingsTile(
                icon: Icons.assignment_outlined,
                title: 'Terms & conditions',
                onTap: () => Get.to(() => const TermsAndConditionsView()),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ProfileController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          CommonImageView(
            url: controller.avatar.isNotEmpty ? controller.avatar : AppConstants.dummyImageUrl,
            height: 80,
            width: 80,
            shape: BoxShape.circle,
          ),
          const SizedBox(height: 16),
          CommonText(
            controller.fullName.isNotEmpty ? controller.fullName : 'User Name',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 4),
          CommonText(
            controller.specialization,
            fontSize: 14,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            child: const CommonText(
              'View Profile',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E90FA), // Blue color from image
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddHorseBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF000B48),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pest_control_rodent_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonText(
                  'Add a horse',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 2),
                CommonText(
                  "It's simple to get set up and start earning.",
                  fontSize: 13,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: CommonText(
        title,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.textSecondary),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonText(
                    title,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 54),
              child: Divider(
                height: 1,
                color: AppColors.border.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(Get.context!),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, size: 20, color: Color(0xFFD92D20)),
            SizedBox(width: 10),
            CommonText(
              'Logout',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD92D20),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFD92D20), size: 28),
              ),
              const SizedBox(height: 20),
              const CommonText(
                'Are you sure you want to logout?',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: CommonText('Cancel', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        if (Get.isRegistered<AuthController>()) {
                          Get.find<AuthController>().logout();
                        } else {
                          Get.put(AuthController()).logout();
                        }
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD92D20),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CommonText('Logout', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
