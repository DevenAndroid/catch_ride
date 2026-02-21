import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/auth/welcome_screen.dart';
import 'package:catch_ride/view/notifications/notification_screen.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/controllers/user_role_controller.dart';
import 'package:catch_ride/view/profile/personal_info_screen.dart';
import 'package:catch_ride/view/profile/login_security_screen.dart';
import 'package:catch_ride/view/settings/terms_conditions_screen.dart';
import 'package:catch_ride/view/barn_manager/manage_horses/barn_manager_horse_list_screen.dart';
import 'package:catch_ride/view/trainer/book_service/vendor_search_screen.dart';
import 'package:catch_ride/view/support/feedback_screen.dart';
import 'package:catch_ride/view/barn_manager/profile/edit_profile_barn_manager_screen.dart';

class BarnManagerMenuScreen extends StatelessWidget {
  const BarnManagerMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roleController = Get.find<UserRoleController>();

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
            // Profile Header with "Managing on behalf of" label
            _buildProfileHeader(roleController),
            const Divider(height: 1, thickness: 1, color: AppColors.grey200),

            // "Managing on behalf of" Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.deepNavy.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.supervised_user_circle,
                    color: AppColors.deepNavy,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Managing on behalf of',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        Obx(
                          () => Text(
                            '${roleController.linkedTrainerName.value} — ${roleController.linkedStableName.value}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.deepNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Add your horses',
                  onPressed: () {
                    // Usually links to new listing
                    Get.snackbar(
                      'Permission Denied',
                      'Barn Managers cannot create new horses. Please ask the Trainer.',
                    );
                  },
                  backgroundColor: AppColors.mutedGold,
                  textColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Account Settings
            _buildSectionHeader('Account Settings'),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                Get.to(() => const EditProfileBarnManagerScreen());
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Personal Information',
              onTap: () {
                Get.to(() => const PersonalInfoScreen());
              },
            ),
            _buildMenuItem(
              icon: Icons.security_outlined,
              title: 'Login & Security',
              onTap: () {
                Get.to(() => const LoginSecurityScreen());
              },
            ),
            _buildMenuItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () => Get.to(() => const NotificationScreen()),
            ),

            const Divider(height: 32, thickness: 1),

            // Horses & Services
            _buildSectionHeader('Management'),
            _buildMenuItem(
              icon: Icons.list_alt_outlined,
              title: 'Manage Horses',
              subtitle: 'Availability & location updates',
              onTap: () {
                Get.to(() => const BarnManagerHorseListScreen());
              },
            ),
            _buildMenuItem(
              icon: Icons.handyman_outlined,
              title: 'Book a Service',
              subtitle: 'Request vendor services on behalf of trainer',
              onTap: () {
                Get.to(() => const VendorSearchScreen());
              },
            ),

            const Divider(height: 32, thickness: 1),

            // Support Section
            _buildSectionHeader('Support'),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Get Help',
              onTap: () {
                Get.snackbar('Coming Soon', 'Help Center');
              },
            ),
            _buildMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Give us feedback',
              onTap: () {
                Get.to(() => const FeedbackScreen());
              },
            ),

            const Divider(height: 32, thickness: 1),

            // Tools Section
            _buildSectionHeader('Tools'),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () {
                Get.to(() => const TermsConditionsScreen());
              },
            ),

            const SizedBox(height: 48),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
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
            Text(
              'Version 1.0.0',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserRoleController roleController) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&q=80&w=800',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: AppColors.deepNavy),
                  onPressed: () =>
                      Get.snackbar('Photo', 'Update cover photo...'),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey200,
                  border: Border.all(color: Colors.white, width: 3),
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/150'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sarah Connor',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mutedGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Barn Manager',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.mutedGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.to(() => const EditProfileBarnManagerScreen());
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
        ),
      ],
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
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.deepNavy, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
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
