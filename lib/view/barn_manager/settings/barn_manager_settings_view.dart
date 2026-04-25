import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/barn_manager/settings/privacy_policy_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/view/barn_manager/settings/profile_information_view.dart';
import 'package:catch_ride/view/barn_manager/settings/account_settings_view.dart';
import 'package:catch_ride/view/barn_manager/settings/notification_settings_view.dart';
import 'package:catch_ride/view/barn_manager/settings/terms_and_conditions_view.dart';
import 'package:catch_ride/view/barn_manager/settings/edit_profile.dart';
import 'package:catch_ride/view/barn_manager/settings/get_help_view.dart';
import 'package:catch_ride/view/barn_manager/settings/feedback_view.dart';
import 'package:catch_ride/view/barn_manager/settings/barn_manager_profile_view.dart';
import 'package:catch_ride/view/barn_manager/settings/past_services_view.dart';
import 'package:catch_ride/view/barn_manager/settings/view_all_horses_view.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/profile_controller.dart';
import '../../trainer/settings/account_settings_view.dart';
import '../../trainer/settings/feedback_view.dart';
import '../../trainer/settings/get_help_view.dart';
import '../../trainer/settings/notification_settings_view.dart';
import '../../trainer/settings/notifications_view.dart';
import '../../trainer/settings/privacy_policy_view.dart';
import '../../trainer/settings/profile_information_view.dart';
import '../../trainer/settings/terms_and_conditions_view.dart';
import '../list/barn_manager_horse_listing_view.dart';

class BarnManagerSettingsView extends StatelessWidget {
  const BarnManagerSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const CommonText(
          'Profile',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF101828),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFF344054),
                  size: 24,
                ),
                onPressed: ()=> Get.to(()=> NotificationsView()),
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
            const SizedBox(height: 16),

            // Manage Your Horses Banner
            _buildManageHorsesBanner(),
            const SizedBox(height: 24),

          //  const SizedBox(height: 32),

            _buildSectionHeader('Account Settings'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () => Get.to(() => const EditBarnManagerProfileView()),
              ),
              _buildSettingsTile(
                icon: Icons.person_outline,
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
                icon: Icons.visibility_outlined,
                title: 'View all Horses',
            //   onTap: () => Get.to(() => const ViewAllHorsesView()),
                onTap: () => Get.to(() => const BarnManagerHorseListingView()),
              ),
              _buildSettingsTile(
                icon: Icons.history,
                title: 'Past Services and Trials',
                onTap: () => Get.to(() => const PastServicesView()),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 24),

            const SizedBox(height: 16),

            _buildSectionHeader('Support'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Get Help',
                onTap: () => Get.to(() => const GetHelpView()),
              ),
              _buildSettingsTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Share your feedback',
                onTap: () => Get.to(() => const FeedbackView()),
              ),
              _buildSettingsTile(
                icon: Icons.article_outlined,
                title: 'Privacy policy',
                onTap: () => Get.to(() => const PrivacyPolicyView()),
              ),
              _buildSettingsTile(
                icon: Icons.article_outlined,
                title: 'Terms & conditions',
                onTap: () => Get.to(() => const TermsAndConditionsView()),
                showDivider: false,
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionHeader('Account'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Account',
                onTap: () => showDeleteAccountDialog(context),
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
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CommonImageView(
            url: controller.avatar.isNotEmpty
                ? controller.avatar
                : 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
            height: 85,
            width: 85,
            shape: BoxShape.circle,
          ),
          const SizedBox(height: 16),
          CommonText(
            controller.fullName.isNotEmpty ? controller.fullName : 'Arya Stark',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF101828),
          ),
          const SizedBox(height: 4),
          CommonText(
            controller.linkedTrainerBarnName.isNotEmpty
                ? 'Barn Manager at ${controller.linkedTrainerBarnName}'
                : 'Barn Manager',
            fontSize: 14,
            color: const Color(0xFF667085),
            fontWeight: FontWeight.w400,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Get.to(() => const BarnManagerProfileView()),
            child: const CommonText(
              'View Profile',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E90FA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageHorsesBanner() {
    return InkWell(
      onTap: ()=>Get.to(()=> const BarnManagerHorseListingView(),),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAECF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                children: const [
                  CommonText(
                    'Manage Your horses',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                  SizedBox(height: 2),
                  CommonText(
                    'Edit availability for yours trainer\'s current string.',
                    fontSize: 13,
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
          ],
        ),
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
