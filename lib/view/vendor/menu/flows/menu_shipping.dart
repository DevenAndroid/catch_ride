import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_setup_shipping.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_shipping.dart';
import 'package:catch_ride/view/vendor/shipping/flows/list_load_shipping.dart';
import 'package:catch_ride/view/vendor/shipping/flows/create_load_shipping.dart';
import 'package:catch_ride/view/vendor/menu/flows/past_clients_shipping.dart';
import 'package:catch_ride/view/vendor/menu/flows/operations_compliance_shipping.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/app_colors.dart';

/// MenuShipping — Vendor Menu for the Shipping service type
class MenuShippingScreen extends StatelessWidget {
  const MenuShippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // ── Account Settings (Profile Header) ──
            _buildProfileHeader(),

            const Divider(height: 32, thickness: 8, color: AppColors.grey100),

            // ── Specialized Banner ──
            _buildLoadBanner(),

            const SizedBox(height: 16),

            // ── Business Section ──
            _sectionHeader('Business Operations'),
            _buildMenuItem(
              icon: Icons.local_shipping_rounded,
              title: 'Manage Loads',
              subtitle: 'Post and manage your active runs',
              onTap: () => Get.to(() => const ListLoadShippingScreen()),
            ),
            _buildMenuItem(
              icon: Icons.history_rounded,
              title: 'Past Clients',
              subtitle: 'View completed bookings & history',
              onTap: () => Get.to(() => const PastClientsShippingScreen()),
            ),
            _buildMenuItem(
              icon: Icons.verified_user_outlined,
              title: 'Operations & Compliance',
              subtitle: 'Insurance docs & service status',
              onTap: () =>
                  Get.to(() => const OperationsComplianceShippingScreen()),
            ),
            _buildMenuItem(
              icon: Icons.access_time_filled_rounded,
              title: 'Availability Shortcut',
              subtitle: 'Manage your calendar & open dates',
              onTap: () => Get.to(() => const AvailabilityShippingScreen()),
            ),

            const Divider(height: 32, thickness: 1),

            _sectionHeader('Trust & Community'),
            _buildMenuItem(
              icon: Icons.card_giftcard_rounded,
              title: 'Refer a Member',
              subtitle: 'Earn rewards for new signups',
              onTap: () =>
                  Get.snackbar('Referrals', 'Opening referral dashboard...'),
            ),
            _buildMenuItem(
              icon: Icons.help_center_outlined,
              title: 'Get Help',
              onTap: () =>
                  Get.snackbar('Support', 'Connecting to help center...'),
            ),
            _buildMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Share Feedback',
              onTap: () => Get.snackbar('Feedback', 'We value your input!'),
            ),

            const Divider(height: 32, thickness: 1),
            const SizedBox(height: 24),

            // Logout
            _buildLogoutButton(),
            const SizedBox(height: 20),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.deepNavy,
            child: Text(
              'BC',
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
                Text('Cole Equine Transport', style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mutedGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'SHIPPER',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mutedGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.to(() => const ProfileSetupShippingScreen()),
            icon: const Icon(Icons.edit_outlined, color: AppColors.deepNavy),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepNavy, Color(0xFF1A2A4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have empty slots?',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Post a run and fill your trailer.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      Get.to(() => const CreateLoadShippingScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mutedGold,
                    foregroundColor: AppColors.deepNavy,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'List a Load',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.local_shipping_rounded,
            size: 48,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.grey500,
            letterSpacing: 1.2,
            fontSize: 11,
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
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => Get.snackbar('Logout', 'Logging out...'),
          icon: const Icon(Icons.logout_rounded),
          label: const Text(
            'Log Out',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppColors.softRed),
            foregroundColor: AppColors.softRed,
          ),
        ),
      ),
    );
  }
}
