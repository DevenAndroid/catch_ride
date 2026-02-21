import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/auth/welcome_screen.dart';
import 'package:catch_ride/view/notifications/notification_screen.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_setup_clipping.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_clipping.dart';
import 'package:catch_ride/view/vendor/bookings/flows/clipping_booking_screens.dart';
import 'package:catch_ride/view/vendor/menu/flows/services_rates_clipping.dart';
import 'package:catch_ride/view/vendor/menu/flows/past_clients_clipping.dart';

/// MenuClippingScreen — Custom Menu mapping directly to Checklist
class MenuClippingScreen extends StatelessWidget {
  const MenuClippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Inside IndexedStack
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // Menu Header Profile
            _buildProfileHeader(context),
            const Divider(height: 32, thickness: 8, color: AppColors.grey100),

            // Top Quick Action: Add Availability
            _buildActionCard(
              icon: Icons.access_time_filled_rounded,
              title: 'Add your Availability',
              subtitle: 'Manage dates and time-blocks',
              color: AppColors.successGreen,
              onTap: () => Get.to(() => const AvailabilityClippingScreen()),
            ),
            const Divider(height: 32, thickness: 1),

            // 1. Account Settings
            _buildSectionHeader('Account Settings'),
            _buildMenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
              onTap: () =>
                  Get.snackbar('Coming Soon', 'Personal Information Settings'),
            ),
            _buildMenuItem(
              icon: Icons.edit_document,
              title: 'Edit Profile',
              subtitle: 'Update clipping profile inputs',
              onTap: () => Get.to(() => const ProfileSetupClippingScreen()),
            ),
            _buildMenuItem(
              icon: Icons.lock_outline_rounded,
              title: 'Login + Sec',
              onTap: () => Get.snackbar('Coming Soon', 'Login and Security'),
            ),
            _buildMenuItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () => Get.to(() => const NotificationScreen()),
            ),
            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: 'Payments and Subscriptions',
              onTap: () => Get.snackbar('Coming Soon', 'Payment Profiles'),
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy and sharing',
              onTap: () => Get.snackbar('Coming Soon', 'Privacy Settings'),
            ),
            const Divider(height: 32, thickness: 1),

            // 2. Business Management
            _buildSectionHeader('Business Management'),
            _buildMenuItem(
              icon: Icons.content_cut_rounded,
              title: 'Services + Rates',
              onTap: () => Get.to(() => const ServicesRatesClippingScreen()),
            ),
            _buildMenuItem(
              icon: Icons.group_outlined,
              title: 'Past Clients',
              onTap: () => Get.to(() => const PastClientsClippingScreen()),
            ),
            _buildMenuItem(
              icon: Icons.calendar_today_outlined,
              title: 'Upcoming Clients',
              onTap: () => Get.to(() => const BookingListClippingScreen()),
            ),
            _buildMenuItem(
              icon: Icons.date_range_rounded,
              title: 'Calendar + Availability',
              onTap: () => Get.to(() => const AvailabilityClippingScreen()),
            ),
            const Divider(height: 32, thickness: 1),

            // 3. Referrals
            _buildSectionHeader('Referrals'),
            _buildMenuItem(
              icon: Icons.card_giftcard_rounded,
              title: 'Refer a new member',
              subtitle: 'Earn rewards for inviting friends',
              onTap: () => Get.snackbar('Coming Soon', 'Referral Code System'),
            ),
            const Divider(height: 32, thickness: 1),

            // 4. Support
            _buildSectionHeader('Support'),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Get Help',
              onTap: () => Get.snackbar('Support', 'Contacting CSR...'),
            ),
            _buildMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Feedback',
              onTap: () =>
                  Get.snackbar('Feedback', 'Submit a bug or feature request'),
            ),
            const Divider(height: 32, thickness: 1),

            // 5. Tools
            _buildSectionHeader('Tools'),
            _buildMenuItem(
              icon: Icons.article_outlined,
              title: 'Terms of Service',
              onTap: () => Get.snackbar('ToS', 'View Terms of Service'),
            ),
            _buildMenuItem(
              icon: Icons.shield_outlined,
              title: 'Privacy Policy',
              onTap: () => Get.snackbar('Privacy', 'View Privacy Policy'),
            ),
            const SizedBox(height: 32),

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
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.mutedGold.withOpacity(0.15),
            child: Text(
              'JR',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.mutedGold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jamie Roberts', // Mock name
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.mutedGold,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.9 (124 reviews)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.grey500,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Color color = AppColors.deepNavy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.deepNavy, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
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
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
