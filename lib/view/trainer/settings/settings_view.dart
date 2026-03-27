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
import 'package:catch_ride/view/trainer/settings/trainer_profile_view.dart';
import 'package:catch_ride/view/trainer/settings/view_all_horses_view.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/profile_controller.dart';
import '../list/add_new_listing_view.dart';
import '../bookings/trainer_past_bookings_view.dart';
import 'notifications_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: CommonText(
            'Profile',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                onPressed: () => Get.to(() => const NotificationsView()),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Obx(() => _buildProfileCard(controller)),
            const SizedBox(height: 20),

            // Add a horse banner
            GestureDetector(
              onTap: () => Get.to(() => const AddNewListingView()),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00083B),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        "assets/images/logo.svg",
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CommonText(
                            'Add your horses',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00083B),
                          ),
                          CommonText(
                            'Create a listing to share availability.',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Account Settings'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () => Get.to(() => const EditProfileView()),
              ),
              _buildSettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Personal Information',
                onTap: () => Get.to(() => const ProfileInformationView()),
              ),
              _buildSettingsTile(
                icon: Icons.shield_outlined,
                title: 'Login & Security',
                onTap: () => Get.to(() => const AccountSettingsView()),
              ),
              _buildSettingsTile(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                onTap: () => Get.to(() => const NotificationSettingsView()),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('Horses & Services'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.add_circle_outline_rounded,
                title: 'List Your Horses',
                onTap: () => Get.to(() => const AddNewListingView()),
              ),
              _buildSettingsTile(
                icon: Icons.visibility_outlined,
                title: 'View all Horses',
                onTap: () => Get.to(() => const ViewAllHorsesView()),
              ),
              _buildSettingsTile(
                icon: Icons.history_rounded,
                title: 'Past Services and Trials',
                onTap: () => Get.to(() => const TrainerPastBookingsView()),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('Referrals'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.person_add_alt_outlined,
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
                icon: Icons.description_outlined,
                title: 'Privacy policy',
                onTap: () => Get.to(() => const PrivacyPolicyView()),
              ),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms & conditions',
                onTap: () => Get.to(() => const TermsAndConditionsView()),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ProfileController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.2),
              ),
            ),
            child: CommonImageView(
              url: controller.avatar,
              height: 90,
              width: 90,
              shape: BoxShape.circle,
              isUserImage: true,
            ),

          ),
          const SizedBox(height: 16),
          CommonText(
            controller.fullName.isNotEmpty ? controller.fullName : '',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 4),
          CommonText(
            controller.barnName.isNotEmpty ? controller.barnName : '',
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Get.to(() => TrainerProfileView()),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const CommonText(
              'View Profile',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.linkBlue,
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
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
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
                Icon(icon, size: 24, color: AppColors.textSecondary),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonText(
                    title,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Divider(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(Get.context!),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEAECF0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, size: 22, color: Color(0xFFF04438)),
            SizedBox(width: 10),
            CommonText(
              'Logout',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF04438),
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
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFD92D20),
                  size: 28,
                ),
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
                          child: CommonText(
                            'Cancel',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
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
                          child: CommonText(
                            'Logout',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
