import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

import 'package:catch_ride/view/vendor/profile/flows/profile_setup_braiding.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_braiding.dart';
import 'package:catch_ride/view/vendor/menu/flows/services_rates_braiding.dart';
import 'package:catch_ride/view/vendor/menu/flows/past_clients_braiding.dart';
import 'package:catch_ride/view/vendor/bookings/flows/braiding_booking_screens.dart';

import 'package:catch_ride/view/auth/welcome_screen.dart';
import 'package:catch_ride/view/notifications/notification_screen.dart';

class MenuBraidingScreen extends StatelessWidget {
  const MenuBraidingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.grey50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // Banner Alert
            _buildActionBanner(
              'Add your Availability',
              Icons.calendar_month_outlined,
              () => Get.to(() => const AvailabilityBraidingScreen()),
            ),
            const SizedBox(height: 16),

            // Account Settings
            _buildSectionHeader('Account Settings'),
            _buildCard([
              _buildRow(
                'Personal Information',
                Icons.person_outline,
                () => Get.snackbar('Coming Soon', 'Personal Info'),
              ),
              _buildRow(
                'Edit Profile',
                Icons.edit_outlined,
                () => Get.to(() => const ProfileSetupBraidingScreen()),
              ),
              _buildRow(
                'Login & Security',
                Icons.lock_outline,
                () => Get.snackbar('Coming Soon', 'Security'),
              ),
              _buildRow(
                'Notifications',
                Icons.notifications_none,
                () => Get.to(() => const NotificationScreen()),
              ),
              _buildRow(
                'Payments and Subscriptions',
                Icons.payment_outlined,
                () => Get.snackbar('Coming Soon', 'Payments'),
              ),
              _buildRow(
                'Privacy and Sharing',
                Icons.privacy_tip_outlined,
                () => Get.snackbar('Coming Soon', 'Privacy'),
                isLast: true,
              ),
            ]),

            // Business Links
            _buildSectionHeader('Business'),
            _buildCard([
              _buildRow(
                'Services & Rates',
                Icons.attach_money,
                () => Get.to(() => const ServicesRatesBraiderScreen()),
              ),
              _buildRow(
                'Past Clients',
                Icons.people_outline,
                () => Get.to(() => const PastClientsBraiderScreen()),
              ),
              _buildRow(
                'Upcoming Clients',
                Icons.calendar_today_outlined,
                () => Get.to(() => const BookingListBraiderScreen()),
              ),
              _buildRow(
                'Calendar & Availability',
                Icons.event_available,
                () => Get.to(() => const AvailabilityBraidingScreen()),
                isLast: true,
              ),
            ]),

            // Referrals
            _buildSectionHeader('Referrals'),
            _buildCard([
              _buildRow(
                'Refer a new member',
                Icons.card_giftcard,
                () => Get.snackbar('Coming Soon', 'Referral Options'),
                isLast: true,
              ),
            ]),

            // Support
            _buildSectionHeader('Support'),
            _buildCard([
              _buildRow(
                'Get Help',
                Icons.help_outline,
                () => Get.snackbar('Coming Soon', 'Support Desk'),
              ),
              _buildRow(
                'Feedback',
                Icons.feedback_outlined,
                () => Get.snackbar('Coming Soon', 'Submit Feedback'),
                isLast: true,
              ),
            ]),

            // Tools
            _buildSectionHeader('Tools'),
            _buildCard([
              _buildRow(
                'Terms of Service',
                Icons.gavel_outlined,
                () => Get.snackbar('Coming Soon', 'TOS'),
              ),
              _buildRow(
                'Privacy Policy',
                Icons.policy_outlined,
                () => Get.snackbar('Coming Soon', 'Privacy Policy'),
                isLast: true,
              ),
            ]),

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
                    backgroundColor: Colors.white,
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

  Widget _buildActionBanner(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.deepNavy,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepNavy.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.grey600,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow(
    String text,
    IconData icon,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(16))
          : BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.grey100, width: 1),
                ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.deepNavy),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}
