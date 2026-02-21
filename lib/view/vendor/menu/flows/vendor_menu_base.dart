import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/auth/welcome_screen.dart';
import 'package:catch_ride/view/notifications/notification_screen.dart';
import 'package:catch_ride/view/vendor/profile/edit_vendor_profile_screen.dart';
import 'package:catch_ride/view/vendor/services/edit_services_rates_screen.dart';
import 'package:catch_ride/view/vendor/earnings/vendor_earnings_screen.dart';
import 'package:catch_ride/view/reviews/review_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Shared menu item data class  (public so specialty screens can use it)
// ─────────────────────────────────────────────────────────────────────────────

class VendorMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const VendorMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  VendorMenuBase
//  Fully wired settings/menu screen shared across all 6 vendor service types.
// ─────────────────────────────────────────────────────────────────────────────

class VendorMenuBase extends StatelessWidget {
  final String vendorName;
  final String vendorInitials;
  final String serviceLabel;
  final IconData serviceIcon;
  final double rating;
  final int reviewCount;

  /// Extra items injected into the Business section (service-specific)
  final List<VendorMenuItem> specialtyItems;

  /// Custom action for the Edit Profile button
  final VoidCallback? onEditProfile;

  const VendorMenuBase({
    super.key,
    this.vendorName = 'John Smith',
    this.vendorInitials = 'JS',
    required this.serviceLabel,
    required this.serviceIcon,
    this.rating = 4.8,
    this.reviewCount = 124,
    this.specialtyItems = const [],
    this.onEditProfile,
  });

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
            // ── Profile Header ──────────────────────────────────────────
            _buildProfileHeader(context),
            const Divider(height: 32, thickness: 8, color: AppColors.grey100),

            // ── Business Section ────────────────────────────────────────
            _buildSectionHeader('Business'),

            // Service-specific items first
            ...specialtyItems.map(_buildMenuItem),

            // Common business items
            _buildMenuItem(
              VendorMenuItem(
                icon: Icons.attach_money_rounded,
                title: 'Services & Rates',
                subtitle: 'Update pricing for your services',
                onTap: () => Get.to(() => const EditServicesRatesScreen()),
              ),
            ),
            _buildMenuItem(
              VendorMenuItem(
                icon: Icons.star_outline_rounded,
                title: 'My Reviews',
                subtitle: 'View client feedback',
                onTap: () => Get.to(() => const ReviewScreen()),
              ),
            ),
            _buildMenuItem(
              VendorMenuItem(
                icon: Icons.bar_chart_outlined,
                title: 'Earnings & Stats',
                subtitle: 'Revenue breakdown & booking history',
                onTap: () => Get.to(() => const VendorEarningsScreen()),
              ),
            ),

            const Divider(height: 32, thickness: 1),

            // ── Account Section ─────────────────────────────────────────
            _buildSectionHeader('Account'),
            _buildMenuItem(
              VendorMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                subtitle: 'Update your public profile',
                onTap:
                    onEditProfile ??
                    () => Get.to(() => const EditVendorProfileScreen()),
              ),
            ),
            _buildMenuItem(
              VendorMenuItem(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () => Get.to(() => const NotificationScreen()),
              ),
            ),
            _buildMenuItem(
              VendorMenuItem(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                subtitle: 'Manage payout accounts',
                onTap: () => Get.snackbar('Coming Soon', 'Payment Settings'),
              ),
            ),
            _buildMenuItem(
              VendorMenuItem(
                icon: Icons.lock_outline_rounded,
                title: 'Login & Security',
                onTap: () => Get.snackbar('Coming Soon', 'Login & Security'),
              ),
            ),
            _buildMenuItem(
              VendorMenuItem(
                icon: Icons.settings_outlined,
                title: 'App Settings',
                onTap: () => Get.snackbar('Coming Soon', 'App Settings'),
              ),
            ),

            const Divider(height: 32, thickness: 1),

            // ── Support Section ─────────────────────────────────────────
            _buildSectionHeader('Support'),
            _buildMenuItem(
              VendorMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () => Get.snackbar('Support', 'Contacting Support...'),
              ),
            ),
            _buildMenuItem(
              VendorMenuItem(
                icon: Icons.article_outlined,
                title: 'Terms & Conditions',
                onTap: () => Get.snackbar('Coming Soon', 'Terms & Conditions'),
              ),
            ),
            _buildMenuItem(
              VendorMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => Get.snackbar('Coming Soon', 'Privacy Policy'),
              ),
            ),

            const SizedBox(height: 48),

            // ── Logout ──────────────────────────────────────────────────
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Profile Header
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildProfileHeader(BuildContext context) {
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
                vendorInitials,
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
                  vendorName,
                  style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mutedGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.mutedGold.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(serviceIcon, size: 12, color: AppColors.mutedGold),
                      const SizedBox(width: 4),
                      Text(
                        serviceLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mutedGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: AppColors.mutedGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$rating ($reviewCount reviews)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed:
                onEditProfile ??
                () => Get.to(() => const EditVendorProfileScreen()),
            icon: const Icon(Icons.edit_outlined, color: AppColors.deepNavy),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.grey500,
            letterSpacing: 1.2,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(VendorMenuItem item) {
    return InkWell(
      onTap: item.onTap,
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
              child: Icon(item.icon, color: AppColors.deepNavy, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.subtitle!,
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
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
