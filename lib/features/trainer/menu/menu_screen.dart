import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/auth/welcome_screen.dart';
import 'package:catch_ride/view/notifications/notification_screen.dart';
import 'package:catch_ride/view/trainer/barn_manager/invite_barn_manager_screen.dart';
import 'package:catch_ride/view/trainer/list/list_screen.dart';
import 'package:catch_ride/view/trainer/onboarding/profile_complete_trainer_screen.dart';
import 'package:catch_ride/view/trainer/listing/horse_listing_create_screen.dart';
import 'package:catch_ride/view/trainer/profile/trainer_profile_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            const Divider(height: 32, thickness: 8, color: AppColors.grey100),

            // Top Action: Add your horses
            _buildMenuItem(
              icon: Icons.add_circle_outline,
              title: 'Add your horses',
              subtitle: 'Create a new listing',
              onTap: () {
                Get.to(() => const HorseListingCreateScreen());
              },
              isProminent: true,
            ),
            const Divider(height: 32, thickness: 1),

            // Account Settings
            _buildSectionHeader('Account Settings'),
            _buildMenuItem(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () => Get.to(() => const ProfileCompleteTrainerScreen()),
            ),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: () =>
                  Get.snackbar('Coming Soon', 'Personal Information Screen'),
            ),
            _buildMenuItem(
              icon: Icons.security_outlined,
              title: 'Login & Security',
              onTap: () =>
                  Get.snackbar('Coming Soon', 'Login & Security Screen'),
            ),
            _buildMenuItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () => Get.to(() => const NotificationScreen()),
            ),
            // Payment menu removed
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy + Sharing',
              onTap: () =>
                  Get.snackbar('Coming Soon', 'Privacy + Sharing Screen'),
            ),

            const Divider(height: 32, thickness: 1),

            // Horses + Services
            _buildSectionHeader('Horses + Services'),
            _buildMenuItem(
              icon: Icons.add_box_outlined,
              title: 'List your horse',
              onTap: () => Get.to(() => const HorseListingCreateScreen()),
            ),
            _buildMenuItem(
              icon: Icons.inventory_2_outlined,
              title: 'View your horses',
              onTap: () => Get.to(() => const ListScreen()),
            ),
            _buildMenuItem(
              icon: Icons.history_outlined,
              title: 'Past Services + Trials',
              onTap: () => Get.snackbar('Coming Soon', 'Past Services Screen'),
            ),

            const Divider(height: 32, thickness: 1),

            // Referrals
            _buildSectionHeader('Referrals'),
            _buildMenuItem(
              icon: Icons.people_outline,
              title: 'Barn Managers',
              onTap: () => Get.to(() => const InviteBarnManagerScreen()),
            ),
            _buildMenuItem(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Refer a new Member',
              onTap: () => Get.snackbar('Coming Soon', 'Referral Screen'),
            ),

            const Divider(height: 32, thickness: 1),

            // Support
            _buildSectionHeader('Support'),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Get Help',
              onTap: () => Get.snackbar('Coming Soon', 'Help Screen'),
            ),
            _buildMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Give us feedback',
              onTap: () => Get.snackbar('Coming Soon', 'Feedback Form'),
            ),

            const Divider(height: 32, thickness: 1),

            // Tools
            _buildSectionHeader('Tools'),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: 'Terms + Conditions',
              onTap: () => Get.snackbar('Coming Soon', 'Terms Screen'),
            ),

            const SizedBox(height: 48),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Clear Session Logic
                    Get.offAll(() => const WelcomeScreen());
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.softRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: AppColors.softRed,
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Version 1.0.0',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return InkWell(
      onTap: () =>
          Get.to(() => const TrainerProfileScreen(isVisitingOwnProfile: true)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mutedGold.withOpacity(0.2),
                border: Border.all(color: AppColors.mutedGold, width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Smith',
                    style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wellington Stables',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'View Profile',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.deepNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.grey500,
            letterSpacing: 1.2,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isProminent = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isProminent ? AppColors.warmCream.withOpacity(0.3) : null,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isProminent ? AppColors.deepNavy : AppColors.grey50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isProminent ? Colors.white : AppColors.deepNavy,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: isProminent
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isProminent
                          ? AppColors.deepNavy
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
