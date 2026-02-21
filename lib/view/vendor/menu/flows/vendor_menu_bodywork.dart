import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

import 'package:catch_ride/view/auth/welcome_screen.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_complete_bodywork.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_bodywork.dart';
import 'package:catch_ride/view/vendor/bookings/vendor_bookings_screen.dart';

import 'package:catch_ride/view/vendor/menu/flows/services_rates_bodywork.dart';
import 'package:catch_ride/view/vendor/menu/flows/past_clients_bodywork.dart';
import 'package:catch_ride/view/vendor/menu/flows/insurance_upload_bodywork.dart';

class VendorMenuBodyworkScreen extends StatelessWidget {
  const VendorMenuBodyworkScreen({super.key});

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

            // Top CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Get.to(() => const AvailabilityBodyworkScreen()),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Add your Availability'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mutedGold,
                    foregroundColor: AppColors.deepNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Account Settings
            _buildSectionHeader('Account Settings'),
            _buildMenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
              onTap: () => Get.snackbar('Coming Soon', 'Personal Info'),
            ),
            _buildMenuItem(
              icon: Icons.badge_outlined,
              title: 'Edit Profile',
              onTap: () => Get.to(() => const ProfilePageBodyworkScreen()),
            ),
            _buildMenuItem(
              icon: Icons.lock_outline_rounded,
              title: 'Login + Sec',
              onTap: () => Get.snackbar('Coming Soon', 'Login info'),
            ),
            _buildMenuItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () => Get.snackbar('Coming Soon', 'Notifications'),
            ),
            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: 'Payments and Subscriptions',
              onTap: () => Get.snackbar('Coming Soon', 'Payments'),
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy and sharing',
              onTap: () => Get.snackbar('Coming Soon', 'Privacy options'),
            ),

            const Divider(height: 32, thickness: 1),

            // Business Links
            _buildMenuItem(
              icon: Icons.attach_money_rounded,
              title: 'Services + Rates',
              onTap: () => Get.to(() => const ServicesRatesBodyworkScreen()),
            ),
            _buildMenuItem(
              icon: Icons.history_rounded,
              title: 'Past Clients',
              onTap: () => Get.to(() => const PastClientsBodyworkScreen()),
            ),
            _buildMenuItem(
              icon: Icons.calendar_month_rounded,
              title: 'Upcoming Clients',
              onTap: () => Get.to(() => const VendorBookingsScreen()),
            ),
            _buildMenuItem(
              icon: Icons.edit_calendar_rounded,
              title: 'Calendar + Availability',
              onTap: () => Get.to(() => const AvailabilityBodyworkScreen()),
            ),

            // Insurance explicitly marked
            _buildMenuItem(
              icon: Icons.verified_user_outlined,
              title: 'Insurance Upload',
              subtitle: 'Current status: Insurance on file',
              onTap: () => Get.to(() => const InsuranceUploadBodyworkScreen()),
            ),

            const Divider(height: 32, thickness: 1),

            // Referrals
            _buildSectionHeader('Referrals'),
            _buildMenuItem(
              icon: Icons.card_giftcard_rounded,
              title: 'Refer a new member',
              onTap: () => Get.snackbar('Invite', 'Share your referral code!'),
            ),

            const Divider(height: 32, thickness: 1),

            // Support
            _buildSectionHeader('Support'),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Get Help',
              onTap: () => Get.snackbar('Support', 'Contacting Support...'),
            ),
            _buildMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Feedback',
              onTap: () => Get.snackbar('Feedback', 'Submit feedback'),
            ),

            const Divider(height: 32, thickness: 1),

            // Tools
            _buildSectionHeader('Tools'),
            _buildMenuItem(
              icon: Icons.article_outlined,
              title: 'Terms of Service',
              onTap: () => Get.snackbar('Legal', 'Terms of Service'),
            ),
            _buildMenuItem(
              icon: Icons.security_outlined,
              title: 'Privacy Policy',
              onTap: () => Get.snackbar('Legal', 'Privacy Policy'),
            ),

            const SizedBox(height: 48),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Get.offAll(() => const WelcomeScreen()),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.softRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: AppColors.softRed,
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

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.deepNavy,
            ),
            child: Center(
              child: Text(
                'LH',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.mutedGold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Lisa Holt',
                  style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Bodywork Specialist',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.to(() => const ProfilePageBodyworkScreen()),
            icon: const Icon(Icons.edit_outlined, color: AppColors.deepNavy),
            tooltip: 'View Profile',
          ),
        ],
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
