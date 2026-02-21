import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_groom.dart';
import 'package:catch_ride/view/vendor/services/edit_groom_services_rates_screen.dart';
import 'package:catch_ride/view/vendor/clients/past_groom_clients_screen.dart';
import 'package:catch_ride/view/vendor/bookings/flows/groom_booking_screens.dart';
import 'package:catch_ride/view/vendor/profile/edit_vendor_profile_screen.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_complete_groom.dart';
import 'package:catch_ride/view/auth/welcome_screen.dart';

/// MenuGroomScreen — Specialized menu for Groom vendors
class MenuGroomScreen extends StatelessWidget {
  const MenuGroomScreen({super.key});

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
            // Header
            _buildProfileHeader(),
            const Divider(height: 32, thickness: 8, color: AppColors.grey100),

            // 1. Availability Section
            _buildSectionHeader('Management'),
            _buildMenuItem(
              icon: Icons.add_circle_outline_rounded,
              title: 'Add your Availability',
              subtitle: 'Update your calendar and show circuits',
              onTap: () => Get.to(() => const AvailabilityGroomScreen()),
            ),
            _buildMenuItem(
              icon: Icons.payments_outlined,
              title: 'Services + Rates',
              subtitle: 'Manage show prep, day rates, and skills',
              onTap: () => Get.to(() => const EditGroomServicesRatesScreen()),
            ),
            _buildMenuItem(
              icon: Icons.people_outline_rounded,
              title: 'Past Clients',
              subtitle: 'View history and message past trainers',
              onTap: () => Get.to(() => const PastGroomClientsScreen()),
            ),
            _buildMenuItem(
              icon: Icons.calendar_today_outlined,
              title: 'Upcoming Clients',
              subtitle: 'View your booking list',
              onTap: () => Get.to(() => const BookingListGroomScreen()),
            ),
            _buildMenuItem(
              icon: Icons.event_available_rounded,
              title: 'Calendar + Availability',
              onTap: () => Get.to(() => const AvailabilityGroomScreen()),
            ),

            const Divider(height: 32, thickness: 1),

            // 2. Account Settings Section
            _buildSectionHeader('Account Settings'),
            _buildMenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
              onTap: () => Get.to(() => const EditVendorProfileScreen()),
            ),
            _buildMenuItem(
              icon: Icons.edit_note_rounded,
              title: 'Edit Profile',
              subtitle: 'View and edit your public profile',
              onTap: () => Get.to(() => const ProfilePageGroomScreen()),
            ),
            _buildMenuItem(
              icon: Icons.lock_outline_rounded,
              title: 'Login & Security',
              onTap: () => Get.snackbar('Coming Soon', 'Security settings'),
            ),
            _buildMenuItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () => Get.snackbar('Coming Soon', 'Notification settings'),
            ),
            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: 'Payments and Subscriptions',
              onTap: () => Get.snackbar('Coming Soon', 'Payment management'),
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy and sharing',
              onTap: () => Get.snackbar('Coming Soon', 'Privacy settings'),
            ),

            const Divider(height: 32, thickness: 1),

            // 3. Referrals Section
            _buildSectionHeader('Referrals'),
            _buildMenuItem(
              icon: Icons.card_giftcard_rounded,
              title: 'Refer a new member',
              subtitle: 'Get rewards for invites',
              onTap: () => Get.snackbar('Referrals', 'Invite friends logic'),
            ),

            const Divider(height: 32, thickness: 1),

            // 4. Support
            _buildSectionHeader('Support'),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Get Help',
              onTap: () => Get.snackbar('Support', 'Help Center'),
            ),
            _buildMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Feedback',
              onTap: () => Get.snackbar('Feedback', 'Leave a review'),
            ),

            const Divider(height: 32, thickness: 1),

            // 5. Tools
            _buildSectionHeader('Tools'),
            _buildMenuItem(
              icon: Icons.article_outlined,
              title: 'Terms of Service',
              onTap: () => Get.snackbar('Coming Soon', 'TOS'),
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => Get.snackbar('Coming Soon', 'Privacy Policy'),
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
                    'Log Out',
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
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.deepNavy,
            child: Text(
              'JS',
              style: TextStyle(
                color: AppColors.mutedGold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
                  'Elite Grooming Services',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.mutedGold,
                    ),
                    const SizedBox(width: 4),
                    Text('4.8 (124 reviews)', style: AppTextStyles.bodySmall),
                  ],
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
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.grey500,
            letterSpacing: 1.1,
            fontSize: 11,
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
            Icon(icon, color: AppColors.deepNavy, size: 22),
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
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}
