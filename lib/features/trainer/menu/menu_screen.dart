import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/auth/welcome_screen.dart';
import 'package:catch_ride/view/notifications/notification_screen.dart';
import 'package:catch_ride/view/reviews/review_screen.dart';
import 'package:catch_ride/view/trainer/list/add_horse_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.mutedGold,
                    child: Text(
                      'JS',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('John Smith', style: AppTextStyles.titleMedium),
                        Text(
                          'Wellington Stables',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Trainer • USEF #12345',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.grey500,
                    ),
                    onPressed: () {
                      // Edit Profile
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Core Features
            _buildSectionHeader('Management'),
            _buildMenuItem(
              icon: Icons.inventory_2_outlined,
              title: 'Add your horses',
              onTap: () {
                Get.to(() => const AddHorseScreen());
              },
            ),
            _buildMenuItem(
              icon: Icons.people_outline,
              title: 'Barn Staff',
              subtitle: 'Approve & Manage Barn Managers',
              onTap: () {
                // Barn Manager Approval Screen (Admin-lite)
              },
            ),

            const SizedBox(height: 16),
            _buildSectionHeader('Account'),
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => Get.to(() => const NotificationScreen()),
            ),
            _buildMenuItem(
              icon: Icons.star_border,
              title: 'My Reviews',
              onTap: () => Get.to(() => const ReviewScreen()),
            ),
            _buildMenuItem(
              icon: Icons.payment,
              title: 'Payment Methods',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {},
            ),

            const SizedBox(height: 16),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                onPressed: () {
                  Get.offAll(() => const WelcomeScreen());
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.softRed),
                  foregroundColor: AppColors.softRed,
                ),
                child: const Text('Log Out'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
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
            letterSpacing: 1.2,
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
    Color? color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: color ?? AppColors.deepNavy),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: color ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySmall)
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.grey400,
      ),
      onTap: onTap,
    );
  }
}
